#!/usr/bin/env python3
"""
FastAPI application runner
"""
import uvicorn
from app.config.env import settings

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=settings.port,
        reload=settings.environment == "development",
        log_level="info" if settings.environment == "production" else "debug",
    )

