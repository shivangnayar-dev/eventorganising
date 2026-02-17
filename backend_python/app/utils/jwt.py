"""
JWT token utilities
"""
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from jose import jwt
from app.config.env import settings


def sign_token(payload: Dict[str, Any], expires_in: Optional[str] = None) -> str:
    """
    Sign a JWT token
    
    Args:
        payload: Token payload
        expires_in: Expiration time (e.g., '1d', '7d', '15m')
    
    Returns:
        Signed JWT token
    """
    expires_in = expires_in or settings.jwt_expires_in
    
    # Parse expires_in string to timedelta
    if expires_in.endswith('d'):
        days = int(expires_in[:-1])
        exp = datetime.utcnow() + timedelta(days=days)
    elif expires_in.endswith('h'):
        hours = int(expires_in[:-1])
        exp = datetime.utcnow() + timedelta(hours=hours)
    elif expires_in.endswith('m'):
        minutes = int(expires_in[:-1])
        exp = datetime.utcnow() + timedelta(minutes=minutes)
    else:
        # Default to 1 day
        exp = datetime.utcnow() + timedelta(days=1)
    
    payload['exp'] = exp
    payload['iat'] = datetime.utcnow()
    
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def verify_token(token: str) -> Dict[str, Any]:
    """
    Verify and decode a JWT token
    
    Args:
        token: JWT token to verify
    
    Returns:
        Decoded token payload
    
    Raises:
        jwt.JWTError: If token is invalid or expired
    """
    return jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])

