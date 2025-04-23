from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
import firebase_admin
from firebase_admin import credentials, firestore
import os
from loguru import logger

from .config import settings
from .routers import ai, nutrition, users, weight

# Initialize FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Backend API for SlimSense AI-powered weight loss application",
)

# Set up CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Firebase
try:
    # Check if credentials file exists
    if os.path.exists(settings.FIREBASE_CREDENTIALS):
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS)
        firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase initialized successfully")
    else:
        logger.warning(
            f"Firebase credentials file not found at {settings.FIREBASE_CREDENTIALS}"
        )
        logger.warning("Firebase is not initialized - some features may not work")
except Exception as e:
    logger.error(f"Failed to initialize Firebase: {e}")


# Include routers
app.include_router(ai.router, prefix=f"{settings.API_PREFIX}/ai", tags=["AI Coach"])
app.include_router(
    nutrition.router, prefix=f"{settings.API_PREFIX}/nutrition", tags=["Nutrition"]
)
app.include_router(users.router, prefix=f"{settings.API_PREFIX}/users", tags=["Users"])
app.include_router(
    weight.router, prefix=f"{settings.API_PREFIX}/weight", tags=["Weight Tracking"]
)


@app.get("/")
async def root():
    """Root endpoint that returns API information"""
    return {
        "app_name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "active",
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
