from pydantic import BaseModel
from typing import Optional, Any, List, Dict

class FormValidation(BaseModel):
    min_length: Optional[int] = None
    max_length: Optional[int] = None
    pattern: Optional[str] = None

class FormField(BaseModel):
    id: str
    type: str
    label: str
    required: bool
    validation: Optional[FormValidation] = None

class FormSection(BaseModel):
    id: str
    title: str
    fields: List[FormField]

class FormTemplateResponse(BaseModel):
    form_id: str
    name: str
    form_template: List[FormSection]

class FilledFormCreate(BaseModel):
    form_id: str
    filled_data: Dict[str, Any]
    citizen_id: str

class SubmitFormRequest(BaseModel):
    form_data: Dict[str, Any]
    citizen_id: str 
