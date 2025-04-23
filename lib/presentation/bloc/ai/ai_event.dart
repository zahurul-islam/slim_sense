part of 'ai_bloc.dart';

@immutable
abstract class AiEvent {
  const AiEvent();
}

class GetWeightLossRecommendation extends AiEvent {
  final double currentWeight;
  final double targetWeight;
  final String gender;
  final int age;
  final String activityLevel;
  final List<String> dietaryPreferences;

  const GetWeightLossRecommendation({
    required this.currentWeight,
    required this.targetWeight,
    required this.gender,
    required this.age,
    required this.activityLevel,
    required this.dietaryPreferences,
  });
}

class GetMealRecommendation extends AiEvent {
  final double calories;
  final String mealType;
  final List<String> dietaryRestrictions;
  final List<String> availableIngredients;

  const GetMealRecommendation({
    required this.calories,
    required this.mealType,
    required this.dietaryRestrictions,
    required this.availableIngredients,
  });
}

class GetWorkoutRecommendation extends AiEvent {
  final String fitnessLevel;
  final String goal;
  final int availableMinutes;
  final List<String> availableEquipment;

  const GetWorkoutRecommendation({
    required this.fitnessLevel,
    required this.goal,
    required this.availableMinutes,
    required this.availableEquipment,
  });
}

class AnalyzeDietaryHabits extends AiEvent {
  final int days;

  const AnalyzeDietaryHabits({required this.days});
}

class ForecastWeightProgress extends AiEvent {
  final double? targetWeight;

  const ForecastWeightProgress({this.targetWeight});
}

class ResetAiState extends AiEvent {
  const ResetAiState();
}
