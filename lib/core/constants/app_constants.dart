class AppConstants {
  // App Info
  static const String appName = 'SlimSense';
  static const String appVersion = '1.0.0';

  // API Settings
  static const int apiTimeoutDuration = 30;
  static const String apiBaseUrl = 'https://api.slimsense.com/v1';
  static const String pythonBackendUrl =
      'http://localhost:8000'; // Local Python backend

  // Local Storage Keys
  static const String isFirstTimeKey = 'is_first_time';
  static const String userIdKey = 'user_id';
  static const String targetWeightKey = 'target_weight';
  static const String calorieGoalKey = 'calorie_goal';
  static const String themeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String weightLogsCollection = 'weight_logs';
  static const String foodLogsCollection = 'food_logs';
  static const String mealPlansCollection = 'meal_plans';
  static const String recipesCollection = 'recipes';

  // Food Recognition API
  static const String foodRecognitionApiKey = 'YOUR_FOOD_RECOGNITION_API_KEY';
  static const String nutritionixAppId = 'YOUR_NUTRITIONIX_APP_ID';
  static const String nutritionixApiKey = 'YOUR_NUTRITIONIX_API_KEY';

  // AI Service
  // API keys are now stored in .env file and accessed via EnvConfig

  // Time Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Pagination
  static const int pageSize = 20;
  static const int maxItemsToFetch = 100;

  // Weight Tracking
  static const double minWeight = 20.0; // kg
  static const double maxWeight = 300.0; // kg
  static const double weightStep = 0.1; // kg

  // Food Tracking
  static const int defaultCalorieGoal = 2000;
  static const int minCalories = 1200;
  static const int maxCalories = 5000;

  // Units
  static const String metricUnit = 'kg';
  static const String imperialUnit = 'lbs';

  // UI Constants
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double bottomNavHeight = 64.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const Duration nutritionCacheDuration = Duration(days: 7);
}
