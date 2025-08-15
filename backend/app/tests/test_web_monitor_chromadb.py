# Update: backend/app/tests/test_web_monitor_chromadb.py
import asyncio
from app.services.web_monitor import GovernmentWebMonitor
from app.services.knowledge_base import KnowledgeBaseService
from app.core.database import connect_db, disconnect_db  # Add these imports

async def test_integration():
    print("Testing web monitor to ChromaDB integration...")
    
    try:
        # ✅ FIX: Initialize database connection for the test
        print("Connecting to database...")
        await connect_db()
        print("Database connected successfully")
        
        # Check ChromaDB before
        kb_service = KnowledgeBaseService()
        stats_before = kb_service.get_collection_stats()
        print(f"ChromaDB documents before: {stats_before['document_count']}")

        # Run web monitoring
        async with GovernmentWebMonitor() as monitor:
            print("Running web monitoring...")
            changes = await monitor.monitor_government_sources()
            print(f"Changes detected: {len(changes)}")

        # Wait a moment for processing
        await asyncio.sleep(2)

        # Check ChromaDB after
        stats_after = kb_service.get_collection_stats()
        print(f"ChromaDB documents after: {stats_after['document_count']}")
        print(f"Documents added: {stats_after['document_count'] - stats_before['document_count']}")

        # Test search with content we know exists
        results = await kb_service.search("DMT government services", 3)
        print(f"Search results: {len(results['documents'][0]) if results['documents'] else 0}")
        
        print("Integration test completed successfully!")
        
    except Exception as e:
        print(f"Test failed with error: {str(e)}")
        import traceback
        traceback.print_exc()
        
    finally:
        # Clean up database connection
        try:
            await disconnect_db()
            print("Database disconnected")
        except Exception as e:
            print(f"Database disconnect error: {str(e)}")

if __name__ == "__main__":
    asyncio.run(test_integration())
