from pydantic import BaseModel, HttpUrl
from datetime import datetime
from typing import Optional

class MonitoringStatus(BaseModel):
    is_active: bool
    last_run: datetime
    urls_monitored: int
    changes_last_24h: int
    total_changes_this_week: int

class ContentChangeResponse(BaseModel):
    url: str
    changed: bool
    change_type: Optional[str] = None
    detected_at: datetime
    old_hash: Optional[str] = None
    new_hash: Optional[str] = None

class WebPageRecordResponse(BaseModel):
    id: str
    url: str
    content_hash: str
    last_checked: datetime
    last_modified: datetime
    is_active: bool
    error_count: int

class ManualCheckRequest(BaseModel):
    url: HttpUrl
    force_update: bool = False
