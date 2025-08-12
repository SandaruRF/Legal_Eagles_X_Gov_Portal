from typing import Optional, List
from datetime import datetime, timedelta
from prisma import Prisma
from prisma.models import WebPageRecord, ContentChangeLog

class WebMonitorRepository:
    def __init__(self):
        self.db = Prisma()
    
    async def connect(self):
        await self.db.connect()
    
    async def disconnect(self):
        await self.db.disconnect()
    
    async def get_url_record(self, url: str) -> Optional[WebPageRecord]:
        """Get stored record for a URL"""
        return await self.db.webpagerecord.find_unique(
            where={"url": url}
        )
    
    async def store_url_hash(self, url: str, content_hash: str, content: str) -> WebPageRecord:
        """Store new URL with its hash"""
        return await self.db.webpagerecord.create(
            data={
                "url": url,
                "content_hash": content_hash,
                "content_preview": content[:500] if content else "",
                "last_checked": datetime.utcnow(),
                "last_modified": datetime.utcnow(),
            }
        )
    
    async def update_url_hash(self, url: str, new_hash: str, content: str) -> Optional[WebPageRecord]:
        """Update hash for existing URL"""
        return await self.db.webpagerecord.update(
            where={"url": url},
            data={
                "content_hash": new_hash,
                "content_preview": content[:500] if content else "",
                "last_checked": datetime.utcnow(),
                "last_modified": datetime.utcnow(),
            }
        )
    
    async def log_content_change(self, url: str, old_hash: str, new_hash: str, change_type: str) -> ContentChangeLog:
        """Log content change for audit trail"""
        return await self.db.contentchangelog.create(
            data={
                "url": url,
                "old_hash": old_hash,
                "new_hash": new_hash,
                "change_type": change_type,
                "detected_at": datetime.utcnow()
            }
        )
    
    async def get_recent_changes(self, days: int = 7) -> List[ContentChangeLog]:
        """Get recent content changes"""
        cutoff_date = datetime.utcnow() - timedelta(days=days)
        return await self.db.contentchangelog.find_many(
            where={"detected_at": {"gte": cutoff_date}},
            order={"detected_at": "desc"}
        )
