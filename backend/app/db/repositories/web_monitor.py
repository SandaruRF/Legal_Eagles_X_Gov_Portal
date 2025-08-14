from typing import Optional, List
from datetime import datetime, timedelta
import logging
import asyncio

from prisma.models import WebPageRecord, ContentChangeLog
from app.core.database import get_db  # Use global database instance

logger = logging.getLogger(__name__)

class WebMonitorRepository:
    def __init__(self):
        # Use the global database instance instead of creating new ones
        self.db = get_db()
    
    async def connect(self):
        """Method kept for backward compatibility - DB is already connected globally"""
        pass
    
    async def disconnect(self):
        """Method kept for backward compatibility - DB connection managed globally"""
        pass
    
    async def get_url_record(self, url: str) -> Optional[WebPageRecord]:
        """Get stored record for a URL using global DB instance"""
        try:
            result = await self.db.webpagerecord.find_unique(where={"url": url})
            logger.debug(f"Database query for {url}: {'Found' if result else 'Not found'}")
            return result
        except Exception as e:
            logger.error(f"Error getting URL record for {url}: {str(e)}")
            return None
    
    async def store_url_hash(self, url: str, content_hash: str, content: str) -> Optional[WebPageRecord]:
        """Store new URL with its hash using global DB instance"""
        try:
            result = await self.db.webpagerecord.create(
                data={
                    "url": url,
                    "content_hash": content_hash,
                    "content_preview": content[:500] if content else "",
                    "last_checked": datetime.utcnow(),
                    "last_modified": datetime.utcnow(),
                }
            )
            logger.info(f"Stored new URL record: {url}")
            return result
        except Exception as e:
            logger.error(f"Error storing URL hash for {url}: {str(e)}")
            return None
    
    async def update_url_hash(self, url: str, new_hash: str, content: str) -> Optional[WebPageRecord]:
        """Update hash for existing URL using global DB instance"""
        try:
            result = await self.db.webpagerecord.update(
                where={"url": url},
                data={
                    "content_hash": new_hash,
                    "content_preview": content[:500] if content else "",
                    "last_checked": datetime.utcnow(),
                    "last_modified": datetime.utcnow(),
                }
            )
            logger.info(f"Updated URL record: {url}")
            return result
        except Exception as e:
            logger.error(f"Error updating URL hash for {url}: {str(e)}")
            return None
    
    async def log_content_change(self, url: str, old_hash: str, new_hash: str, change_type: str) -> Optional[ContentChangeLog]:
        """Log content change using global DB instance"""
        try:
            result = await self.db.contentchangelog.create(
                data={
                    "url": url,
                    "old_hash": old_hash,
                    "new_hash": new_hash,
                    "change_type": change_type,
                    "detected_at": datetime.utcnow()
                }
            )
            logger.info(f"Logged content change: {url} - {change_type}")
            return result
        except Exception as e:
            logger.error(f"Error logging content change for {url}: {str(e)}")
            return None
    
    async def get_recent_changes(self, days: int = 7) -> List[ContentChangeLog]:
        """Get recent content changes using global DB instance"""
        try:
            cutoff_date = datetime.utcnow() - timedelta(days=days)
            result = await self.db.contentchangelog.find_many(
                where={"detected_at": {"gte": cutoff_date}},
                order={"detected_at": "desc"}
            )
            return result
        except Exception as e:
            logger.error(f"Error getting recent changes: {str(e)}")
            return []
