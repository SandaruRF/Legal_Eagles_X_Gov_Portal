import chromadb
from chromadb.config import Settings
import json
from pathlib import Path
import logging
from datetime import datetime
from typing import Dict, List, Any
import hashlib

from app.core.config import get_settings
from app.utils.embeddings import SentenceTransformerEmbeddings
from app.services.knowledge_base import KnowledgeBaseService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChromaDataLoader:
    def __init__(self):
        settings = get_settings()
        
        # Initialize ChromaDB client
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
        
        # Create or get the collection
        self.collection = self.client.get_or_create_collection(
            name="government_services",
            embedding_function=self.embedding_function
        )
        
        self.scraped_data_path = Path(__file__).parent.parent / 'scraped_data'
    
    def _generate_document_id(self, content: str, url: str) -> str:
        """Generate a unique ID for a document"""
        unique_string = f"{url}_{content}"
        return hashlib.sha256(unique_string.encode()).hexdigest()
    
    def _prepare_text_chunk(self, content: Dict[str, Any], parent_url: str = "") -> List[Dict]:
        """Prepare text chunks from content for embedding"""
        chunks = []
        
        # Process main content
        if content.get('main_content'):
            chunks.append({
                'text': content['main_content'],
                'url': content['url'],
                'type': 'main_content',
                'title': content.get('title', ''),
                'parent_url': parent_url
            })
        
        # Process sections
        for section in content.get('sections', []):
            if section.get('content'):
                chunks.append({
                    'text': f"{section.get('heading', '')}\n{section['content']}",
                    'url': content['url'],
                    'type': 'section',
                    'title': section.get('heading', ''),
                    'parent_url': parent_url
                })
        
        # Process tables
        for table in content.get('tables', []):
            table_text = ""
            if table.get('headers'):
                table_text += " | ".join(table['headers']) + "\n"
            for row in table.get('rows', []):
                table_text += " | ".join(str(cell) for cell in row) + "\n"
            
            if table_text:
                chunks.append({
                    'text': table_text,
                    'url': content['url'],
                    'type': 'table',
                    'title': content.get('title', ''),
                    'parent_url': parent_url
                })
        
        # Process forms
        for form in content.get('forms', []):
            form_text = f"Form Action: {form.get('action', '')}\n"
            for input_field in form.get('inputs', []):
                form_text += f"Field: {input_field.get('name', '')} ({input_field.get('type', '')})\n"
            
            chunks.append({
                'text': form_text,
                'url': content['url'],
                'type': 'form',
                'title': 'Form: ' + content.get('title', ''),
                'parent_url': parent_url
            })
        
        return chunks
    
    def load_scraped_data(self):
        """Load scraped data from JSON files into ChromaDB"""
        try:
            # Get all JSON files in the scraped_data directory
            json_files = list(self.scraped_data_path.glob('*.json'))
            logger.info(f"Found {len(json_files)} JSON files to process")
            
            for json_file in json_files:
                logger.info(f"Processing {json_file.name}")
                
                with open(json_file, 'r', encoding='utf-8') as f:
                    content = json.load(f)
                
                # Process the content recursively
                self._process_content(content)
                
            logger.info("Completed loading data into ChromaDB")
            
        except Exception as e:
            logger.error(f"Error loading data into ChromaDB: {str(e)}")
            raise
    
    async def _process_content(self, content: Dict[str, Any], parent_url: str = ""):
        """Process content and batch add to ChromaDB"""
        chunks = self._prepare_text_chunk(content, parent_url)
        
        # Prepare batch data
        documents = []
        metadatas = []
        ids = []
        
        for chunk in chunks:
            doc_id = self._generate_document_id(chunk['text'], chunk['url'])
            metadata = {
                'url': chunk['url'],
                'type': chunk['type'],
                'title': chunk['title'],
                'parent_url': chunk['parent_url'],
                'timestamp': datetime.utcnow().isoformat()
            }
            
            documents.append(chunk['text'])
            metadatas.append(metadata)
            ids.append(doc_id)
        
        # USE add_documents() for bulk insertion
        if documents: 
            kb_service = KnowledgeBaseService()
            await kb_service.add_documents(documents, metadatas, ids)
    
    def query_similar_content(self, query_text: str, n_results: int = 5) -> List[Dict]:
        """Query ChromaDB for similar content"""
        results = self.collection.query(
            query_texts=[query_text],
            n_results=n_results
        )
        
        return [
            {
                'text': doc,
                'metadata': metadata,
                'distance': distance
            }
            for doc, metadata, distance in zip(
                results['documents'][0],
                results['metadatas'][0],
                results['distances'][0]
            )
        ]

def main():
    loader = ChromaDataLoader()
    loader.load_scraped_data()
    
    # Test query
    test_query = "How do I renew my driver's license?"
    results = loader.query_similar_content(test_query)
    
    print(f"\nTest Query: {test_query}")
    for i, result in enumerate(results, 1):
        print(f"\nResult {i}:")
        print(f"URL: {result['metadata']['url']}")
        print(f"Type: {result['metadata']['type']}")
        print(f"Title: {result['metadata']['title']}")
        print(f"Relevance Score: {1 - result['distance']:.2f}")
        print(f"Content Preview: {result['text'][:200]}...")

if __name__ == "__main__":
    main()
