from contextlib import asynccontextmanager
import logging

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1.telemetry import router as telemetry_router
from app.core.database import close_db_engine
from app.core.gzip_middleware import GzipRequestMiddleware

logger = logging.getLogger("agentlens.main")


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

# Custom Gzip and Payload Size middleware
app.add_middleware(GzipRequestMiddleware)

# CORS Middleware
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


# RFC 7807 Problem Details Exception Handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Formats HTTP exceptions as RFC 7807 Problem Details."""
    status_titles = {
        400: "Bad Request",
        401: "Unauthorized",
        403: "Forbidden",
        404: "Not Found",
        413: "Payload Too Large",
        422: "Unprocessable Entity",
        500: "Internal Server Error",
    }
    title = status_titles.get(exc.status_code, "HTTP Error")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "type": f"https://agentlens.dev/errors/{title.lower().replace(' ', '-')}",
            "title": title,
            "status": exc.status_code,
            "detail": exc.detail if isinstance(exc.detail, str) else str(exc.detail),
            "instance": request.url.path,
        },
        headers=getattr(exc, "headers", None),
        media_type="application/problem+json",
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """Formats Pydantic validation errors as RFC 7807 Problem Details."""
    errors = exc.errors()
    error_messages = [f"{'.'.join(str(loc) for loc in err['loc'])}: {err['msg']}" for err in errors]
    detail = "; ".join(error_messages)

    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "type": "https://agentlens.dev/errors/validation-failed",
            "title": "Invalid Telemetry Batch",
            "status": status.HTTP_422_UNPROCESSABLE_ENTITY,
            "detail": detail,
            "instance": request.url.path,
        },
        media_type="application/problem+json",
    )


# Routers
app.include_router(telemetry_router, prefix="/api/v1/telemetry")


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
