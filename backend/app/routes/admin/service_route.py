from fastapi import APIRouter, Body, HTTPException
from typing import List, Optional
from pydantic import BaseModel
from app.core.database import db
import json

router = APIRouter()

class FormField(BaseModel):
    type: str
    label: str
    required: bool
    placeholder: Optional[str] = None
    maxLength: Optional[int] = None
    minValue: Optional[float] = None
    maxValue: Optional[float] = None
    options: Optional[List[str]] = None

class ServiceForm(BaseModel):
    departmentID: str
    departmentName: str
    serviceName: str
    formName: str
    description: str
    category: Optional[str] = None
    processingTime: Optional[int] = None
    requiredDocuments: List[str]
    formFields: List[FormField]

@router.post("/admin/services", tags=["Services"])
async def create_service(service: ServiceForm = Body(...)):
    """
    Create a new government service with its form structure and store in database.
    """
    try:
        print(f"Received service data: {service.dict()}")  # Debug log
        
        # First, verify if the department exists
        department = await db.department.find_unique(
            where={
                'department_id': service.departmentID
            }
        )
        print(f"Department lookup result: {department}")  # Debug log
        
        if not department:
            raise HTTPException(status_code=404, detail="Department not found")

        # Create required_documents JSON object and serialize it properly
        required_docs = service.requiredDocuments
        print(f"Required docs JSON: {required_docs}")  # Debug log

        # Create the service in the database
        try:
            # Convert required_docs to JSON string first
            required_docs_json = json.dumps(required_docs)
            print(f"Required docs JSON string: {required_docs_json}")  # Debug log
            
            # Create service with proper data structure
            service_data = {
                "name": service.serviceName,
                "description": service.description,
                "required_documents": required_docs_json,  # Send as JSON string
                "department": {
                    "connect": {
                        "department_id": service.departmentID
                    }
                }
            }
            print(f"Service create data: {service_data}")  # Debug log
            
            created_service = await db.service.create(data=service_data)
            print(f"Created service: {created_service}")  # Debug log
        except Exception as e:
            print(f"Error creating service: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Failed to create service: {str(e)}")

        # Create form template
        try:
            # Prepare form fields data structure
            form_fields_data = [field.dict() for field in service.formFields]

            form_fields_json = json.dumps(form_fields_data)
            print(f"Form template data: {form_fields_json}")  # Debug log
            
            # Create form template with both fields
            form_template_data = {
                "form_name": service.formName,
                "template_url": "",  # Empty string instead of None
                "form_template": json.dumps(form_fields_data),  # Convert to JSON string
                "service": {
                    "connect": {
                        "service_id": created_service.service_id
                    }
                }
            }
            
            print(f"Creating form template with data: {form_template_data}")
            form_template = await db.formtemplate.create(data=form_template_data)
            print(f"Created form template: {form_template}")  # Debug log
        except Exception as e:
            print(f"Error creating form template: {str(e)}")
            # Try to rollback service creation
            if created_service:
                try:
                    await db.service.delete(where={'service_id': created_service.service_id})
                except:
                    pass  # Ignore rollback errors
            raise HTTPException(status_code=500, detail=f"Failed to create form template: {str(e)}")

        # Parse required_documents from JSON string if needed
        try:
            required_docs = created_service.required_documents
            if isinstance(required_docs, str):
                required_docs = json.loads(required_docs)
        except:
            required_docs = []

        # Construct the response
        response_data = {
            "status": "success",
            "message": "Service created successfully",
            "data": {
                "service": {
                    "service_id": created_service.service_id,
                    "name": created_service.name,
                    "description": created_service.description,
                    "required_documents": required_docs,
                    "department_id": created_service.department_id
                },
                "form_template": {
                    "form_id": form_template.form_id,
                    "form_name": form_template.form_name,
                    "template_url": form_template.template_url,
                    "form_template": form_template.form_template  # It's already a dictionary from Prisma
                }
            }
        }

        print(f"Returning response: {response_data}")  # Debug log
        return response_data

    except HTTPException as http_error:
        raise http_error
    except Exception as e:
        print(f"Error in final response: {str(e)}")  # Debug log
        raise HTTPException(status_code=500, detail=str(e))
