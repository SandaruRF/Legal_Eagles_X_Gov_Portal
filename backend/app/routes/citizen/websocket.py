# backend/app/routes/citizen/websocket.py
from fastapi import WebSocket, WebSocketDisconnect, APIRouter, Depends
from app.core.auth import get_current_user
from app.schemas.citizen import citizen_schema
from app.core.websocket_manager import WebSocketManager

# Create a WebSocket manager instance
websocket_manager = WebSocketManager()

router = APIRouter()

@router.websocket("/ws/notifications")
async def websocket_endpoint(
    websocket: WebSocket,
    current_user: citizen_schema.Citizen = Depends(get_current_user)
):
    """WebSocket endpoint for notifications"""
    try:
        # Accept the connection
        await websocket.accept()
        # Connect to WebSocket manager
        await websocket_manager.connect(current_user.citizen_id, websocket)
        
        while True:
            # Keep the connection alive and handle any incoming messages
            data = await websocket.receive_json()
            if data.get("type") == "ping":
                await websocket.send_json({"type": "pong"})
            
    except WebSocketDisconnect:
        # Handle disconnection
        await websocket_manager.disconnect(current_user.citizen_id)
    except Exception as e:
        print(f"WebSocket error: {str(e)}")
        await websocket_manager.disconnect(current_user.citizen_id)