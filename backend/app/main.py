from contextlib import asynccontextmanager
from fastapi import FastAPI
from .core.database import connect_db, disconnect_db

from .routes.citizen import citizen_route


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Context manager for FastAPI application lifespan events.
    """
    # Code to be executed before the application starts
    await connect_db()
    yield
    # Code to be executed after the application stops
    await disconnect_db()

# Create the FastAPI app instance with the lifespan manager
app = FastAPI(
    title="Gov-Portal API",
    description="The official backend API for the Gov-Portal government service portal.",
    version="1.0.0",
    lifespan=lifespan
)

# --- API Routers ---
app.include_router(citizen_route.router, prefix="/api")

# A simple root endpoint for health checks
@app.get("/", tags=["Health Check"])
async def root():
    """
    A simple health check endpoint to confirm the API is running.
    """
    return {"status": "ok", "message": "Welcome to the Gov-Portal API"}
