from pydantic import BaseModel
from typing import List

class FormTemplateRequest(BaseModel):
    form_name: str
    form_template: List[dict]
    service_name: str
    service_description: str
    required_documents: List[str]
    department_id: str