# backend/app/routes/notification/websocket.py
from fastapi import WebSocket, WebSocketDisconnect, Depends
from fastapi import APIRouter
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from app.core.notification_manager import notification_manager

router = APIRouter()

@router.websocket("/ws/notifications")
async def websocket_endpoint(
    websocket: WebSocket,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    await notification_manager.connect(current_user.citizen_id, websocket)
    try:
        while True:
            # Keep connection alive
            await websocket.receive_text()
    except WebSocketDisconnect:
        notification_manager.disconnect(current_user.citizen_id)