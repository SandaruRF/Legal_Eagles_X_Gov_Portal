from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.database import connect_db, disconnect_db

from .routes.citizen import citizen_route
from .routes.citizen import citizen_kyc_route

from .routes.admin import admin_route
from .routes.admin import department_route
from .routes.admin import appointment_route
from .routes.admin import feedback_route
from .routes.admin import dashboard_route
from .routes.admin import analytics_route


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
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- API Routers ---
app.include_router(citizen_route.router, prefix="/api")
app.include_router(admin_route.router, prefix="/api")
app.include_router(citizen_kyc_route.router, prefix="/api")
app.include_router(department_route.router, prefix="/api")
app.include_router(
    appointment_route.router, prefix="/api/appointments", tags=["Appointments"]
)
app.include_router(feedback_route.router, prefix="/api/admin", tags=["Feedback"])
app.include_router(
    dashboard_route.router, prefix="/api/admin/dashboard", tags=["Dashboard"]
)
app.include_router(analytics_route.router, prefix="/api/admin", tags=["Analytics"])


# A simple root endpoint for health checks
@app.get("/", tags=["Health Check"])
async def root():
    """
    A simple health check endpoint to confirm the API is running.
    """
    return {"status": "ok", "message": "Welcome to the Gov-Portal API"}
