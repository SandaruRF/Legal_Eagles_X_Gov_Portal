import pytest
import asyncio
from app.services.web_monitor import GovernmentWebMonitor
from app.services.knowledge_base import KnowledgeBaseService
from app.services.document_processor import DocumentProcessor

async def test_complete_flow():
    """Test the complete integration flow"""
    
    # 1. Test web monitoring
    async with GovernmentWebMonitor() as monitor:
        changes = await monitor.monitor_government_sources()
        print(f"✅ Web monitoring detected {len(changes)} changes")
    
    # 2. Test knowledge base search
    kb_service = KnowledgeBaseService()
    results = await kb_service.search("driver license renewal", 3)
    print(f"✅ Knowledge base search returned {len(results['documents'][0]) if results['documents'] else 0} results")
    
    # 3. Test document processing
    if changes:
        processor = DocumentProcessor()
        for change in changes[:1]:  # Test with first change
            await processor.process_content_change(change)
        print("✅ Document processing completed")
    
    print("🎉 Complete integration test passed!")

# Run with: python -m pytest backend/app/tests/test_knowledge_integration.py -v
