import hashlib
import logging
from datetime import datetime
from typing import List, Dict
from dataclasses import dataclass

from app.services.knowledge_base import KnowledgeBaseService
from app.db.repositories.web_monitor import WebMonitorRepository

logger = logging.getLogger(__name__)

@dataclass
class ContentChange:
    url: str
    old_hash: str
    new_hash: str
    content: str
    timestamp: datetime
    change_type: str  # 'new', 'updated', 'deleted'

class DocumentProcessor:
    def __init__(self):
        self.kb_service = KnowledgeBaseService()
        self.repo = WebMonitorRepository()
    
    async def process_content_change(self, change: ContentChange):
        """Process detected content changes and update knowledge base"""
        logger.info(f"Processing content change for {change.url}: {change.change_type}")
        
        try:
            if change.change_type in ['new', 'updated']:
                # Store in ChromaDB for semantic search
                doc_id = await self.kb_service.store_webpage_content(
                    url=change.url,
                    content=change.content,
                    timestamp=change.timestamp
                )
                
                # Log the change in database
                await self.repo.connect()
                await self.repo.log_content_change(
                    url=change.url,
                    old_hash=change.old_hash,
                    new_hash=change.new_hash,
                    change_type=change.change_type
                )
                await self.repo.disconnect()
                
                logger.info(f"Successfully processed change for {change.url}, doc_id: {doc_id}")
                
            elif change.change_type == 'deleted':
                # Handle deleted content if needed
                logger.info(f"Content deleted from {change.url}")
                
        except Exception as e:
            logger.error(f"Error processing content change for {change.url}: {str(e)}")
            raise
    
    def chunk_content(self, content: str, chunk_size: int = 1000) -> List[str]:
        """Split large content into searchable chunks"""
        words = content.split()
        chunks = []
        
        for i in range(0, len(words), chunk_size):
            chunk = ' '.join(words[i:i + chunk_size])
            chunks.append(chunk)
        
        return chunks if chunks else [content]
