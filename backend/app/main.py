from contextlib import asynccontextmanager
from fastapi import FastAPI
from .core.database import connect_db, disconnect_db

# --- Routers ---
from .routes.citizen import citizen_route
from .routes.citizen import citizen_kyc_route
from .routes.citizen import digital_vault_route

from .routes.citizen import feedback   
from .routes.admin import admin_route


@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_db()
    yield
    await disconnect_db()


app = FastAPI(
    title="Gov-Portal API",
    description="The official backend API for the Gov-Portal government service portal.",
    version="1.0.0",
    lifespan=lifespan
)

# ✅ Register API routers
app.include_router(citizen_route.router, prefix="/api")
app.include_router(admin_route.router, prefix="/api")
app.include_router(citizen_kyc_route.router, prefix="/api")
app.include_router(digital_vault_route.router, prefix="/api")
app.include_router(feedback.router, prefix="/api")  

@app.get("/", tags=["Health Check"])
async def root():
    return {"status": "ok", "message": "Welcome to the Gov-Portal API"}
