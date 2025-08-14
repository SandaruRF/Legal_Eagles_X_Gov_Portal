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
        """Process single content change - keep your existing method"""
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
    
    # batch processing method
    async def process_multiple_changes(self, changes: List[ContentChange]):
        """Process multiple content changes in batch - MORE EFFICIENT"""
        if not changes:
            logger.info("No changes to process")
            return
        
        logger.info(f"Processing {len(changes)} content changes in batch")
        
        try:
            documents = []
            metadatas = []
            ids = []
            database_logs = []
            
            for change in changes:
                if change.change_type in ['new', 'updated']:
                    # Chunk large content for better search
                    chunks = self.chunk_content(change.content)
                    
                    for i, chunk in enumerate(chunks):
                        doc_id = f"webpage_{hashlib.sha256(f'{change.url}_{i}'.encode()).hexdigest()}"
                        
                        metadata = {
                            "url": change.url,
                            "source_type": "government_website",
                            "last_updated": change.timestamp.isoformat(),
                            "content_type": "webpage",
                            "chunk_index": i,
                            "total_chunks": len(chunks),
                            "change_type": change.change_type
                        }
                        
                        documents.append(chunk)
                        metadatas.append(metadata)
                        ids.append(doc_id)
                    
                    # Prepare database log entry
                    database_logs.append({
                        "url": change.url,
                        "old_hash": change.old_hash,
                        "new_hash": change.new_hash,
                        "change_type": change.change_type
                    })
                
                elif change.change_type == 'deleted':
                    logger.info(f"Content deleted from {change.url}")
            
            # Batch insert to ChromaDB
            if documents:
                await self.kb_service.add_documents(documents, metadatas, ids)
                logger.info(f"✅ Successfully added {len(documents)} document chunks to ChromaDB")
            
            # Batch log to database
            if database_logs:
                await self.repo.connect()
                for log_entry in database_logs:
                    await self.repo.log_content_change(
                        url=log_entry["url"],
                        old_hash=log_entry["old_hash"],
                        new_hash=log_entry["new_hash"],
                        change_type=log_entry["change_type"]
                    )
                await self.repo.disconnect()
                logger.info(f"Successfully logged {len(database_logs)} changes to database")
            
            logger.info(f"Batch processing completed: {len(changes)} changes processed")
            
        except Exception as e:
            logger.error(f"Error in batch processing: {str(e)}")
            raise
    
    def chunk_content(self, content: str, chunk_size: int = 1000) -> List[str]:
        """Split large content into searchable chunks"""
        if not content:
            return []
        
        words = content.split()
        chunks = []
        
        for i in range(0, len(words), chunk_size):
            chunk = ' '.join(words[i:i + chunk_size])
            chunks.append(chunk)
        
        return chunks if chunks else [content]
