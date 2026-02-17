"""
FastAPI application entry point
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
import uvicorn

from app.config.env import settings
from app.config.logger import setup_logger
from app.database.connection import init_db, close_db
from app.middleware.error_handler import error_handler
from app.middleware.rate_limiter import RateLimiterMiddleware
from app.routes import auth, service, booking, verification, admin

logger = setup_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    # Startup
    logger.info("Starting application...")
    try:
        await init_db()
        logger.info("Database connected successfully")
    except Exception as e:
        logger.error(f"Failed to initialize database during startup: {e}", exc_info=True)
        # Don't raise - let the app start but endpoints will fail gracefully
        pass
    yield
    # Shutdown
    logger.info("Shutting down application...")
    try:
        await close_db()
        logger.info("Database connection closed")
    except Exception as e:
        logger.error(f"Error during shutdown: {e}")


# Create FastAPI app
app = FastAPI(
    title="Event Organising API",
    description="Backend API for Event Organising Application",
    version="1.0.0",
    lifespan=lifespan,
)

# Security middleware - CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins if settings.environment == "production" else ["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

# Compression middleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Rate limiting middleware
app.add_middleware(RateLimiterMiddleware)

# Error handlers - register specific types only
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from app.middleware.error_handler import HttpError

app.add_exception_handler(RequestValidationError, error_handler)
app.add_exception_handler(StarletteHTTPException, error_handler)
app.add_exception_handler(HttpError, error_handler)
app.add_exception_handler(Exception, error_handler)  # Catch all unhandled exceptions


# Simple test endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Event Organising API", "status": "running"}

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        from datetime import datetime
        from app.database.connection import client
        
        # Test database connection
        if client is None:
            return JSONResponse(
                status_code=503,
                content={
                    "status": "error",
                    "timestamp": datetime.utcnow().isoformat(),
                    "database": "not_initialized",
                },
            )
        
        await client.admin.command("ping")
        return {
            "status": "ok",
            "timestamp": datetime.utcnow().isoformat(),
            "environment": settings.environment,
            "database": "connected",
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}", exc_info=True)
        from datetime import datetime
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "timestamp": datetime.utcnow().isoformat(),
                "database": "disconnected",
                "error": str(e) if settings.environment == "development" else None,
            },
        )


# Register routes
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(service.router, prefix="/service", tags=["service"])
app.include_router(verification.router, prefix="/service", tags=["verification"])
app.include_router(booking.router, prefix="/booking", tags=["booking"])
app.include_router(admin.router, prefix="/admin", tags=["admin"])


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.port,
        reload=settings.environment == "development",
        log_level="info" if settings.environment == "production" else "debug",
    )

