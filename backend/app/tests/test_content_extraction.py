import asyncio
import aiohttp
from app.services.web_monitor import GovernmentWebMonitor

async def test_extraction():
    print("Testing content extraction...")
    
    try:
        async with GovernmentWebMonitor() as monitor:
            print("Monitor initialized successfully")
            
            # Test content extraction
            content = await monitor.extract_content("https://dmt.gov.lk/index.php?lang=en")
            
            if content:
                print(f"Content extracted: {len(content)} characters")
                print(f"First 200 chars: {content[:200]}...")
                
                # Test hash generation
                hash_value = monitor.generate_content_hash(content)
                print(f"Hash generated: {hash_value}")
                
                return True
            else:
                print("No content extracted")
                return False
                
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

if __name__ == "__main__":
    result = asyncio.run(test_extraction())
    if result:
        print("Content extraction working!")
    else:
        print("Content extraction failed!")
