from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import close_db_engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup initialization
    yield
    # Shutdown: Cleanly dispose async database connection pool
    await close_db_engine()

app = FastAPI(
    title="AgentLens API",
    description="AI Agent Observability and Failure Debugging Platform",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:4173",
        "http://localhost:4174",
        "http://localhost:4175",
        "http://127.0.0.1:4173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "Welcome to AgentLens API",
        "status": "running",
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "AgentLens Backend",
        "version": "0.1.0",
    }
