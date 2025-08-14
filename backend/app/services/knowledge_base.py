import chromadb
import datetime
import hashlib
from chromadb.config import Settings
from app.core.config import get_settings
from app.utils.embeddings import SentenceTransformerEmbeddings

class KnowledgeBaseService:
    def __init__(self):
        settings = get_settings()
        
        # Initialize ChromaDB client with persistent storage
        self.client = chromadb.PersistentClient(path="chroma_storage")
        
        # Use Sentence Transformers for embeddings
        self.embedding_function = SentenceTransformerEmbeddings(
            model_name="paraphrase-multilingual-MiniLM-L12-v2"  # This model supports multiple languages
        )
        
        # Create or get collection with metadata
        self.collection = self.client.get_or_create_collection(
            name="government_services",
            embedding_function=self.embedding_function,
            metadata={"hnsw:space": "cosine"}  # Use cosine similarity for better matching
        )
        
        # Create or get the collection with the embedding function
        self.collection = self.client.get_or_create_collection(
            name=settings.CHROMADB_COLLECTION_NAME,
            embedding_function=self.embedding_function
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
    
    async def store_webpage_content(self, url: str, content: str, timestamp: datetime):
        """Store scraped webpage content in the vector database"""
        # Generate a unique ID for the document
        doc_id = f"webpage_{hashlib.sha256(url.encode()).hexdigest()}"
        
        # Create metadata for the document
        metadata = {
            "url": url,
            "source_type": "government_website",
            "last_updated": timestamp.isoformat(),
            "content_type": "webpage"
        }
        
        # Add or update the document in ChromaDB
        self.collection.upsert(
            documents=[content],
            metadatas=[metadata],
            ids=[doc_id]
        )
        
        return doc_id
