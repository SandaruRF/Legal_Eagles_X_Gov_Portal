# app/core/database.py

from prisma import Prisma

# Create a single, global instance of the Prisma client
# This instance will be reused across the application
db = Prisma(auto_register=True)

async def connect_db():
    """
    Connects to the Prisma database client.
    This should be called when the FastAPI application starts up.
    """
    print("Connecting to the database...")
    await db.connect()
    print("Database connection successful.")

async def disconnect_db():
    """
    Disconnects from the Prisma database client.
    This should be called when the FastAPI application shuts down.
    """
    print("Disconnecting from the database...")
    await db.disconnect()
    print("Database connection closed.")

def get_db() -> Prisma:
    """
    Returns the global Prisma client instance.
    This function can be used as a FastAPI dependency to ensure
    that the database client is available in the request context.
    """
    return db
