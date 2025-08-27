from pydantic import BaseModel

class TaskInput(BaseModel):
    date: str
    time: str
    task_id: str