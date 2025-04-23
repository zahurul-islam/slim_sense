from fastapi import HTTPException
from fastapi.responses import JSONResponse
import functools
import logging
from typing import Callable, Any
from loguru import logger

def handle_exceptions(func: Callable) -> Callable:
    """
    Decorator to handle exceptions in FastAPI routes and service methods
    
    Args:
        func: The function to decorate
        
    Returns:
        Decorated function with exception handling
    """
    @functools.wraps(func)
    async def wrapper(*args, **kwargs) -> Any:
        try:
            return await func(*args, **kwargs)
        except HTTPException:
            # Re-raise FastAPI HTTP exceptions as-is
            raise
        except ValueError as e:
            # Convert ValueError to HTTP 400 Bad Request
            logger.error(f"Value error in {func.__name__}: {str(e)}")
            raise HTTPException(status_code=400, detail=str(e))
        except PermissionError as e:
            # Convert PermissionError to HTTP 403 Forbidden
            logger.error(f"Permission error in {func.__name__}: {str(e)}")
            raise HTTPException(status_code=403, detail=str(e))
        except FileNotFoundError as e:
            # Convert FileNotFoundError to HTTP 404 Not Found
            logger.error(f"Not found error in {func.__name__}: {str(e)}")
            raise HTTPException(status_code=404, detail=str(e))
        except NotImplementedError as e:
            # Convert NotImplementedError to HTTP 501 Not Implemented
            logger.error(f"Not implemented error in {func.__name__}: {str(e)}")
            raise HTTPException(status_code=501, detail=str(e))
        except Exception as e:
            # Convert any other exception to HTTP 500 Internal Server Error
            logger.exception(f"Unexpected error in {func.__name__}: {str(e)}")
            raise HTTPException(
                status_code=500,
                detail=f"An unexpected error occurred: {str(e)}"
            )
            
    return wrapper

class ErrorResponse(JSONResponse):
    """
    Custom JSON response for error handling
    """
    def __init__(
        self,
        status_code: int,
        message: str,
        error_code: str = None,
        **kwargs
    ):
        content = {
            "status": "error",
            "message": message
        }
        
        if error_code:
            content["error_code"] = error_code
            
        # Add any additional context
        for key, value in kwargs.items():
            content[key] = value
            
        super().__init__(content=content, status_code=status_code)
