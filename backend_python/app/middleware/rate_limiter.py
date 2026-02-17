"""
Rate limiting middleware
"""
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request, status
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from app.config.env import settings

# Create rate limiter
limiter = Limiter(key_func=get_remote_address)

# Default rate limit (applied to all routes)
default_limit = f"{settings.rate_limit_max}/{settings.rate_limit_window_ms // 1000}seconds"

# Auth rate limit (stricter)
auth_limit = f"5/{settings.rate_limit_window_ms // 1000}seconds"


class RateLimiterMiddleware(BaseHTTPMiddleware):
    """Rate limiting middleware"""
    
    async def dispatch(self, request: Request, call_next):
        """Apply rate limiting"""
        try:
            response = await call_next(request)
            return response
        except RateLimitExceeded as e:
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={"error": "Too many requests", "message": str(e)},
            )

