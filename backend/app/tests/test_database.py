import asyncio
from app.db.repositories.web_monitor import WebMonitorRepository

async def test_database():
    print("Testing database connection...")
    
    repo = WebMonitorRepository()
    
    try:
        # Test connection
        await repo.connect()
        print("Database connected successfully")
        
        # Test query
        result = await repo.get_url_record("test-url")
        print(f"Database query successful: {result}")
        
        # Test disconnect
        await repo.disconnect()
        print("Database disconnected successfully")
        
        return True
        
    except Exception as e:
        print(f"Database error: {str(e)}")
        return False

if __name__ == "__main__":
    result = asyncio.run(test_database())
    if result:
        print("Database connection working!")
    else:
        print("Database connection failed!")
