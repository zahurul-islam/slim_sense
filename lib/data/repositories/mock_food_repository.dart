import 'package:dio/dio.dart';
import '../models/food_log_model.dart';
import 'food_repository_interface.dart';

class MockFoodRepository implements FoodRepositoryInterface {
  final Dio dio;

  // In-memory storage for food logs
  final List<FoodLogModel> _foodLogs = [];

  MockFoodRepository({required this.dio}) {
    // Initialize with some sample data
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();

    // Sample breakfast items
    _foodLogs.add(
      FoodLogModel(
        id: 'food-log-1',
        userId: 'demo-user-id',
        foodName: 'Oatmeal with Berries',
        calories: 320,
        protein: 12,
        carbs: 58,
        fat: 6,
        mealType: 'breakfast',
        loggedAt: DateTime(now.year, now.month, now.day, 8, 0),
        servingSize: 1,
        servingUnit: 'bowl',
        photoUrl:
            'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?ixlib=rb-4.0.3',
        isFavorite: true,
      ),
    );

    _foodLogs.add(
      FoodLogModel(
        id: 'food-log-2',
        userId: 'demo-user-id',
        foodName: 'Coffee with Milk',
        calories: 40,
        protein: 1,
        carbs: 3,
        fat: 2,
        mealType: 'breakfast',
        loggedAt: DateTime(now.year, now.month, now.day, 8, 15),
        servingSize: 1,
        servingUnit: 'cup',
        isFavorite: false,
      ),
    );

    // Sample lunch items
    _foodLogs.add(
      FoodLogModel(
        id: 'food-log-3',
        userId: 'demo-user-id',
        foodName: 'Grilled Chicken Salad',
        calories: 450,
        protein: 35,
        carbs: 20,
        fat: 25,
        mealType: 'lunch',
        loggedAt: DateTime(now.year, now.month, now.day, 12, 30),
        servingSize: 1,
        servingUnit: 'plate',
        photoUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3',
        isFavorite: true,
      ),
    );

    // Sample dinner items
    _foodLogs.add(
      FoodLogModel(
        id: 'food-log-4',
        userId: 'demo-user-id',
        foodName: 'Salmon with Vegetables',
        calories: 520,
        protein: 40,
        carbs: 25,
        fat: 30,
        mealType: 'dinner',
        loggedAt: DateTime(now.year, now.month, now.day, 19, 0),
        servingSize: 1,
        servingUnit: 'plate',
        photoUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-4.0.3',
        isFavorite: false,
      ),
    );

    // Sample snack
    _foodLogs.add(
      FoodLogModel(
        id: 'food-log-5',
        userId: 'demo-user-id',
        foodName: 'Apple',
        calories: 95,
        protein: 0.5,
        carbs: 25,
        fat: 0.3,
        mealType: 'snack',
        loggedAt: DateTime(now.year, now.month, now.day, 15, 30),
        servingSize: 1,
        servingUnit: 'medium',
        isFavorite: false,
      ),
    );
  }

  @override
  Stream<List<FoodLogModel>> getFoodLogs(String userId) {
    // Return a stream that emits the food logs once
    return Stream.value(
      _foodLogs.where((log) => log.userId == userId).toList(),
    );
  }

  @override
  Future<List<FoodLogModel>> getFoodLogsByDate(
    String userId,
    DateTime date,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter logs by date
    return _foodLogs
        .where(
          (log) =>
              log.userId == userId &&
              log.loggedAt.year == date.year &&
              log.loggedAt.month == date.month &&
              log.loggedAt.day == date.day,
        )
        .toList();
  }

  @override
  Future<String> addFoodLog(FoodLogModel foodLog) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate a unique ID
    final id = 'food-log-${DateTime.now().millisecondsSinceEpoch}';

    // Create a new log with the generated ID
    final newLog = FoodLogModel(
      id: id,
      userId: foodLog.userId,
      foodName: foodLog.foodName,
      calories: foodLog.calories,
      protein: foodLog.protein,
      carbs: foodLog.carbs,
      fat: foodLog.fat,
      mealType: foodLog.mealType,
      loggedAt: foodLog.loggedAt,
      servingSize: foodLog.servingSize,
      servingUnit: foodLog.servingUnit,
      photoUrl: foodLog.photoUrl,
      isFavorite: foodLog.isFavorite,
      fiber: foodLog.fiber,
    );

