#!/bin/bash

# Start script for SlimSense backend

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    echo "Activating virtual environment..."
    source venv/bin/activate
fi

# Check if requirements are installed
if ! pip show fastapi > /dev/null 2>&1; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Creating default .env file..."
    cat > .env << EOF
# Server settings
DEBUG=True
HOST=0.0.0.0
PORT=8000

# Security (generate a random key for production)
SECRET_KEY=dev-secret-key-change-in-production

# API Keys (replace with your actual keys)
OPENAI_API_KEY=your-openai-api-key
NUTRITIONIX_APP_ID=your-nutritionix-app-id
NUTRITIONIX_API_KEY=your-nutritionix-api-key

# Firebase (optional for development)
# FIREBASE_CREDENTIALS=path/to/firebase-credentials.json
EOF
    echo ".env file created. Please update it with your actual API keys."
fi

# Start the server
echo "Starting SlimSense backend..."
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
