from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.database import connect_db, disconnect_db
import asyncio
from fastapi import status


# --- Routers ---
from .routes.citizen import citizen_route
from .routes.citizen import citizen_kyc_route
from .routes.citizen import digital_vault_route
from .routes.citizen import feedback as citizen_feedback_route
from .routes.admin import feedback_summary as admin_feedback_route  
from .routes.admin import admin_route
from .routes.citizen import notification_route, websocket
import asyncio
from fastapi import status

from fastapi import WebSocket, WebSocketDisconnect
from app.core.websocket_manager import websocket_manager
from app.core.auth import get_current_user_ws
from app.schemas.citizen import citizen_schema

from .routes.admin import department_route
from .routes.admin import appointment_route
from .routes.admin import feedback_route
from .routes.admin import dashboard_route
from .routes.admin import analytics_route
from .routes.admin import service_route
from .routes.admin import kyc_verification_admin_route
from .routes import web_monitor
from .routes import knowledge_base
from app.routes.citizen.appointment_route import router as appointment_router
from app.routes.citizen.form_route import router as form_router
from app.routes.citizen.search_route import router as search_router
from app.routes.citizen.notifications import router as notification_router
from app.services.citizen.appointment_reminder import appointment_reminder_worker
from app.services.citizen.appointment_status_monitor import appointment_status_monitor
from app.services.citizen.document_expiry_monitor import document_expiry_monitor

@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_db()
    asyncio.create_task(appointment_reminder_worker())
    asyncio.create_task(appointment_status_monitor())
    asyncio.create_task(document_expiry_monitor())
    yield
    await disconnect_db()



app = FastAPI(
    title="Gov-Portal API",
    description="The official backend API for the Gov-Portal government service portal.",
    version="1.0.0",
    lifespan=lifespan,
)

# --- API Routers ---
app.include_router(citizen_route.router, prefix="/api")
app.include_router(admin_route.router, prefix="/api")
app.include_router(citizen_kyc_route.router, prefix="/api")
app.include_router(notification_route.router, prefix="/api")
app.include_router(websocket.router, prefix="/api")


app.include_router(notification_router, prefix="/api")


app.include_router(department_route.router, prefix="/api")
app.include_router(
    appointment_route.router, prefix="/api/appointments", tags=["Appointments"]
)
app.include_router(feedback_route.router, prefix="/api/admin", tags=["Feedback"])
app.include_router(
    dashboard_route.router, prefix="/api/admin/dashboard", tags=["Dashboard"]
)
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
async def websocket_notifications(
    websocket: WebSocket,
    token: str
):
    """WebSocket endpoint for real-time notifications"""
    try:
        # Authenticate user
        user = await get_current_user_ws(token)
        if not user:
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
            return
        
        # Connect to WebSocket manager
        await websocket_manager.connect(user.citizen_id, websocket)
        
        # Keep connection alive
        while True:
            await websocket.receive_text()
            
    except WebSocketDisconnect:
        websocket_manager.disconnect(user.citizen_id, websocket)
    except Exception as e:
        try:
            await websocket.close(code=status.WS_1011_INTERNAL_ERROR)
        except:
            pass
        websocket_manager.disconnect(user.citizen_id,websocket)