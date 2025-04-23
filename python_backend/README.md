# SlimSense Backend API

Backend API for the SlimSense AI-powered weight loss application. This API provides advanced features for nutrition analysis, AI-powered recommendations, and data processing.

## Features

- AI-powered weight loss recommendations
- Meal planning and recommendations
- Workout plans based on user preferences
- Food nutrition data lookup and analysis
- Weight tracking and progress forecasting
- User profile management

## Technology Stack

- **FastAPI**: Modern, high-performance web framework for building APIs
- **Firebase**: Authentication and database
- **OpenAI**: AI models for personalized recommendations
- **Nutritionix API**: Food nutrition data
- **Python 3.9+**: Core language

## Getting Started

### Prerequisites

- Python 3.9 or higher
- Firebase account (for production)
- OpenAI API key
- Nutritionix API credentials

### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd slim_sense/python_backend
   ```

2. Create a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Create a `.env` file with the following variables:
   ```
   # Server settings
   DEBUG=True
   HOST=0.0.0.0
   PORT=8000

   # Security
   SECRET_KEY=your-secret-key-here
   
   # API Keys
   OPENAI_API_KEY=your-openai-api-key
   NUTRITIONIX_APP_ID=your-nutritionix-app-id
   NUTRITIONIX_API_KEY=your-nutritionix-api-key
   
   # Firebase (optional for development)
   FIREBASE_CREDENTIALS=path/to/firebase-credentials.json
   ```

### Running the API

For development:

```
uvicorn app.main:app --reload
```

For production:

```
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## API Documentation

Once the server is running, access the automatic API documentation at:

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Endpoints

The API is organized into the following modules:

- **AI**: `/api/v1/ai/` - AI-powered recommendations and analysis
- **Nutrition**: `/api/v1/nutrition/` - Food tracking and nutrition data
- **Weight**: `/api/v1/weight/` - Weight tracking and statistics
- **Users**: `/api/v1/users/` - User management and authentication

## Integration with Flutter App

This backend is designed to work with the SlimSense Flutter application. The Flutter app communicates with this API for advanced features while using Firebase directly for basic authentication and data storage.

## Testing

Run tests with pytest:

```
pytest
```

## Deployment

The API can be deployed to any platform that supports Python applications.

Recommended platforms:
- Google Cloud Run
- AWS Lambda with API Gateway
- Heroku
- Digital Ocean App Platform
