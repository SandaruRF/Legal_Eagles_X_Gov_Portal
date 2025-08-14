# Update: backend/app/services/knowledge_base.py
import chromadb
import datetime
import hashlib
import logging
from typing import List, Dict, Any, Optional

from app.core.config import get_settings
from app.utils.embeddings import SentenceTransformerEmbeddings  # Fix import path

logger = logging.getLogger(__name__)

class KnowledgeBaseService:
    def __init__(self):
        try:
            settings = get_settings()
            
            # Initialize ChromaDB client with persistent storage
            self.client = chromadb.PersistentClient(path="chroma_storage")
            
            # Use Sentence Transformers for embeddings
            self.embedding_function = SentenceTransformerEmbeddings(
                model_name="paraphrase-multilingual-MiniLM-L12-v2"
            )
            
            # Create or get collection with metadata
            self.collection = self.client.get_or_create_collection(
                name=settings.CHROMADB_COLLECTION_NAME,
                embedding_function=self.embedding_function,
                metadata={"hnsw:space": "cosine"}
            )
            
            logger.info(f"ChromaDB collection '{settings.CHROMADB_COLLECTION_NAME}' initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize KnowledgeBaseService: {str(e)}")
            raise RuntimeError(f"ChromaDB initialization failed: {str(e)}")
    
    async def search(self, query: str, limit: int = 5):
        """Search government services using natural language with error handling"""
        try:
            if not query or not query.strip():
                logger.warning("Empty query provided")
                return {'documents': [[]], 'metadatas': [[]], 'distances': [[]]}
                
            if limit <= 0:
                limit = 5
            elif limit > 100:
                limit = 100
                
            results = self.collection.query(
                query_texts=[query],
                n_results=limit
            )
            
            if not results or not results.get('documents') or not results['documents'][0]:
                logger.warning(f"No results found for query: {query}")
                return {'documents': [[]], 'metadatas': [[]], 'distances': [[]]}
                
            logger.info(f"Found {len(results['documents'][0])} results for query: {query[:50]}...")
            return results
            
        except Exception as e:
            logger.error(f"Error in ChromaDB search for query '{query[:50]}': {str(e)}")
            return {'documents': [[]], 'metadatas': [[]], 'distances': [[]]}
    
    async def add_documents(self, documents: List[str], metadatas: List[Dict], ids: List[str]):
        """Add new documents to knowledge base with comprehensive error handling"""
        try:
            if not documents or not metadatas or not ids:
                raise ValueError("Documents, metadatas, and ids cannot be empty")
            
            if len(documents) != len(metadatas) or len(documents) != len(ids):
                raise ValueError("Documents, metadatas, and ids must have the same length")
            
            self.collection.add(
                documents=documents,
                metadatas=metadatas,
                ids=ids
            )
            
            logger.info(f"Successfully added {len(documents)} documents to knowledge base")
            return {
                "status": "success",
                "documents_added": len(documents),
                "ids": ids
            }
            
        except Exception as e:
            logger.error(f"Error adding documents to knowledge base: {str(e)}")
            if "already exists" in str(e).lower():
                raise ValueError(f"Some document IDs already exist. Use upsert instead of add.")
            else:
                raise RuntimeError(f"Failed to add documents to ChromaDB: {str(e)}")
    
    async def store_webpage_content(self, url: str, content: str, timestamp: datetime.datetime):
        """Store scraped webpage content with comprehensive error handling"""
        try:
            if not url or not content:
                raise ValueError("URL and content cannot be empty")
            
            if len(content.strip()) < 50:
                logger.warning(f"Content for {url} is very short ({len(content)} chars)")
            
            # Generate a unique ID for the document
            doc_id = f"webpage_{hashlib.sha256(url.encode()).hexdigest()}"
            
            # Create metadata for the document
            metadata = {
                "url": url,
                "source_type": "government_website",
                "last_updated": timestamp.isoformat(),
                "content_type": "webpage",
                "content_length": len(content)
            }
            
            # Add or update the document in ChromaDB
            self.collection.upsert(
                documents=[content],
                metadatas=[metadata],
                ids=[doc_id]
            )
            
            logger.info(f"Successfully stored webpage content: {url} ({len(content)} chars)")
            return doc_id
            
        except Exception as e:
            logger.error(f"Error storing webpage content for {url}: {str(e)}")
            raise RuntimeError(f"Failed to store webpage content: {str(e)}")
    
    def get_collection_stats(self) -> Dict[str, Any]:
        """Get statistics about the ChromaDB collection"""
        try:
            count = self.collection.count()
            return {
                "document_count": count,
                "collection_name": self.collection.name,
                "status": "healthy"
            }
        except Exception as e:
            logger.error(f"Error getting collection stats: {str(e)}")
            return {
                "document_count": 0,
                "collection_name": "unknown",
                "status": "error",
                "error": str(e)
            }
