from app.schemas.citizen.filled_form_schema import FilledFormCreate
from app.schemas.citizen.appointment_schema import AppointmentBookingRequest
from app.core.database import db
from prisma.enums import AppointmentStatus
from datetime import datetime
import requests
from PyPDF2 import PdfReader, PdfWriter
from PyPDF2.generic import NameObject, BooleanObject
import os
import uuid
import tempfile
import pandas as pd
import numpy as np
import pickle
import xgboost as xgb
from pydantic import BaseModel

from app.core.supabase_client import supabase

def predict_appointment_time(datetime: str,task_id: str):
    MODEL_DIR = os.path.join(os.path.dirname(__file__), '../../../model')
    model_path = os.path.abspath(os.path.join(MODEL_DIR, 'xgb_predict_model.pkl'))
    stats_path = os.path.abspath(os.path.join(MODEL_DIR, 'task_stats.csv'))

    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    task_stats = pd.read_csv(stats_path)
    # Convert task_id to int
    task_id_int = int(task_id.split("-")[-1])

    appt_datetime = pd.to_datetime(datetime)

    # Build dataframe
    df = pd.DataFrame([{
        "task_id": task_id_int,
        "appt_datetime": appt_datetime
    }])

    # Time features
    df["hour"] = df["appt_datetime"].dt.hour
    df["day_of_week"] = df["appt_datetime"].dt.dayofweek
    df["month"] = df["appt_datetime"].dt.month
    df["week_of_year"] = df["appt_datetime"].dt.isocalendar().week.astype(int)

    # Cyclic features
    df["hour_sin"] = np.sin(2 * np.pi * df["hour"] / 24)
    df["month_sin"] = np.sin(2 * np.pi * df["month"] / 12)
    df["month_cos"] = np.cos(2 * np.pi * df["month"] / 12)
    df["dow_sin"] = np.sin(2 * np.pi * df["day_of_week"] / 7)

    df["is_end_of_month"] = df["appt_datetime"].dt.is_month_end.astype(int)
    df["is_monday"] = (df["day_of_week"] == 0).astype(int)
    df["is_friday"] = (df["day_of_week"] == 4).astype(int)

    df["task_dow_sin_interaction"] = df["task_id"] * df["dow_sin"]

    # Festival features
    festival_md = ["01-01","01-14","01-15","02-04","04-13","04-14","05-01","12-25"]
    festival_dates = [pd.to_datetime(f"2000-{md}") for md in festival_md]

    def days_to_next_festival(date):
        app_md = date.replace(year=2000)
        future_days = [(f - app_md).days if (f - app_md).days >= 0 else (f - app_md).days + 366 for f in festival_dates]
        return min(future_days)

    def days_since_last_festival(date):
        app_md = date.replace(year=2000)
        past_days = [(app_md - f).days if (app_md - f).days >= 0 else (app_md - f).days + 366 for f in festival_dates]
        return min(past_days)

    df["days_to_next_festival"] = df["appt_datetime"].dt.date.apply(lambda d: days_to_next_festival(pd.to_datetime(d)))
    df["days_since_last_festival"] = df["appt_datetime"].dt.date.apply(lambda d: days_since_last_festival(pd.to_datetime(d)))

    # Merge with task_stats
    df = df.merge(task_stats, how="left", left_on="task_id", right_on="task_id")
    df["task_count_per_month"] = df["task_count_per_month"].fillna(0)
    df["task_id_mean_duration"] = df["task_id_mean_duration"].fillna(0)

    # Select columns in the same order
    feature_cols = [
        'hour_sin','month_sin','month_cos','week_of_year',
        'is_friday','is_monday','is_end_of_month','days_to_next_festival',
        'days_since_last_festival','task_dow_sin_interaction',
        'task_id_mean_duration','task_count_per_month'
    ]

    dtest = xgb.DMatrix(df[feature_cols])
    pred_minutes  = model.predict(dtest).round().astype(int)[0]
    return int(pred_minutes)

async def get_form_template(form_id: str):
    form = await db.formtemplate.find_unique(where={"form_id": form_id})
    if not form:
        return None
    return {
        "form_id": form.form_id,
        "name": form.form_name,
        "form_template": form.form_template 
    }

