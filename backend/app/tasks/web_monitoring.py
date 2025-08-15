from celery import Celery
from celery.schedules import crontab
from datetime import datetime
import asyncio
import logging

from app.core.config import get_settings
from app.services.web_monitor import GovernmentWebMonitor
from app.services.document_processor import DocumentProcessor

logger = logging.getLogger(__name__)

settings = get_settings()

# Initialize Celery
celery_app = Celery(
    "government_web_monitor",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

# Configure Celery
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    beat_schedule={
        "monitor-government-websites": {
            "task": "app.tasks.web_monitoring.monitor_websites_task",
            "schedule": crontab(minute=f"*/{settings.SCRAPING_INTERVAL_MINUTES}"),
        },
        "discover-new-pages": {
            "task": "app.tasks.web_monitoring.discover_pages_task",
            "schedule": crontab(hour=2, minute=0),  # Daily at 2 AM
        },
    },
)

@celery_app.task(bind=True, max_retries=3)
def monitor_websites_task(self):
    """Celery task to monitor government websites for changes"""
    try:
        logger.info("Starting scheduled website monitoring task")
        
        # Run async function in celery task
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        async def run_monitoring():
            async with GovernmentWebMonitor() as monitor:
                changes = await monitor.monitor_government_sources()
                
                if changes:
                    # Process changes and update knowledge base
                    processor = DocumentProcessor()
                    for change in changes:
                        await processor.process_content_change(change)
                    
                    logger.info(f"Processed {len(changes)} content changes")
                else:
                    logger.info("No content changes detected")
                
                return len(changes)
        
        changes_count = loop.run_until_complete(run_monitoring())
        loop.close()
        
        return {
            "status": "success",
            "changes_detected": changes_count,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error in monitoring task: {str(e)}")
        # Retry the task
        raise self.retry(countdown=60 * 5)  # Retry after 5 minutes

@celery_app.task
def discover_pages_task():
    """Task to discover new relevant pages on government websites"""
    logger.info("Starting page discovery task")
    
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    async def run_discovery():
        async with GovernmentWebMonitor() as monitor:
            all_discovered = []
            
            for category, urls in settings.GOVERNMENT_SOURCES.items():
                for url in urls:
                    discovered = await monitor.discover_additional_pages(url)
                    all_discovered.extend(discovered)
            
            # Add newly discovered URLs to monitoring list
            logger.info(f"Discovered {len(all_discovered)} new pages")
            return all_discovered
    
    discovered_pages = loop.run_until_complete(run_discovery())
    loop.close()
    
    return {
        "status": "success",
        "pages_discovered": len(discovered_pages),
        "timestamp": datetime.utcnow().isoformat()
    }
