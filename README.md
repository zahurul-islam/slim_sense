# SlimSense

SlimSense is an AI-powered weight loss application that provides personalized recommendations for diet, workouts, and health tracking. The app leverages modern AI technologies to deliver a comprehensive weight management solution.

## Features

- **AI-Powered Recommendations**: Get personalized weight loss plans, meal ideas, and workout routines.
- **Weight Tracking**: Log and track your weight over time with charts and progress visualization.
- **Food Logging**: Record your meals and receive nutritional analysis.
- **Dietary Analysis**: Analyze your eating habits and receive suggestions for improvement.
- **Progress Forecasting**: Get AI-driven forecasts of your weight loss journey.
- **User Authentication**: Secure login with email, Google, or Facebook.
- **Cross-Platform**: Works on iOS, Android, and web platforms.

## Technical Overview

SlimSense is built using a modern tech stack:

- **Frontend**: Flutter for cross-platform mobile and web applications
- **Backend**: Python (FastAPI) for advanced AI features
- **Database**: Firebase Firestore for cloud storage
- **Authentication**: Firebase Auth
- **AI Integration**: OpenAI/Gemini via OpenRouter API
- **State Management**: Flutter Bloc
- **Offline Support**: Hive for local storage

## Project Structure

```
slim_sense/
├── lib/                    # Flutter application code
│   ├── core/               # Core utilities, constants, services
│   ├── data/               # Data layer (models, repositories)
│   ├── domain/             # Domain layer (entities, use cases)
│   ├── presentation/       # UI layer (screens, widgets, blocs)
│   └── main.dart           # Entry point
├── python_backend/         # Python backend for AI features
│   ├── app/                # FastAPI application
│   │   ├── models/         # Data models
│   │   ├── routers/        # API endpoints
│   │   ├── services/       # Business logic
│   │   └── utils/          # Utility functions
│   ├── requirements.txt    # Python dependencies
│   └── start.sh            # Startup script
└── assets/                 # Static assets (images, fonts)
```

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Python 3.9+ (for backend)
- Firebase project
- OpenAI API key
- Nutritionix API key (for food database)

### Setup

1. Clone the repository
2. Set up the Flutter frontend:
   ```
   flutter pub get
   ```

3. Set up the Python backend:
   ```
   cd python_backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

4. Configure your API keys in the appropriate files.

### Running the App

#### Flutter App
```
flutter run
```

#### Python Backend
```
cd python_backend
./start.sh
```

## Architecture

SlimSense follows Clean Architecture principles with the following layers:

1. **Presentation Layer**: UI components and BLoC state management
2. **Domain Layer**: Business logic and use cases
3. **Data Layer**: Data models, repositories, and API integration
4. **Core**: Shared utilities and constants

The application uses the BLoC pattern for state management, separating the UI from the business logic.

## AI Features

SlimSense uses AI for a variety of features:

- **Personalized Weight Loss Plans**: Custom plans based on user's profile, goals, and preferences
- **Meal Recommendations**: Suggestions based on calorie goals and dietary restrictions
- **Workout Plans**: Custom exercise routines based on fitness level and available equipment
- **Dietary Analysis**: Analysis of eating habits and areas for improvement
- **Weight Progress Forecasting**: Predictions based on current trends and target goals

The AI features are implemented through a combination of the Python backend (for complex analysis) and direct API calls from the Flutter app (for simpler recommendations).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
