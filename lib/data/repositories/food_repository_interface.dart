import '../models/food_log_model.dart';

abstract class FoodRepositoryInterface {
  Stream<List<FoodLogModel>> getFoodLogs(String userId);

  Future<List<FoodLogModel>> getFoodLogsByDate(String userId, DateTime date);

  Future<String> addFoodLog(FoodLogModel foodLog);

  Future<void> updateFoodLog(FoodLogModel foodLog);

  Future<void> deleteFoodLog(String foodLogId);

  Future<void> toggleFavorite(String foodLogId, bool isFavorite);

  Future<FoodLogModel?> getFoodLogById(String foodLogId);

  // Additional methods needed by the food bloc
  Future<List<Map<String, dynamic>>> searchFood(String query);

  Future<Map<String, dynamic>> getFoodNutrition({
    required String foodName,
    String? brand,
    double? servingSize,
    String? servingUnit,
  });

  Future<Map<String, dynamic>> lookupBarcode(String barcode);

  Future<List<FoodLogModel>> getFavoriteFoods(String userId);

  Future<Map<String, dynamic>> getDailyNutritionSummary({
    required String userId,
    required DateTime date,
  });
}
