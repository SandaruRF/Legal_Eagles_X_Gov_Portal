from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text
from sqlalchemy.sql import func
from app.models.base import Base

class WebPageRecord(Base):
    __tablename__ = "web_page_records"
    
    id = Column(Integer, primary_key=True, index=True)
    url = Column(String(2000), unique=True, index=True, nullable=False)
    content_hash = Column(String(64), nullable=False)  # SHA-256 hash
    last_checked = Column(DateTime(timezone=True), server_default=func.now())
    last_modified = Column(DateTime(timezone=True), server_default=func.now())
    is_active = Column(Boolean, default=True)
    content_preview = Column(Text)  # First 500 chars for quick reference
    error_count = Column(Integer, default=0)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class ContentChangeLog(Base):
    __tablename__ = "content_change_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    url = Column(String(2000), nullable=False, index=True)
    old_hash = Column(String(64))
    new_hash = Column(String(64), nullable=False)
    change_type = Column(String(20), nullable=False)  # 'new', 'updated', 'deleted'
    detected_at = Column(DateTime(timezone=True), server_default=func.now())
