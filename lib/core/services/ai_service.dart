import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AIService {
  final String openRouterApiKey;
  final String geminiModel = 'gemini-pro';
  final String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String pythonBackendUrl;

  AIService({
    required this.openRouterApiKey,
    this.pythonBackendUrl = AppConstants.pythonBackendUrl,
  });

  // Helper to check if Python backend is available
  Future<bool> _isPythonBackendAvailable() async {
    try {
      // Check connectivity first
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Check if Python backend is available with a quick health check
      final response = await http
          .get(Uri.parse('$pythonBackendUrl/health'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> getWeightLossRecommendation({
    required double currentWeight,
    required double targetWeight,
    required String gender,
    required int age,
    required String activityLevel,
    required List<String> dietaryPreferences,
  }) async {
    // Try to use Python backend if available
    final useBackend = await _isPythonBackendAvailable();

    if (useBackend) {
      try {
        final url = '$pythonBackendUrl/api/v1/ai/weight-loss-plan';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // In production, add auth token here
            // 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'target_weight': targetWeight,
            'dietary_preferences': dietaryPreferences,
            // User profile will be retrieved from auth token
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Format the recommendation for display
          return _formatWeightLossPlan(data);
        } else {
          throw Exception(
            'Failed to get AI recommendation from backend: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('Error using Python backend: $e');
        // Fallback to direct API call
        return _fallbackGetWeightLossRecommendation(
          currentWeight: currentWeight,
          targetWeight: targetWeight,
          gender: gender,
          age: age,
          activityLevel: activityLevel,
          dietaryPreferences: dietaryPreferences,
        );
      }
    } else {
      // Use direct API call if backend is not available
      return _fallbackGetWeightLossRecommendation(
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        gender: gender,
        age: age,
        activityLevel: activityLevel,
        dietaryPreferences: dietaryPreferences,
      );
    }
  }

  // Direct API call as fallback
  Future<String> _fallbackGetWeightLossRecommendation({
    required double currentWeight,
    required double targetWeight,
    required String gender,
    required int age,
    required String activityLevel,
    required List<String> dietaryPreferences,
  }) async {
    final prompt = '''
    You are a professional nutritionist and fitness coach. 
    Provide a personalized weight loss plan for:
    - Current weight: $currentWeight kg
    - Target weight: $targetWeight kg
    - Gender: $gender
    - Age: $age
    - Activity level: $activityLevel
    - Dietary preferences: ${dietaryPreferences.join(', ')}

    Include:
    1. Daily calorie target
    2. Macronutrient breakdown
    3. Sample meal plan
    4. Recommended exercises
    5. Weekly progression goals
    ''';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $openRouterApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': geminiModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful nutrition and fitness AI assistant.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception(
          'Failed to get AI recommendation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }

  // Helper to format Python backend response
  String _formatWeightLossPlan(Map<String, dynamic> data) {
    String recommendation = '';
    
    // Add daily calorie target
    recommendation += '### Daily Calorie Target\n';
    recommendation += '${data['daily_calorie_target']} calories per day\n\n';
    
    // Add macronutrient breakdown
    recommendation += '### Macronutrient Breakdown\n';
    var macros = data['macronutrient_breakdown'];
    recommendation += '- Protein: ${macros['protein']}%\n';
    recommendation += '- Carbs: ${macros['carbs']}%\n';
    recommendation += '- Fat: ${macros['fat']}%\n\n';
    
    // Add sample meal plan
    recommendation += '### Sample Meal Plan\n';
    var meals = data['sample_meal_plan'];
    meals.forEach((day, mealList) {
      recommendation += '**$day**\n';
      for (var meal in mealList) {
        recommendation += '- ${meal['meal_type']}: ${meal['meal_name']} (${meal['calories']} cal)\n';
      }
      recommendation += '\n';
    });
    
    // Add recommended exercises
    recommendation += '### Recommended Exercises\n';
    for (var exercise in data['recommended_exercises']) {
      recommendation += '- **${exercise['name']}**: ${exercise['description']}\n';
      recommendation += '  Frequency: ${exercise['frequency']}\n';
    }
    recommendation += '\n';
    
    // Add weekly goals
    recommendation += '### Weekly Progression Goals\n';
    for (var goal in data['weekly_progression_goals']) {
      recommendation += '- $goal\n';
    }
    recommendation += '\n';
    
    // Add explanation
    recommendation += '### Explanation\n';
    recommendation += data['explanation'];
    
    return recommendation;
  }

  Future<String> getMealRecommendation({
    required double calories,
    required String mealType,
    required List<String> dietaryRestrictions,
    required List<String> availableIngredients,
  }) async {
    // Try to use Python backend if available
    final useBackend = await _isPythonBackendAvailable();

    if (useBackend) {
      try {
        final url = '$pythonBackendUrl/api/v1/ai/meal';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // In production, add auth token here
          },
          body: jsonEncode({
            'calories': calories,
            'meal_type': mealType,
            'dietary_restrictions': dietaryRestrictions,
            'available_ingredients': availableIngredients,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Format the recommendation for display
          return _formatMealRecommendation(data);
        } else {
          throw Exception(
            'Failed to get meal recommendation from backend: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('Error using Python backend: $e');
        // Fallback to direct API call
        return _fallbackGetMealRecommendation(
          calories: calories,
          mealType: mealType,
          dietaryRestrictions: dietaryRestrictions,
          availableIngredients: availableIngredients,
        );
      }
    } else {
      // Use direct API call if backend is not available
      return _fallbackGetMealRecommendation(
        calories: calories,
        mealType: mealType,
        dietaryRestrictions: dietaryRestrictions,
        availableIngredients: availableIngredients,
      );
    }
  }

  // Direct API call as fallback
  Future<String> _fallbackGetMealRecommendation({
    required double calories,
    required String mealType,
    required List<String> dietaryRestrictions,
    required List<String> availableIngredients,
  }) async {
    final prompt = '''
    Suggest a $mealType meal with:
    - Target calories: $calories
    - Dietary restrictions: ${dietaryRestrictions.join(', ')}
    - Using available ingredients: ${availableIngredients.join(', ')}

    Include:
    1. Recipe name
    2. Ingredients list
    3. Preparation steps
    4. Nutrition facts
    ''';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $openRouterApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': geminiModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful meal planning AI assistant.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception(
          'Failed to get meal recommendation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }

  // Helper to format Python backend meal response
  String _formatMealRecommendation(Map<String, dynamic> data) {
    String recommendation = '';
    
    // Add recipe name
    recommendation += '# ${data['recipe_name']}\n\n';
    
    // Add meal type and calorie info
    recommendation += '*${data['meal_type']} | ${data['calories']} calories*\n\n';
    
    // Add ingredients
    recommendation += '## Ingredients\n';
    for (var ingredient in data['ingredients']) {
      recommendation += '- $ingredient\n';
    }
    recommendation += '\n';
    
    // Add preparation steps
    recommendation += '## Preparation\n';
    for (var i = 0; i < data['preparation_steps'].length; i++) {
      recommendation += '${i + 1}. ${data['preparation_steps'][i]}\n';
    }
    recommendation += '\n';
    
    // Add nutrition facts
    recommendation += '## Nutrition Facts\n';
    var nutrition = data['nutrition_facts'];
    recommendation += '- Calories: ${nutrition['calories']}\n';
    recommendation += '- Protein: ${nutrition['protein']}g\n';
    recommendation += '- Carbs: ${nutrition['carbs']}g\n';
    recommendation += '- Fat: ${nutrition['fat']}g\n';
    if (nutrition.containsKey('fiber')) {
      recommendation += '- Fiber: ${nutrition['fiber']}g\n';
    }
    if (nutrition.containsKey('sugar')) {
      recommendation += '- Sugar: ${nutrition['sugar']}g\n';
    }
    
    // Add time and difficulty if available
    if (data.containsKey('prep_time_minutes') || data.containsKey('cook_time_minutes')) {
      recommendation += '\n**Time**: ';
      if (data.containsKey('prep_time_minutes')) {
        recommendation += 'Prep: ${data['prep_time_minutes']} min';
      }
      if (data.containsKey('cook_time_minutes')) {
        recommendation += ' | Cook: ${data['cook_time_minutes']} min';
      }
    }
    if (data.containsKey('difficulty')) {
      recommendation += '\n**Difficulty**: ${data['difficulty']}';
    }
    
    return recommendation;
  }

  Future<String> getWorkoutRecommendation({
    required String fitnessLevel,
    required String goal,
    required int availableMinutes,
    required List<String> availableEquipment,
  }) async {
    // Try to use Python backend if available
    final useBackend = await _isPythonBackendAvailable();

    if (useBackend) {
      try {
        final url = '$pythonBackendUrl/api/v1/ai/workout';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // In production, add auth token here
          },
          body: jsonEncode({
            'fitness_level': fitnessLevel,
            'goal': goal,
            'available_minutes': availableMinutes,
            'available_equipment': availableEquipment,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Format the recommendation for display
          return _formatWorkoutRecommendation(data);
        } else {
          throw Exception(
            'Failed to get workout recommendation from backend: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('Error using Python backend: $e');
        // Fallback to direct API call
        return _fallbackGetWorkoutRecommendation(
          fitnessLevel: fitnessLevel,
          goal: goal,
          availableMinutes: availableMinutes,
          availableEquipment: availableEquipment,
        );
      }
    } else {
      // Use direct API call if backend is not available
      return _fallbackGetWorkoutRecommendation(
        fitnessLevel: fitnessLevel,
        goal: goal,
        availableMinutes: availableMinutes,
        availableEquipment: availableEquipment,
      );
    }
  }

  // Direct API call as fallback
  Future<String> _fallbackGetWorkoutRecommendation({
    required String fitnessLevel,
    required String goal,
    required int availableMinutes,
    required List<String> availableEquipment,
  }) async {
    final prompt = '''
    Create a personalized workout plan for:
    - Fitness level: $fitnessLevel
    - Goal: $goal
    - Duration: $availableMinutes minutes
    - Available equipment: ${availableEquipment.join(', ')}

    Include:
    1. Warm-up routine
    2. Main exercises with sets/reps
    3. Cool-down
    4. Progression tips
    ''';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $openRouterApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': geminiModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful fitness AI assistant.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception(
          'Failed to get workout recommendation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }

  // Helper to format Python backend workout response
  String _formatWorkoutRecommendation(Map<String, dynamic> data) {
    String recommendation = '';
    
    // Add header and summary
    recommendation += '# ${data['fitness_level']} Level ${data['difficulty_level']} Workout\n\n';
    recommendation += '**Goal**: ${data['fitness_level']}\n';
    recommendation += '**Duration**: ${data['workout_duration_minutes']} minutes\n';
    if (data.containsKey('estimated_calories_burned')) {
      recommendation += '**Estimated Calories Burned**: ${data['estimated_calories_burned']}\n';
    }
    recommendation += '**Equipment Needed**: ${data['equipment_needed'].join(', ')}\n\n';
    
    // Add warm-up
    recommendation += '## Warm-up (${data['warm_up'].length} exercises)\n';
    for (var exercise in data['warm_up']) {
      recommendation += '### ${exercise['name']} - ${exercise['duration']}\n';
      recommendation += '${exercise['description']}\n\n';
    }
    
    // Add main exercises
    recommendation += '## Main Workout\n';
    for (var exercise in data['main_exercises']) {
      recommendation += '### ${exercise['name']} - ${exercise['sets']} sets of ${exercise['reps']} reps\n';
      recommendation += 'Rest: ${exercise['rest_seconds']} seconds\n\n';
      recommendation += '${exercise['description']}\n\n';
      
      if (exercise.containsKey('form_tips') && exercise['form_tips'].isNotEmpty) {
        recommendation += '**Form Tips**:\n';
        for (var tip in exercise['form_tips']) {
          recommendation += '- $tip\n';
        }
        recommendation += '\n';
      }
      
      if (exercise.containsKey('target_muscles') && exercise['target_muscles'].isNotEmpty) {
        recommendation += '**Target Muscles**: ${exercise['target_muscles'].join(', ')}\n\n';
      }
    }
    
    // Add cool-down
    recommendation += '## Cool-down\n';
    for (var exercise in data['cool_down']) {
      recommendation += '### ${exercise['name']} - ${exercise['duration']}\n';
      recommendation += '${exercise['description']}\n\n';
    }
    
    // Add progression tips
    recommendation += '## Progression Tips\n';
    for (var tip in data['progression_tips']) {
      recommendation += '- $tip\n';
    }
    
    // Add explanation
    recommendation += '\n## Explanation\n';
    recommendation += data['explanation'];
    
    return recommendation;
  }

  // Method to analyze food log data
  Future<String> analyzeDietaryHabits({
    required int days,
    String? token,
  }) async {
    // This requires the backend
    final useBackend = await _isPythonBackendAvailable();

    if (!useBackend) {
      return "Advanced dietary analysis requires the Python backend service to be running. Please try again later.";
    }

    try {
      final url = '$pythonBackendUrl/api/v1/ai/analyze-diet';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'food_logs_days': days,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _formatDietaryAnalysis(data);
      } else {
        throw Exception(
          'Failed to analyze dietary habits: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting dietary analysis: $e');
      throw Exception('Dietary analysis service error: $e');
    }
  }

  // Helper to format dietary analysis response
  String _formatDietaryAnalysis(Map<String, dynamic> data) {
    String analysis = '';
    
    // Add diet score and summary
    analysis += '# Dietary Analysis\n\n';
    analysis += '**Balance Score**: ${data['balanced_diet_score']}/10\n\n';
    
    // Add strengths
    analysis += '## Strengths\n';
    for (var strength in data['strengths']) {
      analysis += '- $strength\n';
    }
    analysis += '\n';
    
    // Add improvement areas
    analysis += '## Areas for Improvement\n';
    for (var area in data['improvement_areas']) {
      analysis += '- $area\n';
    }
    analysis += '\n';
    
    // Add nutrient analysis
    analysis += '## Nutrient Analysis\n';
    var nutrients = data['nutrient_analysis'];
    analysis += '- **Protein**: ${nutrients['protein_adequacy']}\n';
    analysis += '- **Carbohydrates**: ${nutrients['carb_quality']}\n';
    analysis += '- **Fats**: ${nutrients['fat_quality']}\n';
    
    if (nutrients.containsKey('micronutrient_concerns') && 
        nutrients['micronutrient_concerns'].isNotEmpty) {
      analysis += '- **Micronutrient Concerns**:\n';
      for (var concern in nutrients['micronutrient_concerns']) {
        analysis += '  - $concern\n';
      }
    }
    
    if (nutrients.containsKey('hydration')) {
      analysis += '- **Hydration**: ${nutrients['hydration']}\n';
    }
    analysis += '\n';
    
    // Add recommendations
    analysis += '## Recommendations\n';
    for (var rec in data['recommendations']) {
      analysis += '- $rec\n';
    }
    analysis += '\n';
    
    // Add explanation
    analysis += '## Detailed Explanation\n';
    analysis += data['explanation'];
    
    return analysis;
  }

  // Method to forecast weight progress
  Future<String> forecastWeightProgress({
    double? targetWeight,
    String? token,
  }) async {
    // This requires the backend
    final useBackend = await _isPythonBackendAvailable();

    if (!useBackend) {
      return "Weight progress forecasting requires the Python backend service to be running. Please try again later.";
    }

    try {
      final url = '$pythonBackendUrl/api/v1/ai/forecast-weight';
      final Map<String, dynamic> requestBody = {};
      
      if (targetWeight != null) {
        requestBody['target_weight'] = targetWeight;
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _formatWeightForecast(data);
      } else {
        throw Exception(
          'Failed to forecast weight progress: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting weight forecast: $e');
      throw Exception('Weight forecast service error: $e');
    }
  }

  // Helper to format weight forecast response
  String _formatWeightForecast(Map<String, dynamic> data) {
    String forecast = '';
    
    // Add header and summary
    forecast += '# Weight Progress Forecast\n\n';
    forecast += '**Sustainable Rate**: ${data['sustainable_rate']} kg per week\n';
    forecast += '**Required Daily Calorie Deficit**: ${data['calorie_deficit_required']} calories\n';
    
    if (data.containsKey('expected_completion_date') && 
        data['expected_completion_date'] != null) {
      forecast += '**Expected Completion Date**: ${data['expected_completion_date']}\n\n';
    } else {
      forecast += '\n';
    }
    
    // Add weekly projections
    forecast += '## Weekly Projections\n';
    for (var projection in data['weekly_projections']) {
      forecast += '- **Week ${projection['week']}**: ${projection['projected_weight'].toStringAsFixed(1)} kg';
      forecast += ' (Deficit: ${projection['required_calorie_deficit']} cal/day)\n';
    }
    forecast += '\n';
    
    // Add challenges
    forecast += '## Potential Challenges\n';
    for (var challenge in data['challenges']) {
      forecast += '- $challenge\n';
    }
    forecast += '\n';
    
    // Add recommendations
    forecast += '## Recommendations\n';
    for (var rec in data['recommendations']) {
      forecast += '- $rec\n';
    }
    forecast += '\n';
    
    // Add explanation
    forecast += '## Explanation\n';
    forecast += data['explanation'];
    
    return forecast;
  }
}
