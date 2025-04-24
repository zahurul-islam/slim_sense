import 'package:flutter/material.dart';
import '../models/weight_log_model.dart';
import '../models/food_log_model.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class InsightsService {
  // Calculate weight trend insights
  Map<String, dynamic> getWeightTrendInsights(List<WeightLogModel> weightLogs, UserModel user) {
    if (weightLogs.isEmpty) {
      return {
        'hasData': false,
        'message': 'No weight data available',
      };
    }

    // Sort logs by date
    final sortedLogs = List<WeightLogModel>.from(weightLogs)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    final firstWeight = sortedLogs.first.weightInKg;
    final currentWeight = sortedLogs.last.weightInKg;
    final weightChange = currentWeight - firstWeight;
    final isWeightLoss = weightChange < 0;
    
    // Calculate weekly average change
    double weeklyChange = 0;
    if (sortedLogs.length > 1) {
      final daysDifference = sortedLogs.last.loggedAt.difference(sortedLogs.first.loggedAt).inDays;
      if (daysDifference > 0) {
        weeklyChange = (weightChange / daysDifference) * 7;
      }
    }

    // Calculate progress towards goal
    double progressPercentage = 0;
    String progressMessage = '';
    
    if (user.targetWeight != null && user.targetWeight != firstWeight) {
      final totalChangeNeeded = user.targetWeight! - firstWeight;
      final changeAchieved = currentWeight - firstWeight;
      progressPercentage = (changeAchieved / totalChangeNeeded).abs();
      
      // Cap at 100%
      progressPercentage = progressPercentage > 1 ? 1 : progressPercentage;
      
      final remainingKg = (user.targetWeight! - currentWeight).abs();
      progressMessage = 'You\'re ${(progressPercentage * 100).toStringAsFixed(1)}% towards your goal. ${remainingKg.toStringAsFixed(1)} kg to go!';
    }

    // Estimate time to goal
    String estimatedCompletion = '';
    if (weeklyChange.abs() > 0 && user.targetWeight != null) {
      final remainingChange = (user.targetWeight! - currentWeight).abs();
      final weeksRemaining = remainingChange / weeklyChange.abs();
      
      if (weeksRemaining.isFinite && weeksRemaining > 0) {
        final daysRemaining = (weeksRemaining * 7).round();
        final targetDate = DateTime.now().add(Duration(days: daysRemaining));
        estimatedCompletion = 'At your current rate, you may reach your goal around ${DateFormat('MMMM d, y').format(targetDate)}';
      }
    }

    // Generate insight message
    String insightMessage = '';
    if (isWeightLoss) {
      insightMessage = 'You\'ve lost ${weightChange.abs().toStringAsFixed(1)} kg since you started tracking.';
      if (weeklyChange.abs() > 0) {
        insightMessage += ' That\'s about ${weeklyChange.abs().toStringAsFixed(1)} kg per week.';
      }
    } else {
      insightMessage = 'You\'ve gained ${weightChange.abs().toStringAsFixed(1)} kg since you started tracking.';
      if (weeklyChange.abs() > 0) {
        insightMessage += ' That\'s about ${weeklyChange.abs().toStringAsFixed(1)} kg per week.';
      }
    }

    return {
      'hasData': true,
      'firstWeight': firstWeight,
      'currentWeight': currentWeight,
      'weightChange': weightChange,
      'isWeightLoss': isWeightLoss,
      'weeklyChange': weeklyChange,
      'progressPercentage': progressPercentage,
      'progressMessage': progressMessage,
      'estimatedCompletion': estimatedCompletion,
      'insightMessage': insightMessage,
      'weightLogs': sortedLogs,
    };
  }

  // Calculate nutrition insights
  Map<String, dynamic> getNutritionInsights(List<FoodLogModel> foodLogs, UserModel user) {
    if (foodLogs.isEmpty) {
      return {
        'hasData': false,
        'message': 'No nutrition data available',
      };
    }

    // Group logs by date
    final Map<String, List<FoodLogModel>> logsByDate = {};
    for (var log in foodLogs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.loggedAt);
      if (!logsByDate.containsKey(dateKey)) {
        logsByDate[dateKey] = [];
      }
      logsByDate[dateKey]!.add(log);
    }

    // Calculate daily averages
    double avgCalories = 0;
    double avgProtein = 0;
    double avgCarbs = 0;
    double avgFat = 0;

    logsByDate.forEach((date, logs) {
      double dailyCalories = 0;
      double dailyProtein = 0;
      double dailyCarbs = 0;
      double dailyFat = 0;

      for (var log in logs) {
        dailyCalories += log.calories;
        dailyProtein += log.protein;
        dailyCarbs += log.carbs;
        dailyFat += log.fat;
      }

      avgCalories += dailyCalories;
      avgProtein += dailyProtein;
      avgCarbs += dailyCarbs;
      avgFat += dailyFat;
    });

    final daysCount = logsByDate.length;
    avgCalories /= daysCount;
    avgProtein /= daysCount;
    avgCarbs /= daysCount;
    avgFat /= daysCount;

    // Calculate macronutrient percentages
    final totalMacros = avgProtein + avgCarbs + avgFat;
    final proteinPercentage = totalMacros > 0 ? avgProtein / totalMacros : 0;
    final carbsPercentage = totalMacros > 0 ? avgCarbs / totalMacros : 0;
    final fatPercentage = totalMacros > 0 ? avgFat / totalMacros : 0;

    // Generate insights
    String calorieInsight = '';
    if (user.dailyCalorieGoal != null) {
      final caloriePercentage = avgCalories / user.dailyCalorieGoal!;
      if (caloriePercentage < 0.8) {
        calorieInsight = 'You\'re consistently eating below your calorie goal. This may affect your energy levels.';
      } else if (caloriePercentage > 1.1) {
        calorieInsight = 'You\'re consistently eating above your calorie goal. Consider adjusting your portions.';
      } else {
        calorieInsight = 'You\'re doing great at staying within your calorie goal!';
      }
    }

    String macroInsight = '';
    if (proteinPercentage < 0.2) {
      macroInsight = 'Your protein intake is lower than recommended. Consider adding more protein-rich foods.';
    } else if (carbsPercentage > 0.6) {
      macroInsight = 'Your carbohydrate intake is higher than recommended. Consider reducing refined carbs.';
    } else if (fatPercentage > 0.4) {
      macroInsight = 'Your fat intake is higher than recommended. Focus on healthy fats and reduce saturated fats.';
    } else {
      macroInsight = 'Your macronutrient balance looks good!';
    }

    return {
      'hasData': true,
      'avgCalories': avgCalories,
      'avgProtein': avgProtein,
      'avgCarbs': avgCarbs,
      'avgFat': avgFat,
      'proteinPercentage': proteinPercentage,
      'carbsPercentage': carbsPercentage,
      'fatPercentage': fatPercentage,
      'calorieInsight': calorieInsight,
      'macroInsight': macroInsight,
      'daysTracked': daysCount,
      'foodLogs': foodLogs,
    };
  }

  // Generate AI-powered health insights
  List<Map<String, dynamic>> getAIHealthInsights(
    Map<String, dynamic> weightInsights,
    Map<String, dynamic> nutritionInsights,
    UserModel user,
  ) {
    final insights = <Map<String, dynamic>>[];
    
    // Weight trend insight
    if (weightInsights['hasData']) {
      insights.add({
        'title': 'Weight Trend',
        'description': weightInsights['insightMessage'],
        'icon': Icons.trending_up,
        'color': weightInsights['isWeightLoss'] ? Colors.green : Colors.orange,
        'actionText': 'View Details',
        'actionRoute': '/weight-details',
      });
      
      // Goal progress insight
      if (weightInsights['progressMessage'].isNotEmpty) {
        insights.add({
          'title': 'Goal Progress',
          'description': weightInsights['progressMessage'],
          'icon': Icons.flag,
          'color': Colors.blue,
          'progress': weightInsights['progressPercentage'],
          'actionText': 'Adjust Goal',
          'actionRoute': '/adjust-goal',
        });
      }
      
      // Estimated completion insight
      if (weightInsights['estimatedCompletion'].isNotEmpty) {
        insights.add({
          'title': 'Estimated Timeline',
          'description': weightInsights['estimatedCompletion'],
          'icon': Icons.calendar_today,
          'color': Colors.purple,
        });
      }
    }
    
    // Nutrition insights
    if (nutritionInsights['hasData']) {
      insights.add({
        'title': 'Calorie Intake',
        'description': nutritionInsights['calorieInsight'],
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'actionText': 'Nutrition Details',
        'actionRoute': '/nutrition-details',
      });
      
      insights.add({
        'title': 'Macronutrient Balance',
        'description': nutritionInsights['macroInsight'],
        'icon': Icons.pie_chart,
        'color': Colors.teal,
        'data': {
          'protein': nutritionInsights['proteinPercentage'],
          'carbs': nutritionInsights['carbsPercentage'],
          'fat': nutritionInsights['fatPercentage'],
        },
      });
    }
    
    // Add general health insight based on BMI if available
    if (user.height != null && user.currentWeight != null) {
      final heightInMeters = user.height! / 100;
      final bmi = user.currentWeight! / (heightInMeters * heightInMeters);
      String bmiCategory = '';
      String bmiAdvice = '';
      Color bmiColor = Colors.green;
      
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        bmiAdvice = 'Consider focusing on nutrient-dense foods to reach a healthy weight.';
        bmiColor = Colors.orange;
      } else if (bmi < 25) {
        bmiCategory = 'Healthy Weight';
        bmiAdvice = 'You\'re at a healthy weight. Keep up the good work!';
        bmiColor = Colors.green;
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
        bmiAdvice = 'Consider gradual weight loss through balanced diet and regular exercise.';
        bmiColor = Colors.orange;
      } else {
        bmiCategory = 'Obese';
        bmiAdvice = 'Consider consulting a healthcare professional for personalized weight management advice.';
        bmiColor = Colors.red;
      }
      
      insights.add({
        'title': 'BMI Status',
        'description': 'Your BMI is ${bmi.toStringAsFixed(1)}, which is classified as $bmiCategory. $bmiAdvice',
        'icon': Icons.monitor_weight,
        'color': bmiColor,
      });
    }
    
    return insights;
  }
}
