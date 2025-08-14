from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma
from prisma.errors import UniqueViolationError
from fastapi.responses import JSONResponse
from fastapi import UploadFile, File
from pydantic import BaseModel
from fastapi import Body, Form
import json


from app.core.database import get_db
from app.core.database import db
from app.schemas.admin import admin_schema
from app.schemas import token_schema
from app.db.admin import db_admin
from app.core import auth, hashing
from app.core.config import settings

router = APIRouter(
    prefix="/admins",
    tags=["Admins"]
)

@router.post("/register", response_model=admin_schema.Admin)
async def register_admin(
    admin_in: admin_schema.AdminCreate,
    db: Prisma = Depends(get_db)
):
    """
    Register a new admin in the system.
    """
    try:
        new_admin = await db_admin.create_admin(db, admin_in)
        return new_admin
    except UniqueViolationError:
        raise HTTPException(
            status_code=400,
            detail="An admin with the same email already exists.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An unexpected error occurred: {e}",
        )

@router.post("/login", response_model=token_schema.Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Prisma = Depends(get_db)
):
    """
    Authenticate admin and return a JWT access token.
    """
    admin = await db_admin.get_admin_by_email(db, email=form_data.username)
    if not admin or not hashing.verify_password(form_data.password, admin.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": admin.email}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=admin_schema.Admin)
async def read_admins_me(current_admin: admin_schema.Admin = Depends(auth.get_current_admin)):
    """
    Fetch the details of the currently authenticated admin.
    """
    return current_admin

@router.delete("/{appointment_id}/delete")
async def delete_appointment_endpoint(
    appointment_id: str,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin)
):
    try:
        appointment = await db.appointment.find_unique(where={"appointment_id": appointment_id})
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        slot_id = getattr(appointment, "timeSlotTimeslot_id", None)
        if slot_id:
            slot = await db.timeslot.find_unique(where={"timeslot_id": slot_id})
            if slot:
                appointment_ids = getattr(slot, "appointment_ids", [])
                appointment_ids = [aid for aid in appointment_ids if aid != appointment_id]
                await db.timeslot.update(
                    where={"timeslot_id": slot_id},
                    data={"appointment_ids": appointment_ids}
                )
        from app.core.supabase_client import supabase
        BUCKET_NAME = "appointment-documents"
        folder = f"{appointment_id}/"
        files = supabase.storage.from_(BUCKET_NAME).list(folder)
        for file in files:
            supabase.storage.from_(BUCKET_NAME).remove([folder + file["name"]])
        docs = await db.appointmentdocument.find_many(where={"appointment_id": appointment_id})
        for doc in docs:
            await db.appointmentdocument.delete(where={"appointment_doc_id": doc.appointment_doc_id})
        await db.appointment.delete(where={"appointment_id": appointment_id})
        return JSONResponse(content={"status": "success", "message": "Appointment permanently deleted."})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{appointment_id}/status")
async def update_appointment_status_admin(
    appointment_id: str,
    status: str,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin)
):
    try:
        if status not in ["Confirmed", "Completed"]:
            raise HTTPException(status_code=400, detail="Invalid status. Must be 'Confirmed' or 'Completed'.")
        appointment = await db.appointment.find_unique(where={"appointment_id": appointment_id})
        if not appointment:
            raise HTTPException(status_code=404, detail="Appointment not found")
        await db.appointment.update(
            where={"appointment_id": appointment_id},
            data={"status": status}
        )
        return JSONResponse(content={"status": "success", "message": f"Appointment status updated to {status}."})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{service_id}/store-form-template")
async def store_form_template_endpoint(
    service_id: str,
    request: str = Body(...), # JSON string of FormTemplateRequest
    template_file: UploadFile = File(None),
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin)
):
    """
    Stores a new form template in the FilledTemplate table.
    If a template file is provided, uploads it to Supabase and stores the URL.
    """
    import json
    try:
        request_dict = json.loads(request)
        validated = admin_schema.FormTemplateRequest(**request_dict)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid request format: {e}")
    template_url = None
    template_bytes = None
    template_filename = None
    if template_file:
        template_bytes = await template_file.read()
        template_filename = template_file.filename
        from app.core.supabase_client import supabase
        BUCKET_NAME = "gov-portal-form-templates"
        file_path = template_filename
        supabase.storage.from_(BUCKET_NAME).upload(file_path, template_bytes, {"content-type": "application/pdf", "x-upsert": "true"})
        template_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
    # Serialize form_template as JSON string before saving
    form_template_json = json.dumps(validated.form_template)
    new_template = await db.formtemplate.create(
        data={
            "form_name": validated.form_name,
            "service_id": service_id,
            "form_template": form_template_json,
            "template_url": template_url
        }
    )
    return JSONResponse(content={"status": "success", "form_id": new_template.form_id})
