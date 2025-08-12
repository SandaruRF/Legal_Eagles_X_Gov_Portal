import chromadb
from chromadb.config import Settings
from app.core.config import get_settings

class KnowledgeBaseService:
    def __init__(self):
        settings = get_settings()
        self.client = chromadb.Client()
        self.collection = self.client.get_or_create_collection(
            name=settings.CHROMADB_COLLECTION_NAME
        )
    
    async def search(self, query: str, limit: int = 5):
        """Search government services using natural language"""
        results = self.collection.query(
            query_texts=[query],
            n_results=limit
        )
        return results
    
    async def add_documents(self, documents, metadatas, ids):
        """Add new documents to knowledge base"""
        self.collection.add(
            documents=documents,
            metadatas=metadatas,
            ids=ids
        )