    // Add to the in-memory storage
    _foodLogs.add(newLog);

    return id;
  }

  @override
  Future<void> updateFoodLog(FoodLogModel foodLog) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find the index of the log to update
    final index = _foodLogs.indexWhere((log) => log.id == foodLog.id);

    if (index != -1) {
      // Replace the log
      _foodLogs[index] = foodLog;
    }
  }

  @override
  Future<void> deleteFoodLog(String foodLogId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Remove the log
    _foodLogs.removeWhere((log) => log.id == foodLogId);
  }

  @override
  Future<FoodLogModel?> getFoodLogById(String foodLogId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the food log with the given ID
    try {
      return _foodLogs.firstWhere((log) => log.id == foodLogId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> toggleFavorite(String foodLogId, bool isFavorite) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find the index of the log to update
    final index = _foodLogs.indexWhere((log) => log.id == foodLogId);

    if (index != -1) {
      // Create a new log with updated favorite status
      final updatedLog = FoodLogModel(
        id: _foodLogs[index].id,
        userId: _foodLogs[index].userId,
        foodName: _foodLogs[index].foodName,
        calories: _foodLogs[index].calories,
        protein: _foodLogs[index].protein,
        carbs: _foodLogs[index].carbs,
        fat: _foodLogs[index].fat,
        mealType: _foodLogs[index].mealType,
        loggedAt: _foodLogs[index].loggedAt,
        servingSize: _foodLogs[index].servingSize,
        servingUnit: _foodLogs[index].servingUnit,
        photoUrl: _foodLogs[index].photoUrl,
        isFavorite: isFavorite,
        fiber: _foodLogs[index].fiber,
      );

      // Replace the log
      _foodLogs[index] = updatedLog;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock search results
    return [
      {
        'food_name': 'Apple',
        'brand_name': null,
        'serving_qty': 1,
        'serving_unit': 'medium',
        'calories': 95,
        'photo': {
          'thumb': 'https://nix-tag-images.s3.amazonaws.com/384_thumb.jpg',
        },
      },
      {
        'food_name': 'Banana',
        'brand_name': null,
        'serving_qty': 1,
        'serving_unit': 'medium',
        'calories': 105,
        'photo': {
          'thumb': 'https://nix-tag-images.s3.amazonaws.com/384_thumb.jpg',
        },
      },
      {
        'food_name': 'Chicken Breast',
        'brand_name': null,
        'serving_qty': 3,
        'serving_unit': 'oz',
        'calories': 140,
        'photo': {
          'thumb': 'https://nix-tag-images.s3.amazonaws.com/384_thumb.jpg',
        },
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getFoodNutrition({
    required String foodName,
    String? brand,
    double? servingSize,
    String? servingUnit,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock nutrition data
    return {
      'food_name': foodName,
      'brand_name': brand,
      'serving_qty': servingSize ?? 1,
      'serving_unit': servingUnit ?? 'serving',
      'calories': 150,
      'protein': 10,
      'carbs': 15,
      'fat': 5,
      'fiber': 2,
    };
  }

  @override
  Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock barcode data
    return {
      'food_name': 'Scanned Product',
      'brand_name': 'Mock Brand',
      'serving_qty': 1,
      'serving_unit': 'serving',
      'calories': 200,
      'protein': 5,
      'carbs': 30,
      'fat': 8,
      'barcode': barcode,
    };
  }

  @override
  Future<List<FoodLogModel>> getFavoriteFoods(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return favorite foods
    return _foodLogs
        .where((log) => log.userId == userId && log.isFavorite)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getDailyNutritionSummary({
    required String userId,
    required DateTime date,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get food logs for the day
    final foodLogs = await getFoodLogsByDate(userId, date);

    // Calculate totals
    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    double totalFiber = 0.0;

    for (final log in foodLogs) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFat += log.fat;
      if (log.fiber != null) totalFiber += log.fiber!;
    }

    // Return summary
    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'mealBreakdown': {
        'breakfast':
            foodLogs.where((log) => log.mealType == 'breakfast').toList(),
        'lunch': foodLogs.where((log) => log.mealType == 'lunch').toList(),
        'dinner': foodLogs.where((log) => log.mealType == 'dinner').toList(),
        'snack': foodLogs.where((log) => log.mealType == 'snack').toList(),
      },
    };
  }
}
