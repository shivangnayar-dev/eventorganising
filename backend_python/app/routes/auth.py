"""
Authentication routes
"""
from fastapi import APIRouter, Request, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
from app.middleware.auth_middleware import get_current_user
from app.services.auth_service import AuthService
from app.utils.refresh_token import find_refresh_token, delete_refresh_token
from app.utils.jwt import sign_token
from app.config.env import settings
from app.models.refresh_token import RefreshToken

router = APIRouter()


# Request/Response models
class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    fullName: str
    phone: Optional[str] = None
    role: Optional[str] = "USER"


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RefreshRequest(BaseModel):
    refreshToken: str


class LogoutRequest(BaseModel):
    refreshToken: Optional[str] = None


class AuthResponse(BaseModel):
    accessToken: str
    refreshToken: str
    expiresIn: str
    refreshTokenExpiresIn: str
    user: dict


# Routes
@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def register(request: Request, data: RegisterRequest):
    """Register a new user"""
    result = await AuthService.register(
        email=data.email,
        password=data.password,
        full_name=data.fullName,
        phone=data.phone,
        role=data.role,
        device_id=request.headers.get("x-device-id"),
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    return result


@router.post("/login", response_model=AuthResponse)
async def login(request: Request, data: LoginRequest):
    """Login user"""
    result = await AuthService.login(
        email=data.email,
        password=data.password,
        device_id=request.headers.get("x-device-id"),
        ip_address=request.client.host if request.client else None,
        user_agent=request.headers.get("user-agent"),
    )
    return result


@router.post("/refresh")
async def refresh(data: RefreshRequest):
    """Refresh access token"""
    if not data.refreshToken:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Refresh token is required",
        )
    
    # Find and validate refresh token
    db_token = await find_refresh_token(data.refreshToken)
    if not db_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
        )
    
    # Load user
    from app.models.user import User, Role
    user = await User.get(db_token.user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    
    # Load user roles
    roles = await Role.find({"userId": str(user.id)}).to_list()
    
    # Generate new access token
    payload = {
        "id": str(user.id),
        "email": user.email,
        "roles": [role.role.value for role in roles],
    }
    access_token = sign_token(payload)
    
    return {
        "accessToken": access_token,
        "expiresIn": settings.jwt_expires_in,
    }


@router.post("/logout")
async def logout(data: LogoutRequest, user: dict = Depends(get_current_user)):
    """Logout user"""
    if data.refreshToken:
        await delete_refresh_token(data.refreshToken)
    
    return {"message": "Logged out successfully"}


@router.get("/profile")
async def get_profile(user: dict = Depends(get_current_user)):
    """Get current user profile"""
    user_obj = await AuthService.get_profile(user["id"])
    return user_obj

