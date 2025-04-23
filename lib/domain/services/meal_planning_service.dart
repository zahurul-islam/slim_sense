import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/food_log_model.dart';
import '../../data/models/user_model.dart';

class MealPlanningService {
  final Dio dio;

  MealPlanningService({
    required this.dio,
  });

  /// Generate a weekly meal plan based on user preferences and goals
  Future<Map<String, dynamic>> generateWeeklyMealPlan({
    required UserModel user,
    required int targetCalories,
    required Map<String, double> macroTargets,
    required List<String> dietaryPreferences,
    required List<String> allergies,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/meal-planning/weekly',
        data: {
          'userId': user.id,
          'targetCalories': targetCalories,
          'macroTargets': macroTargets,
          'dietaryPreferences': dietaryPreferences,
          'allergies': allergies,
          'activityLevel': user.activityLevel,
          'excludeFoods': _getExcludedFoods(dietaryPreferences, allergies),
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to generate meal plan');
      }
    } catch (e) {
      print('Error generating meal plan: $e');
      rethrow;
    }
  }

  /// Get meal suggestions based on time of day and past eating habits
  Future<List<Map<String, dynamic>>> getMealSuggestions({
    required String userId,
    required String mealType,
    required int targetCalories,
    required List<FoodLogModel> recentLogs,
  }) async {
    try {
      // Analyze recent eating patterns
      final frequentFoods = _analyzeFrequentFoods(recentLogs);
      final averageMacros = _calculateAverageMacros(recentLogs, mealType);

      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/meal-planning/suggestions',
        data: {
          'userId': userId,
          'mealType': mealType,
          'targetCalories': targetCalories,
          'frequentFoods': frequentFoods,
          'averageMacros': averageMacros,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to get meal suggestions');
      }
    } catch (e) {
      print('Error getting meal suggestions: $e');
      rethrow;
    }
  }

  /// Generate a shopping list from meal plan
  List<Map<String, dynamic>> generateShoppingList(Map<String, dynamic> mealPlan) {
    final ingredients = <String, Map<String, dynamic>>{};

    // Extract all ingredients from the meal plan
    for (final day in mealPlan['days']) {
      for (final meal in day['meals']) {
        for (final ingredient in meal['ingredients']) {
          final name = ingredient['name'] as String;
          final amount = ingredient['amount'] as double;
          final unit = ingredient['unit'] as String;

          if (ingredients.containsKey(name)) {
            // Add to existing ingredient
            ingredients[name]!['amount'] += amount;
          } else {
            // Add new ingredient
            ingredients[name] = {
              'name': name,
              'amount': amount,
              'unit': unit,
              'category': _getIngredientCategory(name),
            };
          }
        }
      }
    }

    // Convert to list and sort by category
    final shoppingList = ingredients.values.toList();
    shoppingList.sort((a, b) => a['category'].compareTo(b['category']));

    return shoppingList;
  }

  /// Adjust meal plan based on user feedback
  Future<Map<String, dynamic>> adjustMealPlan({
    required String mealPlanId,
    required String mealId,
    required String reason,
    required String preference,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/meal-planning/adjust',
        data: {
          'mealPlanId': mealPlanId,
          'mealId': mealId,
          'reason': reason,
          'preference': preference,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to adjust meal plan');
      }
    } catch (e) {
      print('Error adjusting meal plan: $e');
      rethrow;
    }
  }

  /// Get recipe suggestions based on available ingredients
  Future<List<Map<String, dynamic>>> getRecipeSuggestions({
    required List<String> availableIngredients,
    required int targetCalories,
    required String mealType,
    required List<String> dietaryPreferences,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/meal-planning/recipes',
        data: {
          'ingredients': availableIngredients,
          'targetCalories': targetCalories,
          'mealType': mealType,
          'dietaryPreferences': dietaryPreferences,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to get recipe suggestions');
      }
    } catch (e) {
      print('Error getting recipe suggestions: $e');
      rethrow;
    }
  }

