import asyncio
from app.services.knowledge_base import KnowledgeBaseService

async def check_chromadb_status():
    print("Checking ChromaDB status...")
    
    try:
        kb_service = KnowledgeBaseService()
        
        # Get collection stats
        stats = kb_service.get_collection_stats()
        print(f"Collection Stats: {stats}")
        
        # Try a simple test query
        results = await kb_service.search("test", 1)
        print(f"Test Search Results: {len(results['documents'][0]) if results['documents'] else 0} documents found")
        
        # Check collection name
        print(f"Collection Name: {kb_service.collection.name}")
        
    except Exception as e:
        print(f"Error checking ChromaDB: {str(e)}")

if __name__ == "__main__":
    asyncio.run(check_chromadb_status())
