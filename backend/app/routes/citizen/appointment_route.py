from datetime import datetime
from fastapi import APIRouter, HTTPException, UploadFile, File, Depends
from fastapi.responses import JSONResponse
from app.core.database import db
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from app.schemas.citizen.appointment_schema import AppointmentBookingRequest
from app.schemas.citizen.model_schema import TaskInput
from app.services.citizen.citizen_service import get_available_slots, book_appointment, get_user_appointments,predict_appointment_time

router = APIRouter(
    prefix="/appointments",
    tags=["Appointments"]
)

@router.get("/slots/{service_id}/{location_id}")
async def get_available_slots_endpoint(
    service_id: str,
    location_id: str,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    try:
        slots = await get_available_slots(service_id, location_id)
        return JSONResponse(content={
            "status": "success",
            "available_slots": slots
        })
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/locations/{service_id}")
async def get_locations_by_service_id(service_id: str):
    """
    Returns a list of all locations related to the given service_id.
    """
    locations = await db.location.find_many(where={"service_id": service_id})
    
    result = []
    for location in locations:
        result.append({
            "location_id": getattr(location, "id", ""),
            "address": getattr(location, "address", "")
        })
    return result

@router.post("/book")
async def book_appointment_endpoint(
    service_id: str,
    slot_id: str,
    files: list[UploadFile] = File(...),
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    try:
        uploaded_documents = {}
        for file in files:
            file_content = await file.read()
            uploaded_documents[file.filename] = file_content

        booking_request = AppointmentBookingRequest(
            service_id=service_id,
            slot_id=slot_id,
            citizen_id=current_user.citizen_id,
            uploaded_documents=uploaded_documents
        )
        booking_response = await book_appointment(booking_request)
        return JSONResponse(content={
            "status": "success",
            "appointment": booking_response,
        })
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Get User Appointments
@router.get("/status/{status}")
async def get_user_appointments_endpoint(
    status: str,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    try:
        appointments = await get_user_appointments(status, current_user.citizen_id)
        formatted = []
        for apt in appointments:
            formatted.append({
                "appointment_id": apt["appointment_id"],
                "reference_number": apt["reference_number"],
                "service_name": apt["service_name"],
                "scheduled_date": apt["scheduled_date"],
                "scheduled_time": apt["scheduled_time"],
                "status": apt["status"].lower(),
                "address": apt["address"]
            })
        return JSONResponse(content={
            "status": "success",
            "appointments": formatted
        })
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{appointment_id}/reschedule")
async def reschedule_appointment_endpoint(
    appointment_id: str,
    slot_id: str,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    try:
        appointment = await db.appointment.find_unique(where={"appointment_id": appointment_id})
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        appt_dt = appointment.appointment_datetime
        now_dt = datetime.now(appt_dt.tzinfo) if appt_dt.tzinfo else datetime.now()
        if (appt_dt - now_dt).total_seconds() < 48*3600:
            return JSONResponse(content={
                "status": "failed",
                "message": "Rescheduling only allowed more than 48 hours before appointment"
            }, status_code=400)
        slot = await db.timeslot.find_unique(where={"timeslot_id": slot_id})
        if not slot:
            raise HTTPException(status_code=404, detail="New slot not found")
        await db.appointment.update(
            where={"appointment_id": appointment_id},
            data={
                "timeSlotTimeslot_id": slot_id,
                "appointment_datetime": slot.slot_datetime,
                "assigned_admin_id": slot.assigned_admin_id
            }
        )
        return JSONResponse(content={"status": "success", "message": "Appointment rescheduled."})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{appointment_id}/cancel")
async def cancel_appointment_endpoint(
    appointment_id: str,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    try:
        appointment = await db.appointment.find_unique(where={"appointment_id": appointment_id})
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        appt_dt = appointment.appointment_datetime
        now_dt = datetime.now(appt_dt.tzinfo) if appt_dt.tzinfo else datetime.now()
        if (appt_dt - now_dt).total_seconds() < 48*3600:
            return JSONResponse(content={
                "status": "failed",
                "message": "Cancellation only allowed more than 48 hours before appointment"
            }, status_code=400)
        await db.appointment.update(
            where={"appointment_id": appointment_id},
            data={"status": "Cancelled"}
        )
        return JSONResponse(content={"status": "success", "message": "Appointment cancelled."})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    