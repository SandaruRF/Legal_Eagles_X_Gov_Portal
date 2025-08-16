# backend/app/core/websocket_manager.py
from fastapi import WebSocket
from typing import Dict, List
import asyncio

class WebSocketManager:
    def _init_(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, citizen_id: str, websocket: WebSocket):
        await websocket.accept()
        if citizen_id not in self.active_connections:
            self.active_connections[citizen_id] = []
        self.active_connections[citizen_id].append(websocket)

    def disconnect(self, citizen_id: str, websocket: WebSocket):
        if citizen_id in self.active_connections:
            self.active_connections[citizen_id].remove(websocket)
            if not self.active_connections[citizen_id]:
                del self.active_connections[citizen_id]

    async def send_personal_message(self, message: dict, citizen_id: str):
        if citizen_id in self.active_connections:
            for connection in self.active_connections[citizen_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    self.disconnect(citizen_id, connection)

    async def broadcast(self, message: dict):
        for citizen_id in self.active_connections:
            await self.send_personal_message(message, citizen_id)

# Create a global instance
websocket_manager = WebSocketManager()