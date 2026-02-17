"""
Authentication middleware
"""
from fastapi import Request, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.utils.jwt import verify_token
from app.config.logger import setup_logger

logger = setup_logger()
security = HTTPBearer()


async def get_current_user(request: Request) -> dict:
    """
    Get current authenticated user from JWT token
    
    Args:
        request: FastAPI request object
    
    Returns:
        User payload from JWT token
    
    Raises:
        HTTPException: If token is invalid or missing
    """
    authorization = request.headers.get("Authorization")
    
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Unauthorized",
        )
    
    token = authorization[7:]  # Remove "Bearer " prefix
    
    try:
        payload = verify_token(token)
        return payload
    except Exception as e:
        logger.debug(f"Token verification failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )


def require_roles(*allowed_roles: str):
    """
    Dependency to require specific roles
    
    Usage:
        @app.get("/admin")
        async def admin_route(user: dict = Depends(require_roles("ADMIN"))):
            ...
    """
    async def role_checker(request: Request) -> dict:
        user = await get_current_user(request)
        user_roles = user.get("roles", [])
        
        # Check if user has any of the allowed roles
        if not any(role.upper() in [r.upper() for r in user_roles] for role in allowed_roles):
            logger.debug(f"Role mismatch: user has {user_roles}, required {allowed_roles}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Forbidden: Insufficient permissions",
            )
        
        return user
    
    return role_checker

