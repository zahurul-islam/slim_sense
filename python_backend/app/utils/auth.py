from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from ..config import settings
from ..services.user_service import UserService
from ..models.user import UserInDB

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_PREFIX}/users/login")

async def get_current_user(token: str = Depends(oauth2_scheme)) -> UserInDB:
    """
    Get the current user from the JWT token
    
    Args:
        token: JWT token from OAuth2 scheme
        
    Returns:
        Current user information
        
    Raises:
        HTTPException: If authentication fails
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Decode the token
        payload = jwt.decode(
            token, 
            settings.SECRET_KEY, 
            algorithms=[settings.ALGORITHM]
        )
        
        # Extract user ID from token
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
            
        # Get user from database
        user_service = UserService()
        user = await user_service.get_user(user_id)
        
        if user is None:
            raise credentials_exception
            
        return user
    except JWTError:
        raise credentials_exception

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT token
    
    Args:
        data: Data to encode in the token
        expires_delta: Token expiration time delta
        
    Returns:
        Encoded JWT token
    """
    to_encode = data.copy()
    
    # Set expiration time
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        
    to_encode.update({"exp": expire})
    
    # Create JWT token
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.SECRET_KEY, 
        algorithm=settings.ALGORITHM
    )
    
    return encoded_jwt
