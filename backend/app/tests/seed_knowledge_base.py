import asyncio
from app.services.knowledge_base import KnowledgeBaseService

async def seed_knowledge_base():
    print("Seeding knowledge base with initial data...")
    
    try:
        kb_service = KnowledgeBaseService()
        
        # Check if already has data
        stats = kb_service.get_collection_stats()
        if stats['document_count'] > 0:
            print(f"Collection already has {stats['document_count']} documents")
            return
        
        # Sri Lankan government services seed data
        documents = [
            """Department of Motor Traffic (DMT) Services:
            1. Driver's License Renewal: Requires NIC, medical certificate, current license, and payment
            2. Vehicle Registration: Need invoice, customs papers, insurance certificate
            3. Revenue License: Annual renewal required for all vehicles
            4. Driving Test Appointments: Available for new license applicants
            Contact: Head Office at No. 341, Alvitigala Mawatha, Colombo 05
            Phone: +94 112 033333
            Website: dmt.gov.lk""",
            
            """Government Services Online Portal:
            Citizens can access various online services including:
            - E-Services for government applications
            - Appointment booking system
            - Document downloads and applications
            - Status checking for pending applications
            Available 24/7 at gov.lk portal""",
            
            """Transport Ministry Services:
            Ministry of Transport and Civil Aviation provides:
            - Policy guidance for transport sector
            - Coordination with DMT and other transport agencies
            - Infrastructure development oversight
            - Public transport regulation and management
            Website: transport.gov.lk"""
        ]
        
        metadatas = [
            {
                "url": "https://dmt.gov.lk/index.php?lang=en",
                "source_type": "government_website", 
                "title": "DMT Services",
                "department": "Department of Motor Traffic",
                "content_type": "service_info"
            },
            {
                "url": "https://www.gov.lk/services",
                "source_type": "government_website",
                "title": "Government Online Services", 
                "department": "Government Portal",
                "content_type": "service_info"
            },
            {
                "url": "https://www.transport.gov.lk",
                "source_type": "government_website",
                "title": "Transport Ministry",
                "department": "Ministry of Transport", 
                "content_type": "service_info"
            }
        ]
        
        ids = ["seed_dmt_001", "seed_gov_001", "seed_transport_001"]
        
        # Add documents to knowledge base
        result = await kb_service.add_documents(documents, metadatas, ids)
        print(f"Successfully seeded {result['documents_added']} documents")
        
        # Verify seeding worked
        stats = kb_service.get_collection_stats()
        print(f"Collection now has {stats['document_count']} documents")
        
        # Test search
        results = await kb_service.search("Department of Motor Traffic", 2)
        print(f"Test search returned {len(results['documents'][0]) if results['documents'] else 0} results")
        
    except Exception as e:
        print(f"Error seeding knowledge base: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(seed_knowledge_base())