async def fill_passport_pdf(form_data, input_pdf, output_pdf):
    def set_radio_or_checkbox(page, field_name, value):
        for annot in page[NameObject("/Annots")]:
            obj = annot.get_object()
            if obj.get(NameObject("/T")) == field_name:
                obj.update({
                    NameObject("/V"): NameObject(f"/{value}"),
                    NameObject("/AS"): NameObject(f"/{value}")
                })

    sex = form_data.get("sex", "M")
    type_of_service = form_data.get("type_of_service", "Normal")
    type_of_travel_doc = form_data.get("type_of_travel_doc", "All Countries")

    reader = PdfReader(input_pdf)
    writer = PdfWriter()
    writer.append(reader)

    for page in writer.pages:
        writer.update_page_form_field_values(page, {k: v for k, v in form_data.items() if v})

    if sex == "M":
        set_radio_or_checkbox(writer.pages[0], "SexM", "Yes")
    elif sex == "F":
        set_radio_or_checkbox(writer.pages[0], "SexF", "Yes")

    if form_data.get("DC No"):
        set_radio_or_checkbox(writer.pages[0], "DCitizenship Y", "Yes")
    else:
        set_radio_or_checkbox(writer.pages[0], "DCitizenship N", "Yes")

    if type_of_service == "Normal":
        set_radio_or_checkbox(writer.pages[0], "TOS Normal", "Yes")
    elif type_of_service == "OneDay":
        set_radio_or_checkbox(writer.pages[0], "TOS 1day", "Yes")

    if type_of_travel_doc == "All Countries":
        set_radio_or_checkbox(writer.pages[0], "0", "Yes")
    elif type_of_travel_doc == "Middle East":
        set_radio_or_checkbox(writer.pages[0], "1", "Yes")
    elif type_of_travel_doc == "Emergency":
        set_radio_or_checkbox(writer.pages[0], "2", "Yes")
    elif type_of_travel_doc == "Identity":
        set_radio_or_checkbox(writer.pages[0], "3", "Yes")

    if NameObject("/AcroForm") in writer._root_object:
        writer._root_object[NameObject("/AcroForm")].update(
            {NameObject("/NeedAppearances"): BooleanObject(True)}
        )

    with open(output_pdf, "wb") as f:
        writer.write(f)

async def upload_file_to_supabase(file_path: str, file_name: str) -> str:
    """
    Uploads a file to Supabase storage and returns the public URL.
    """
    bucket_name = "gov-portal-filled-forms"
    supabase.storage.from_(bucket_name).upload(file_name, file_path, {"content-type": "application/pdf", "x-upsert": "true"})
    public_url = supabase.storage.from_(bucket_name).get_public_url(file_name)
    return public_url

async def fill_pdf(filled_form: FilledFormCreate):
    form_template = await db.formtemplate.find_unique(where={"form_id": filled_form.form_id})
    if not form_template or not form_template.template_url:
        raise ValueError("Template URL not found for the given form ID.")

    with tempfile.TemporaryDirectory() as temp_dir:
            input_pdf = os.path.join(temp_dir, "template.pdf")
            output_pdf = os.path.join(temp_dir, "filled_application.pdf")

            # Download the template PDF
            response = requests.get(form_template.template_url)
            if response.status_code != 200:
                raise ValueError("Failed to download the template PDF.")

            with open(input_pdf, "wb") as f:
                f.write(response.content)

            # Fill the PDF
            await fill_passport_pdf(filled_form.filled_data, input_pdf, output_pdf)

            # UPLOAD the final PDF from the temporary path to your storage
            unique_filename = f"{str(uuid.uuid4())}_filled_application.pdf"
            final_pdf_url = await upload_file_to_supabase(output_pdf, unique_filename)

            # Return the final, public URL of the uploaded PDF
            return final_pdf_url

async def create_filled_form(filled_form: FilledFormCreate):
    # Save the filled form data to the database
    new_filled = await db.filledform.create(
        data={
            "form_id": filled_form.form_id,
            "filled_data": filled_form.filled_data,
            "citizen_id": filled_form.citizen_id
        }
    )
    return new_filled.filled_form_id


