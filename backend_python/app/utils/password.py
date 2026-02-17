"""
Password hashing utilities
"""
import bcrypt


def hash_password(password: str) -> str:
    """
    Hash a password using bcrypt
    
    Args:
        password: Plain text password (will be encoded to bytes)
    
    Returns:
        Hashed password as string
    """
    # Encode password to bytes
    password_bytes = password.encode('utf-8')
    # Generate salt and hash
    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password_bytes, salt)
    # Return as string
    return hashed.decode('utf-8')


def verify_password(hashed_password: str, plain_password: str) -> bool:
    """
    Verify a password against its hash
    
    Args:
        hashed_password: Hashed password from database
        plain_password: Plain text password to verify
    
    Returns:
        True if password matches, False otherwise
    """
    try:
        # Encode both to bytes
        hashed_bytes = hashed_password.encode('utf-8')
        plain_bytes = plain_password.encode('utf-8')
        # Verify password
        return bcrypt.checkpw(plain_bytes, hashed_bytes)
    except Exception:
        return False

