from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import asyncio
import logging
from typing import List

# Configure logging
logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Database
from app.core.database import connect_db, disconnect_db

# Routers
from app.routes.citizen import citizen_route
from app.routes.citizen import citizen_kyc_route
from app.routes.citizen import digital_vault_route
from app.routes.citizen import feedback as citizen_feedback_route
from app.routes.admin import feedback_summary as admin_feedback_route
from app.routes.admin import admin_route
from app.routes.admin import department_route
from app.routes.admin import appointment_route
from app.routes.admin import feedback_route
from app.routes.admin import dashboard_route
from app.routes.admin import analytics_route
from app.routes.admin import service_route
from app.routes.admin import kyc_verification_admin_route
from app.routes import web_monitor
from app.routes import knowledge_base
from app.routes.citizen.appointment_route import router as appointment_router
from app.routes.citizen.form_route import router as form_router
from app.routes.citizen.search_route import router as search_router
from app.routes.citizen.notifications import router as notification_router

# Workers
from app.services.citizen.appointment_reminder import appointment_reminder_worker
from app.services.citizen.appointment_status_monitor import appointment_status_monitor
from app.services.citizen.document_expiry_monitor import document_expiry_monitor

# WebSocket
from app.core.websocket_manager import websocket_manager
from app.core.auth import get_current_user_ws
from app.schemas.citizen import citizen_schema

class WorkerManager:
    def __init__(self):
        self.tasks: List[asyncio.Task] = []
        self.should_stop = False

    async def run_worker(self, name, worker_func):
        """Run a worker with automatic retry on failure"""
        logger.info(f"Starting {name} worker")
        while not self.should_stop:
            try:
                await worker_func()
            except asyncio.CancelledError:
                logger.info(f"{name} worker cancelled")
                break
            except Exception as e:
                logger.error(f"{name} worker failed: {str(e)}")
                await asyncio.sleep(10)  # Wait before restarting

    async def stop_all(self):
        """Stop all workers gracefully"""
        self.should_stop = True
        for task in self.tasks:
            task.cancel()
            try:
                await task
            except asyncio.CancelledError:
                pass

worker_manager = WorkerManager()

@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        # Connect to database
        logger.info("Connecting to database...")
        await connect_db()
        logger.info("Database connected successfully")

        # Start background workers
        worker_manager.tasks = [
            asyncio.create_task(worker_manager.run_worker("Appointment Reminder", appointment_reminder_worker)),
            asyncio.create_task(worker_manager.run_worker("Status Monitor", appointment_status_monitor)),
            asyncio.create_task(worker_manager.run_worker("Document Expiry", document_expiry_monitor))
        ]

        yield

    except Exception as e:
        logger.error(f"Application startup failed: {str(e)}")
        raise
    finally:
        # Cleanup
        logger.info("Shutting down workers...")
        await worker_manager.stop_all()
        
        logger.info("Disconnecting from database...")
        await disconnect_db()
        logger.info("Shutdown complete")

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

# Static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# API routers
app.include_router(citizen_route.router, prefix="/api")
app.include_router(admin_route.router, prefix="/api")
app.include_router(citizen_kyc_route.router, prefix="/api")
app.include_router(notification_router, prefix="/api")
app.include_router(department_route.router, prefix="/api")
app.include_router(appointment_route.router, prefix="/api/appointments", tags=["Appointments"])
app.include_router(feedback_route.router, prefix="/api/admin", tags=["Feedback"])
app.include_router(dashboard_route.router, prefix="/api/admin/dashboard", tags=["Dashboard"])
app.include_router(analytics_route.router, prefix="/api/admin", tags=["Analytics"])
app.include_router(service_route.router, prefix="/api", tags=["Services"])
app.include_router(kyc_verification_admin_route.router, prefix="/api")
app.include_router(web_monitor.router, prefix="/api")
app.include_router(knowledge_base.router, prefix="/api")
app.include_router(appointment_router, prefix="/api")
app.include_router(form_router, prefix="/api")
app.include_router(digital_vault_route.router, prefix="/api")
app.include_router(citizen_feedback_route.router, prefix="/api/citizen/feedback")
app.include_router(admin_feedback_route.router, prefix="/api/admin/feedback")
app.include_router(search_router, prefix="/api")

@app.get("/", tags=["Health Check"])
async def root():
    return {"status": "ok", "message": "Welcome to the Gov-Portal API"}

@app.websocket("/ws/notifications")
async def websocket_notifications(websocket: WebSocket, token: str):
    """WebSocket endpoint for real-time notifications"""
    try:
        # Authenticate user
        user = await get_current_user_ws(token)
        if not user:
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
            return
        
        # Connect to WebSocket manager
        await websocket_manager.connect(user.citizen_id, websocket)
        logger.info(f"WebSocket connected for user {user.citizen_id}")
        
        # Keep connection alive
        while True:
            await websocket.receive_text()
            
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for user {user.citizen_id}")
        websocket_manager.disconnect(user.citizen_id, websocket)
    except Exception as e:
        logger.error(f"WebSocket error: {str(e)}")
        try:
            await websocket.close(code=status.WS_1011_INTERNAL_ERROR)
        except:
            pass
        if 'user' in locals():
            websocket_manager.disconnect(user.citizen_id, websocket)