async def get_available_slots(service_id: str, location_id: str):
    # Query TimeSlot table and fetch officer details using assigned_admin_id
    slots = await db.timeslot.find_many(
        where={"location_id": location_id, "service_id": service_id},
        order={"slot_datetime": "asc"}
    )
    result = []
    for slot in slots:
        appointment_ids = slot.appointment_ids if hasattr(slot, "appointment_ids") and slot.appointment_ids else []
        if len(appointment_ids) < slot.max_appointments:
            officer = None
            if slot.assigned_admin_id:
                admin = await db.admin.find_unique(where={"admin_id": slot.assigned_admin_id})
                if admin:
                    officer = {"id": admin.admin_id, "name": admin.full_name}
            result.append({
                "slot_id": slot.timeslot_id,
                "date": slot.slot_datetime.strftime("%Y-%m-%d"),
                "time": slot.slot_datetime.strftime("%H:%M:%S"),
                "available": True,
                "officer": officer
            })
    return result

async def book_appointment(booking_request: AppointmentBookingRequest):
    # Save appointment and documents
    # Fetch slot to get slot_datetime and assigned_admin_id
    slot = await db.timeslot.find_unique(where={"timeslot_id": booking_request.slot_id})
    slot_datetime = getattr(slot, "slot_datetime", datetime.now()) if slot else datetime.now()
    assigned_admin_id = getattr(slot, "assigned_admin_id", None) if slot else None
    reference_number = str(uuid.uuid4()).replace('-', '')[:10]  # Generate unique reference number
    appointment = await db.appointment.create(
        data={
            "appointment_datetime": slot_datetime,
            "service_id": booking_request.service_id,
            "timeSlotTimeslot_id": booking_request.slot_id,
            "citizen_id": booking_request.citizen_id,
            "status": AppointmentStatus.Booked,
            "reference_number": reference_number,
            "assigned_admin_id": assigned_admin_id
        }
    )
    # Update TimeSlot.appointment_ids
    if slot:
        appointment_ids = getattr(slot, "appointment_ids", [])
        appointment_ids.append(appointment.appointment_id)
        await db.timeslot.update(
            where={"timeslot_id": booking_request.slot_id},
            data={"appointment_ids": appointment_ids}
        )

    # Upload files to Supabase bucket using appointment_id as folder name
    from app.core.supabase_client import supabase
    BUCKET_NAME = "appointment-documents"
    folder = f"{appointment.appointment_id}/"
    for doc_name, file_content in booking_request.uploaded_documents.items():
        # If file_content is a URL, skip upload (for backward compatibility)
        if isinstance(file_content, bytes):
            file_path = folder + doc_name
            supabase.storage.from_(BUCKET_NAME).upload(file_path, file_content, {"content-type": "application/octet-stream", "x-upsert": "true"})
            public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
        else:
            public_url = file_content
        await db.appointmentdocument.create(
            data={
                "appointment_id": appointment.appointment_id,
                "document_name": doc_name,
                "document_url": public_url,
                "uploaded_at": datetime.now()
            }
        )

    service = await db.service.find_unique(where={"service_id": booking_request.service_id}, include={"department": True})
    task_id="TASK-001"
    predicted_duration = predict_appointment_time(slot_datetime, task_id)

    return {
        "appointment_id": appointment.appointment_id,
        "reference_number": reference_number,
        "service": {
            "name": service.name if service else "",
            "department": service.department.name if service and service.department else ""
        },
        "scheduled_date": appointment.appointment_datetime.strftime("%Y-%m-%d"),
        "scheduled_time": appointment.appointment_datetime.strftime("%H:%M:%S"),
        "approximate_duration": predicted_duration
    }

async def get_user_appointments(status: str, citizen_id: str):
    # Query appointments by status and citizen_id
    appointments = await db.appointment.find_many(
        where={"status": status.capitalize(), "citizen_id": citizen_id},
        include={"service": True}
    )
    result = []
    for apt in appointments:
        address = ""
        # Get address from Location table via TimeSlot
        timeslot = await db.timeslot.find_unique(where={"timeslot_id": apt.timeSlotTimeslot_id}) if hasattr(apt, "timeSlotTimeslot_id") else None
        location_id = getattr(timeslot, "location_id", None) if timeslot else None
        location = await db.location.find_unique(where={"id": location_id}) if location_id else None
        if location and hasattr(location, "address"):
            address = location.address or ""
        result.append({
            "appointment_id": apt.appointment_id,
            "reference_number": apt.reference_number,
            "service_name": apt.service.name if apt.service else "",
            "scheduled_date": apt.appointment_datetime.strftime("%Y-%m-%d"),
            "scheduled_time": apt.appointment_datetime.strftime("%H:%M:%S"),
            "status": apt.status,
            "address": address,
        })
    return result