  /// Analyze nutritional balance of meal plan
  Map<String, dynamic> analyzeMealPlanBalance(Map<String, dynamic> mealPlan) {
    final analysis = {
      'calorieDistribution': <String, int>{},
      'macroDistribution': <String, Map<String, double>>{},
      'micronutrientCoverage': <String, double>{},
      'varietyScore': 0.0,
      'balanceScore': 0.0,
    };

    // Analyze calorie distribution across meals
    for (final day in mealPlan['days']) {
      for (final meal in day['meals']) {
        final mealType = meal['type'] as String;
        final calories = meal['calories'] as int;
        
        analysis['calorieDistribution'][mealType] = 
            (analysis['calorieDistribution'][mealType] ?? 0) + calories;
      }
    }

    // Calculate variety score
    final uniqueFoods = <String>{};
    for (final day in mealPlan['days']) {
      for (final meal in day['meals']) {
        for (final ingredient in meal['ingredients']) {
          uniqueFoods.add(ingredient['name'] as String);
        }
      }
    }
    analysis['varietyScore'] = uniqueFoods.length / 100.0; // Normalized

    // Calculate balance score based on recommended distribution
    final totalCalories = analysis['calorieDistribution'].values.reduce((a, b) => a + b);
    final breakfastPercentage = (analysis['calorieDistribution']['breakfast'] ?? 0) / totalCalories;
    final lunchPercentage = (analysis['calorieDistribution']['lunch'] ?? 0) / totalCalories;
    final dinnerPercentage = (analysis['calorieDistribution']['dinner'] ?? 0) / totalCalories;
    
    // Ideal distribution: breakfast 25%, lunch 35%, dinner 30%, snacks 10%
    analysis['balanceScore'] = 1.0 - (
      (breakfastPercentage - 0.25).abs() +
      (lunchPercentage - 0.35).abs() +
      (dinnerPercentage - 0.30).abs()
    );

    return analysis;
  }

  /// Private helper methods
  List<String> _getExcludedFoods(List<String> dietaryPreferences, List<String> allergies) {
    final excluded = <String>[];
    
    // Add allergens
    excluded.addAll(allergies);
    
    // Add foods based on dietary preferences
    if (dietaryPreferences.contains('vegetarian')) {
      excluded.addAll(['meat', 'poultry', 'fish']);
    }
    if (dietaryPreferences.contains('vegan')) {
      excluded.addAll(['meat', 'poultry', 'fish', 'dairy', 'eggs', 'honey']);
    }
    if (dietaryPreferences.contains('keto')) {
      excluded.addAll(['bread', 'pasta', 'rice', 'sugar', 'grains']);
    }
    if (dietaryPreferences.contains('paleo')) {
      excluded.addAll(['dairy', 'grains', 'legumes', 'processed foods']);
    }
    
    return excluded;
  }

  Map<String, double> _analyzeFrequentFoods(List<FoodLogModel> recentLogs) {
    final foodFrequency = <String, double>{};
    
    for (final log in recentLogs) {
      foodFrequency[log.foodName] = (foodFrequency[log.foodName] ?? 0) + 1;
    }
    
    // Normalize frequencies
    final totalLogs = recentLogs.length.toDouble();
    foodFrequency.updateAll((key, value) => value / totalLogs);
    
    return foodFrequency;
  }

  Map<String, double> _calculateAverageMacros(List<FoodLogModel> recentLogs, String mealType) {
    final filteredLogs = recentLogs.where((log) => log.mealType == mealType).toList();
    
    if (filteredLogs.isEmpty) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }
    
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (final log in filteredLogs) {
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFat += log.fat;
    }
    
    final count = filteredLogs.length;
    return {
      'protein': totalProtein / count,
      'carbs': totalCarbs / count,
      'fat': totalFat / count,
    };
  }

  String _getIngredientCategory(String ingredient) {
    // Simple categorization based on ingredient name
    if (ingredient.contains('chicken') || ingredient.contains('beef') || 
        ingredient.contains('pork') || ingredient.contains('fish')) {
      return 'Meat & Seafood';
    } else if (ingredient.contains('milk') || ingredient.contains('cheese') || 
               ingredient.contains('yogurt')) {
      return 'Dairy';
    } else if (ingredient.contains('bread') || ingredient.contains('pasta') || 
               ingredient.contains('rice')) {
      return 'Grains';
    } else if (ingredient.contains('apple') || ingredient.contains('banana') || 
               ingredient.contains('orange')) {
      return 'Fruits';
    } else if (ingredient.contains('carrot') || ingredient.contains('broccoli') || 
               ingredient.contains('spinach')) {
      return 'Vegetables';
    } else {
      return 'Other';
    }
  }
}
