from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional, Union
from fastapi.security import OAuth2PasswordRequestForm
from prisma import Prisma

from prisma.errors import UniqueViolationError
from fastapi.responses import JSONResponse
from fastapi import UploadFile, File
from pydantic import BaseModel
from fastapi import Body, Form
import json
from fastapi import HTTPException



from app.core.database import get_db
from app.core.database import db
from app.schemas.admin import admin_schema
from app.schemas import token_schema
from app.core import auth
from app.services.admin import admin_service
from app.schemas.admin.form_schema import FormTemplateRequest

router = APIRouter(prefix="/admins", tags=["Admins"])


@router.post("/register", response_model=admin_schema.Admin)
async def register_admin(
    admin_in: admin_schema.AdminCreate,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
    """
    Register a new admin in the system (Head role only).
    """
    return await admin_service.register_admin_service(db, admin_in, current_admin)


@router.post("/login", response_model=token_schema.Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Prisma = Depends(get_db)
):
    """
    Authenticate admin and return a JWT access token.
    """
    return await admin_service.login_admin_service(db, form_data)


@router.get("/me", response_model=admin_schema.Admin)
async def read_admins_me(
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
):
    """
    Fetch the details of the currently authenticated admin.
    """

    return await admin_service.get_current_admin_service(current_admin)


@router.get("/", response_model=List[admin_schema.Admin])
async def get_admins_by_department(
    department_id: Optional[str] = Query(None),
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
    """
    Get all admins by department (Head role only).
    """
    return await admin_service.get_admins_by_department_service(
        db, current_admin, department_id
    )


@router.put("/{admin_id}", response_model=admin_schema.Admin)
async def update_admin(
    admin_id: str,
    admin_update: admin_schema.AdminUpdate,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
    """
    Update an admin (Head role only).
    """
    return await admin_service.update_admin_service(
        db, admin_id, admin_update, current_admin
    )


@router.delete("/{admin_id}")
async def delete_admin(
    admin_id: str,
    current_admin: admin_schema.Admin = Depends(auth.get_current_admin),
    db: Prisma = Depends(get_db),
):
    """
    Delete an admin (Head role only).
    """
    return await admin_service.delete_admin_service(db, admin_id, current_admin)


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




@router.post("/store-form-template")
async def store_form_template_endpoint(
    request: str = Form(...),
    template_file: Optional[UploadFile] = File(None),
    # current_admin: admin_schema.Admin = Depends(auth.get_current_admin)
):
    """
    Receives a multipart/form-data request with a JSON string in 'request' and an optional file. Creates a new Service row, then stores the form template using the generated service_id.
    """
    import json
    try:
        request_dict = json.loads(request)
        validated = FormTemplateRequest(**request_dict)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid request format: {e}")
    template_url = None
    if template_file is not None and isinstance(template_file, UploadFile):
        template_bytes = await template_file.read()
        template_filename = template_file.filename
        from app.core.supabase_client import supabase
        BUCKET_NAME = "gov-portal-form-templates"
        file_path = template_filename
        supabase.storage.from_(BUCKET_NAME).upload(file_path, template_bytes, {"content-type": "application/pdf", "x-upsert": "true"})
        template_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_path)
    required_documents_json = json.dumps(validated.required_documents)
    new_service = await db.service.create(
        data={
            "name": validated.service_name,
            "description": validated.service_description,
            "required_documents": required_documents_json,
            "department_id": validated.department_id
        }
    )
    service_id = new_service.service_id
    form_template_json = json.dumps(validated.form_template)
    new_template = await db.formtemplate.create(
        data={
            "form_name": validated.form_name,
            "service_id": service_id,
            "form_template": form_template_json,
            "template_url": template_url
        }
    )
    return JSONResponse(content={"status": "success", "form_id": new_template.form_id, "service_id": service_id})
