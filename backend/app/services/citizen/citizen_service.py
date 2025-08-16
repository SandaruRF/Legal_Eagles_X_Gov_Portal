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
import shutil


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


async def fill_pdf(filled_form: FilledFormCreate):
    form_template = await db.formtemplate.find_unique(where={"form_id": filled_form.form_id})
    if not form_template or not form_template.template_url:
        raise ValueError("Template URL not found for the given form ID.")

    # Create a unique temp directory for this operation
    temp_dir = os.path.join("temp_files", str(uuid.uuid4()))
    os.makedirs(temp_dir, exist_ok=True)

    input_pdf = os.path.join(temp_dir, "template.pdf")
    output_pdf = os.path.join(temp_dir, "filled_application.pdf")

    # Download the template PDF
    response = requests.get(form_template.template_url)
    if response.status_code != 200:
        shutil.rmtree(temp_dir)
        raise ValueError("Failed to download the template PDF.")

    with open(input_pdf, "wb") as f:
        f.write(response.content)

    # Fill the PDF
    await fill_passport_pdf(filled_form.filled_data, input_pdf, output_pdf)

    # Return the path to the filled PDF for further processing (e.g., upload to Supabase)
    return output_pdf

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
    return {
        "appointment_id": appointment.appointment_id,
        "reference_number": reference_number,
        "service": {
            "name": service.name if service else "",
            "department": service.department.name if service and service.department else ""
        },
        "scheduled_date": appointment.appointment_datetime.strftime("%Y-%m-%d"),
        "scheduled_time": appointment.appointment_datetime.strftime("%H:%M:%S")
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
            "address": address
        })
    return result
