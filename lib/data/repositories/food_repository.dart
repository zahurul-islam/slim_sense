import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../models/food_log_model.dart';
import '../../core/constants/app_constants.dart';
import 'food_repository_interface.dart';

class FoodRepository implements FoodRepositoryInterface {
  final FirebaseFirestore firestore;
  final Dio dio;

  FoodRepository({required this.firestore, required this.dio});

  // Get food logs stream for a user
  @override
  Stream<List<FoodLogModel>> getFoodLogs(String userId) {
    return firestore
        .collection(AppConstants.foodLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        FoodLogModel.fromMap({...doc.data(), 'id': doc.id}),
                  )
                  .toList(),
        );
  }

  // Get food logs for a specific date
  @override
  Future<List<FoodLogModel>> getFoodLogsByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      final snapshot =
          await firestore
              .collection(AppConstants.foodLogsCollection)
              .where('userId', isEqualTo: userId)
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
              )
              .where(
                'timestamp',
                isLessThanOrEqualTo: endOfDay.toIso8601String(),
              )
              .orderBy('timestamp')
              .get();

      return snapshot.docs
          .map((doc) => FoodLogModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching food logs by date: $e');
      rethrow;
    }
  }

  // Add food log
  @override
  Future<String> addFoodLog(FoodLogModel foodLog) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.foodLogsCollection)
          .add(foodLog.toMap());

      return docRef.id;
    } catch (e) {
      print('Error adding food log: $e');
      rethrow;
    }
  }

  // Update food log
  @override
  Future<void> updateFoodLog(FoodLogModel foodLog) async {
    try {
      await firestore
          .collection(AppConstants.foodLogsCollection)
          .doc(foodLog.id)
          .update(foodLog.toMap());
    } catch (e) {
      print('Error updating food log: $e');
      rethrow;
    }
  }

  // Delete food log
  @override
  Future<void> deleteFoodLog(String foodLogId) async {
    try {
      await firestore
          .collection(AppConstants.foodLogsCollection)
          .doc(foodLogId)
          .delete();
    } catch (e) {
      print('Error deleting food log: $e');
      rethrow;
    }
  }

  // Search food database via API
  @override
  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    try {
      final response = await dio.get(
        'https://trackapi.nutritionix.com/v2/search/instant',
        queryParameters: {'query': query},
        options: Options(
          headers: {
            'x-app-id': AppConstants.nutritionixAppId,
            'x-app-key': AppConstants.nutritionixApiKey,
          },
        ),
      );

      final results = <Map<String, dynamic>>[];

      // Add common foods
      if (response.data['common'] != null) {
        results.addAll(
          List<Map<String, dynamic>>.from(
            response.data['common'].map(
              (item) => {
                'foodName': item['food_name'],
                'servingSize': 1.0,
                'servingUnit': item['serving_unit'],
                'photoUrl': item['photo']['thumb'],
                'isCustom': false,
              },
            ),
          ),
        );
      }

      // Add branded foods
      if (response.data['branded'] != null) {
        results.addAll(
          List<Map<String, dynamic>>.from(
            response.data['branded'].map(
              (item) => {
                'foodName': item['food_name'],
                'servingSize': item['serving_qty'],
                'servingUnit': item['serving_unit'],
                'calories': item['nf_calories'],
                'brand': item['brand_name'],
                'photoUrl': item['photo']['thumb'],
                'isCustom': false,
              },
            ),
          ),
        );
      }

      return results;
    } catch (e) {
      print('Error searching food: $e');
      rethrow;
    }
  }

  // Get nutrition details for food
  @override
  Future<Map<String, dynamic>> getFoodNutrition({
    required String foodName,
    String? brand,
    double? servingSize,
    String? servingUnit,
  }) async {
    try {
      final endpoint =
          brand != null ? 'natural/nutrients' : 'natural/nutrients';

      final response = await dio.post(
        'https://trackapi.nutritionix.com/v2/$endpoint',
        data: {
          'query': '$servingSize $servingUnit $foodName',
          'timezone': 'US/Eastern',
        },
        options: Options(
          headers: {
            'x-app-id': AppConstants.nutritionixAppId,
            'x-app-key': AppConstants.nutritionixApiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['foods'] == null || response.data['foods'].isEmpty) {
        throw Exception('No nutrition information found');
      }

      final food = response.data['foods'][0];

      return {
        'foodName': food['food_name'],
        'servingSize': food['serving_qty'],
        'servingUnit': food['serving_unit'],
        'calories': food['nf_calories']?.round() ?? 0,
        'protein': food['nf_protein']?.toDouble() ?? 0.0,
        'carbs': food['nf_total_carbohydrate']?.toDouble() ?? 0.0,
        'fat': food['nf_total_fat']?.toDouble() ?? 0.0,
        'fiber': food['nf_dietary_fiber']?.toDouble(),
        'photoUrl': food['photo']?['thumb'],
        'micronutrients': {
          'sodium': food['nf_sodium'],
          'cholesterol': food['nf_cholesterol'],
          'sugar': food['nf_sugars'],
          'saturatedFat': food['nf_saturated_fat'],
        },
      };
    } catch (e) {
      print('Error getting food nutrition: $e');
      rethrow;
    }
  }

  // Get barcode information
  @override
  Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    try {
      final response = await dio.get(
        'https://trackapi.nutritionix.com/v2/search/item',
        queryParameters: {'upc': barcode},
        options: Options(
          headers: {
            'x-app-id': AppConstants.nutritionixAppId,
            'x-app-key': AppConstants.nutritionixApiKey,
          },
        ),
      );

      if (response.data['foods'] == null || response.data['foods'].isEmpty) {
        throw Exception('Product not found');
      }

      final food = response.data['foods'][0];

      return {
        'foodName': food['food_name'],
        'servingSize': food['serving_qty'],
        'servingUnit': food['serving_unit'],
        'calories': food['nf_calories']?.round() ?? 0,
        'protein': food['nf_protein']?.toDouble() ?? 0.0,
        'carbs': food['nf_total_carbohydrate']?.toDouble() ?? 0.0,
        'fat': food['nf_total_fat']?.toDouble() ?? 0.0,
        'fiber': food['nf_dietary_fiber']?.toDouble(),
        'brand': food['brand_name'],
        'photoUrl': food['photo']?['thumb'],
        'barcode': barcode,
      };
    } catch (e) {
      print('Error looking up barcode: $e');
      rethrow;
    }
  }

  // Get food log by ID
  @override
  Future<FoodLogModel?> getFoodLogById(String foodLogId) async {
    try {
      final doc =
          await firestore
              .collection(AppConstants.foodLogsCollection)
              .doc(foodLogId)
              .get();

      if (!doc.exists) {
        return null;
      }

      return FoodLogModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting food log by ID: $e');
      rethrow;
    }
  }

  // Toggle favorite status for a food log
  @override
  Future<void> toggleFavorite(String foodLogId, bool isFavorite) async {
    try {
      await firestore
          .collection(AppConstants.foodLogsCollection)
          .doc(foodLogId)
          .update({'isFavorite': isFavorite});
    } catch (e) {
      print('Error toggling favorite status: $e');
      rethrow;
    }
  }

  // Get favorite foods for a user
  @override
  Future<List<FoodLogModel>> getFavoriteFoods(String userId) async {
    try {
      final snapshot =
          await firestore
              .collection(AppConstants.foodLogsCollection)
              .where('userId', isEqualTo: userId)
              .where('isFavorite', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) => FoodLogModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching favorite foods: $e');
      rethrow;
    }
  }

  // Get daily nutrition summary
  @override
  Future<Map<String, dynamic>> getDailyNutritionSummary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final foodLogs = await getFoodLogsByDate(userId, date);

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
        totalFiber += log.fiber ?? 0.0;
      }

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
    } catch (e) {
      print('Error getting daily nutrition summary: $e');
      rethrow;
    }
  }
}
