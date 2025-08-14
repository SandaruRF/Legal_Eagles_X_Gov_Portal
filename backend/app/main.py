from contextlib import asynccontextmanager
from fastapi import FastAPI
from .core.database import connect_db, disconnect_db

from .routes.citizen import citizen_route
from .routes.citizen import citizen_kyc_route
from .routes.citizen import digital_vault_route

from .routes.admin import admin_route
from .routes import web_monitor
from .routes import knowledge_base
from app.routes.citizen.appointment_route import router as appointment_router
from app.routes.citizen.form_route import router as form_router


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
app.include_router(admin_route.router, prefix="/api")
app.include_router(citizen_kyc_route.router, prefix="/api")
app.include_router(web_monitor.router, prefix="/api")
app.include_router(knowledge_base.router, prefix="/api")
app.include_router(appointment_router, prefix="/api")
app.include_router(form_router, prefix="/api")
app.include_router(digital_vault_route.router, prefix="/api")

# A simple root endpoint for health checks
@app.get("/", tags=["Health Check"])
async def root():
    """
    A simple health check endpoint to confirm the API is running.
    """
    return {"status": "ok", "message": "Welcome to the Gov-Portal API"}
