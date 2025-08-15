from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.database import connect_db, disconnect_db

# --- Routers ---
from .routes.citizen import citizen_route
from .routes.citizen import citizen_kyc_route
from .routes.citizen import digital_vault_route
from .routes.citizen import feedback as citizen_feedback_route
from .routes.admin import feedback_summary as admin_feedback_route  
from .routes.admin import admin_route

from .routes.admin import department_route
from .routes.admin import appointment_route
from .routes.admin import feedback_route
from .routes.admin import dashboard_route
from .routes.admin import analytics_route
from .routes import web_monitor
from .routes import knowledge_base
from app.routes.citizen.appointment_route import router as appointment_router
from app.routes.citizen.form_route import router as form_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_db()
    yield
    await disconnect_db()



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

# ✅ Register API routers
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

app.include_router(web_monitor.router, prefix="/api")
app.include_router(knowledge_base.router, prefix="/api")
app.include_router(appointment_router, prefix="/api")
app.include_router(form_router, prefix="/api")
app.include_router(digital_vault_route.router, prefix="/api")
app.include_router(citizen_feedback_route.router, prefix="/api/citizen/feedback")
app.include_router(admin_feedback_route.router, prefix="/api/admin/feedback")
 


@app.get("/", tags=["Health Check"])
async def root():
    return {"status": "ok", "message": "Welcome to the Gov-Portal API"}
