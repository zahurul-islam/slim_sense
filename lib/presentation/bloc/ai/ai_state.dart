part of 'ai_bloc.dart';

@immutable
abstract class AiState {
  const AiState();
}

class AiInitial extends AiState {
  const AiInitial();
}

class AiLoading extends AiState {
  const AiLoading();
}

class WeightLossRecommendationLoaded extends AiState {
  final String recommendation;
  const WeightLossRecommendationLoaded(this.recommendation);
}

class MealRecommendationLoaded extends AiState {
  final String recommendation;
  const MealRecommendationLoaded(this.recommendation);
}

class WorkoutRecommendationLoaded extends AiState {
  final String recommendation;
  const WorkoutRecommendationLoaded(this.recommendation);
}

class DietaryAnalysisLoaded extends AiState {
  final String analysis;
  const DietaryAnalysisLoaded(this.analysis);
}

class WeightForecastLoaded extends AiState {
  final String forecast;
  const WeightForecastLoaded(this.forecast);
}

class AiError extends AiState {
  final String message;
  const AiError(this.message);
}
