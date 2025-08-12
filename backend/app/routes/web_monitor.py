from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from typing import List, Optional
from datetime import datetime, timedelta

from app.services.web_monitor import GovernmentWebMonitor
from app.db.repositories.web_monitor import WebMonitorRepository
from app.schemas.web_monitor import (
    MonitoringStatus, ContentChangeResponse, 
    WebPageRecordResponse, ManualCheckRequest
)

router = APIRouter(
    prefix="/web-monitor",
    tags=["Web Monitoring"]
)

@router.post("/trigger-monitoring")
async def trigger_manual_monitoring(background_tasks: BackgroundTasks):
    """Manually trigger website monitoring"""
    try:
        # For now, run monitoring directly (later we'll use Celery)
        async with GovernmentWebMonitor() as monitor:
            changes = await monitor.monitor_government_sources()
            
        return {
            "message": "Monitoring completed",
            "changes_detected": len(changes),
            "status": "success"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to start monitoring: {str(e)}")

@router.get("/status", response_model=MonitoringStatus)
async def get_monitoring_status():
    """Get current monitoring status and statistics"""
    repo = WebMonitorRepository()
    
    try:
        await repo.connect()
        
        # Get recent changes
        recent_changes = await repo.get_recent_changes(days=7)
        changes_24h = [c for c in recent_changes if c.detected_at > datetime.utcnow() - timedelta(days=1)]
        
        await repo.disconnect()
        
        return MonitoringStatus(
            is_active=True,
            last_run=datetime.utcnow(),
            urls_monitored=3,  # Based on your GOVERNMENT_SOURCES config
            changes_last_24h=len(changes_24h),
            total_changes_this_week=len(recent_changes)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/check-url", response_model=ContentChangeResponse)
async def check_specific_url(request: ManualCheckRequest):
    """Manually check a specific URL for changes"""
    try:
        async with GovernmentWebMonitor() as monitor:
            change = await monitor.check_url_for_changes(str(request.url))
            
            if change:
                return ContentChangeResponse(
                    url=change.url,
                    changed=True,
                    change_type=change.change_type,
                    detected_at=change.timestamp,
                    old_hash=change.old_hash,
                    new_hash=change.new_hash
                )
            else:
                return ContentChangeResponse(
                    url=str(request.url),
                    changed=False,
                    detected_at=datetime.utcnow()
                )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/recent-changes", response_model=List[ContentChangeResponse])
async def get_recent_changes(days: int = 7):
    """Get recent content changes"""
    repo = WebMonitorRepository()
    
    try:
        await repo.connect()
        changes = await repo.get_recent_changes(days=days)
        await repo.disconnect()
        
        return [
            ContentChangeResponse(
                url=change.url,
                changed=True,
                change_type=change.change_type,
                detected_at=change.detected_at,
                old_hash=change.old_hash,
                new_hash=change.new_hash
            )
            for change in changes
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
