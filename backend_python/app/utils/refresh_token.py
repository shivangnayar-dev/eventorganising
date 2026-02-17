"""
Refresh token utilities
"""
import secrets
import hashlib
from datetime import datetime, timedelta
from typing import Optional
from app.models.refresh_token import RefreshToken
from app.models.user import User

REFRESH_TOKEN_EXPIRY_DAYS = 7
REFRESH_TOKEN_LENGTH = 64  # 64 bytes = 128 hex characters


def generate_refresh_token() -> str:
    """Generate a secure random refresh token"""
    return secrets.token_hex(REFRESH_TOKEN_LENGTH)


async def hash_refresh_token(token: str) -> str:
    """Hash a refresh token before storing in database using SHA256"""
    # Use SHA256 for tokens (tokens are already random and long, don't need bcrypt's slow hashing)
    return hashlib.sha256(token.encode('utf-8')).hexdigest()


async def create_refresh_token(
    user_id: str,
    token: str,
    device_id: Optional[str] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> RefreshToken:
    """Create a new refresh token for a user"""
    hashed_token = await hash_refresh_token(token)
    expires_at = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRY_DAYS)
    
    refresh_token = RefreshToken(
        userId=user_id,
        token=hashed_token,
        deviceId=device_id,
        ipAddress=ip_address,
        userAgent=user_agent,
        expiresAt=expires_at,
    )
    await refresh_token.insert()
    return refresh_token


async def find_refresh_token(token: str) -> Optional[RefreshToken]:
    """Find and validate a refresh token"""
    # Hash the input token to compare with stored hashes
    hashed_input = await hash_refresh_token(token)
    
    # Find the token by its hash
    db_token = await RefreshToken.find_one({"token": hashed_input})
    
    if not db_token:
        return None
    
    # Check if token is expired
    if db_token.expires_at < datetime.utcnow():
        # Delete expired token
        await db_token.delete()
        return None
    
    # Update lastUsedAt
    db_token.last_used_at = datetime.utcnow()
    await db_token.save()
    
    return db_token


async def delete_refresh_token(token: str) -> None:
    """Delete a refresh token (logout)"""
    hashed_token = await hash_refresh_token(token)
    db_token = await RefreshToken.find_one({"token": hashed_token})
    if db_token:
        await db_token.delete()


async def delete_all_user_refresh_tokens(user_id: str) -> None:
    """Delete all refresh tokens for a user (logout all devices)"""
    await RefreshToken.find({"userId": user_id}).delete()


async def cleanup_expired_tokens() -> int:
    """Clean up expired refresh tokens"""
    now = datetime.utcnow()
    result = await RefreshToken.find({"expiresAt": {"$lt": now}}).delete()
    return result.deleted_count

