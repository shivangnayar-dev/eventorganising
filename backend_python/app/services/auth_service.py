"""
Authentication service
"""
from typing import Optional
from app.models.user import User, Role, UserRole
from app.utils.password import hash_password, verify_password
from app.utils.jwt import sign_token
from app.utils.refresh_token import generate_refresh_token, create_refresh_token
from app.middleware.error_handler import HttpError
from app.config.env import settings


class AuthService:
    """Authentication service"""
    
    @staticmethod
    async def register(
        email: str,
        password: str,
        full_name: str,
        phone: Optional[str] = None,
        role: str = "USER",
        device_id: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> dict:
        """Register a new user"""
        # Check if user exists
        existing_user = await User.find_one({"email": email})
        if existing_user:
            raise HttpError(409, "Email already registered")
        
        # Hash password
        password_hash = hash_password(password)
        user_role = UserRole(role) if role in ["USER", "PROVIDER"] else UserRole.USER
        
        # Create user
        user = User(
            email=email,
            passwordHash=password_hash,
            fullName=full_name,
            phone=phone,
        )
        await user.insert()
        
        # Create role
        role_obj = Role(role=user_role, userId=str(user.id))
        await role_obj.insert()
        
        # Generate refresh token
        refresh_token = generate_refresh_token()
        await create_refresh_token(
            user_id=str(user.id),
            token=refresh_token,
            device_id=device_id,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        
        return await AuthService._build_auth_response(user, refresh_token)
    
    @staticmethod
    async def login(
        email: str,
        password: str,
        device_id: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> dict:
        """Login user"""
        # Find user
        user = await User.find_one({"email": email})
        if not user:
            raise HttpError(401, "Invalid credentials")
        
        # Load roles
        roles = await Role.find({"userId": str(user.id)}).to_list()
        
        # Verify password
        if not verify_password(user.password_hash, password):
            raise HttpError(401, "Invalid credentials")
        
        # Generate refresh token
        refresh_token = generate_refresh_token()
        await create_refresh_token(
            user_id=str(user.id),
            token=refresh_token,
            device_id=device_id,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        
        return await AuthService._build_auth_response(user, refresh_token)
    
    @staticmethod
    async def get_profile(user_id: str) -> dict:
        """Get user profile"""
        user = await User.get(user_id)
        if not user:
            raise HttpError(404, "User not found")
        
        await user.fetch_all_links()
        roles = await Role.find({"userId": str(user.id)}).to_list()
        
        return {
            "id": str(user.id),
            "email": user.email,
            "fullName": user.full_name,
            "phone": user.phone,
            "roles": [{"role": role.role.value} for role in roles],
            "createdAt": user.created_at.isoformat(),
        }
    
    @staticmethod
    async def _build_auth_response(user: User, refresh_token: str) -> dict:
        """Build authentication response"""
        # Get user roles
        roles = await Role.find({"userId": str(user.id)}).to_list()
        role_values = [role.role.value for role in roles]
        
        payload = {
            "id": str(user.id),
            "email": user.email,
            "roles": role_values,
        }
        
        access_token = sign_token(payload)
        
        return {
            "accessToken": access_token,
            "refreshToken": refresh_token,
            "expiresIn": settings.jwt_expires_in,
            "refreshTokenExpiresIn": "7d",
            "user": {
                "id": str(user.id),
                "email": user.email,
                "fullName": user.full_name,
                "phone": user.phone,
                "roles": [{"role": role} for role in role_values],
                "createdAt": user.created_at.isoformat(),
            },
        }

