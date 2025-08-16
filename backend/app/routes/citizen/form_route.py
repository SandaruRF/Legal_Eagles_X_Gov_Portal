from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
from app.schemas.citizen.filled_form_schema import FilledFormCreate, SubmitFormRequest
from app.services.citizen.citizen_service import  get_form_template, fill_pdf
from app.core.database import db
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from datetime import datetime
from supabase import create_client
import os
import aiofiles
import json
import shutil

router = APIRouter(
    prefix="/forms",
    tags=["Forms"]
)

@router.get("/{form_id}")
async def get_form_template_endpoint(form_id: str):
    try:
        form_template = await get_form_template(form_id)
        return JSONResponse(content={
            "status": "success",
            "form": form_template
        })
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/{form_id}/submit")
async def submit_form_application(
    form_id: str,
    request_body: SubmitFormRequest,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    temp_dir = None
    try:
                # Get form template to check template_url
        form = await db.formtemplate.find_unique(where={"form_id": form_id})
        template_url = form.template_url if form else None

        key_mapping = {
            "Surname": "Surname1",
            "Other Names": "OtherName1",
            "Street & house no": "PermAddressOS1",
            "City": "PermAddressOS2",
            "District": "PA District",
            "DOB Date": "DOB Date",
            "DOB Month": "DOB Month",
            "DOB Year": "DOB Year",
            "Birth Certificate No": "BC No",
            "Birth District": "BC District",
            "Place Of Birth": "POB",
            "Profession": "Profession",
            "Dual Citizenship No": "DC No",
            "Phone Number": "Mobile Phone",
            "Email": "eMail",
            "NIC No": "NIC No",
            "Present Travel Document Number": "Present Travel Document Number",
            "NMRP No": "NMRP No",
            "Date filled": "Date dd/mm/yyyy",
            "Foreign Nationality": "ForeignN",
            "Foreign Passport No": "17 Foreign Passport No",
            "National Identity Card No/ Present Travel Document No of Father/Guardian":"National Identity Card No I Present Travel Document No",
            "National Identity Card No/ Present Travel Document No of Mother/Guardian":"National Identity Card No I Present Travel Document No_2",
            "Sex": "sex",
            "Type of service": "type_of_service",
            "Type of travel document": "type_of_travel_doc"
        }

        mapped_form_data = {
            key_mapping.get(key, key): value for key, value in request_body.form_data.items()
        }

        filled_form = FilledFormCreate(
            form_id=form_id,
            filled_data=mapped_form_data,
            citizen_id=current_user.citizen_id
        )

        public_url = None
        # Only fill PDF if template_url exists
        if template_url:
            public_url = await fill_pdf(filled_form)
            
        # Save filled form to DB, pdf url is None if no template
        await db.filledform.create(
            data={
                "form_id": form_id,
                "filled_data": json.dumps(request_body.form_data),
                "citizen_id": current_user.citizen_id,
                "generated_pdf_url": public_url,
                "created_at": datetime.now()
            }
        )

        return JSONResponse(content={
            "status": "success",
            "message": "Form submitted successfully.",
            "pdf_url": public_url
        })
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"File upload failed: {e}")
    finally:
        if temp_dir and os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)