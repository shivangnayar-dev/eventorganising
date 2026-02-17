"""
Error handling middleware
"""
from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from app.config.logger import setup_logger

logger = setup_logger()


class HttpError(Exception):
    """Custom HTTP error exception"""
    def __init__(self, status_code: int, message: str):
        self.status_code = status_code
        self.message = message
        super().__init__(self.message)


async def error_handler(request: Request, exc: Exception) -> JSONResponse:
    """Global error handler"""
    
    # Handle validation errors
    if isinstance(exc, RequestValidationError):
        logger.debug(f"Validation error: {exc.errors()}")
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "error": "Validation error",
                "details": exc.errors(),
            },
        )
    
    # Handle HTTP exceptions
    if isinstance(exc, StarletteHTTPException):
        status_code = exc.status_code
        message = exc.detail
        
        # Log 401/403 at debug level (expected for RBAC)
        if status_code in [401, 403]:
            logger.debug(f"HTTP {status_code}: {message}")
        else:
            logger.error(f"HTTP {status_code}: {message}")
        
        return JSONResponse(
            status_code=status_code,
            content={"error": message},
        )
    
    # Handle custom HttpError
    if isinstance(exc, HttpError):
        if exc.status_code in [401, 403]:
            logger.debug(f"HTTP {exc.status_code}: {exc.message}")
        else:
            logger.error(f"HTTP {exc.status_code}: {exc.message}")
        
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": exc.message},
        )
    
    # Handle unexpected errors
    logger.error(f"Unhandled error: {exc}", exc_info=True)
    from app.config.env import settings
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "Internal server error",
            "message": str(exc) if settings.environment == "development" else "An unexpected error occurred",
        },
    )

