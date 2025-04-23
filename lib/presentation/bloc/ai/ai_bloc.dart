import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../core/services/ai_service.dart';

part 'ai_event.dart';
part 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final AIService aiService;

  AiBloc({required this.aiService}) : super(const AiInitial()) {
    on<GetWeightLossRecommendation>(_onGetWeightLossRecommendation);
    on<GetMealRecommendation>(_onGetMealRecommendation);
    on<GetWorkoutRecommendation>(_onGetWorkoutRecommendation);
    on<AnalyzeDietaryHabits>(_onAnalyzeDietaryHabits);
    on<ForecastWeightProgress>(_onForecastWeightProgress);
    on<ResetAiState>(_onResetAiState);
  }

  Future<void> _onGetWeightLossRecommendation(
    GetWeightLossRecommendation event,
    Emitter<AiState> emit,
  ) async {
    emit(const AiLoading());
    try {
      final recommendation = await aiService.getWeightLossRecommendation(
        currentWeight: event.currentWeight,
        targetWeight: event.targetWeight,
        gender: event.gender,
        age: event.age,
        activityLevel: event.activityLevel,
        dietaryPreferences: event.dietaryPreferences,
      );
      emit(WeightLossRecommendationLoaded(recommendation));
    } catch (e) {
      emit(AiError(e.toString()));
    }
  }

  Future<void> _onGetMealRecommendation(
    GetMealRecommendation event,
    Emitter<AiState> emit,
  ) async {
    emit(const AiLoading());
    try {
      final recommendation = await aiService.getMealRecommendation(
        calories: event.calories,
        mealType: event.mealType,
        dietaryRestrictions: event.dietaryRestrictions,
        availableIngredients: event.availableIngredients,
      );
      emit(MealRecommendationLoaded(recommendation));
    } catch (e) {
      emit(AiError(e.toString()));
    }
  }

  Future<void> _onGetWorkoutRecommendation(
    GetWorkoutRecommendation event,
    Emitter<AiState> emit,
  ) async {
    emit(const AiLoading());
    try {
      final recommendation = await aiService.getWorkoutRecommendation(
        fitnessLevel: event.fitnessLevel,
        goal: event.goal,
        availableMinutes: event.availableMinutes,
        availableEquipment: event.availableEquipment,
      );
      emit(WorkoutRecommendationLoaded(recommendation));
    } catch (e) {
      emit(AiError(e.toString()));
    }
  }

  Future<void> _onAnalyzeDietaryHabits(
    AnalyzeDietaryHabits event,
    Emitter<AiState> emit,
  ) async {
    emit(const AiLoading());
    try {
      final analysis = await aiService.analyzeDietaryHabits(
        days: event.days,
      );
      emit(DietaryAnalysisLoaded(analysis));
    } catch (e) {
      emit(AiError(e.toString()));
    }
  }

  Future<void> _onForecastWeightProgress(
    ForecastWeightProgress event,
    Emitter<AiState> emit,
  ) async {
    emit(const AiLoading());
    try {
      final forecast = await aiService.forecastWeightProgress(
        targetWeight: event.targetWeight,
      );
      emit(WeightForecastLoaded(forecast));
    } catch (e) {
      emit(AiError(e.toString()));
    }
  }

  void _onResetAiState(
    ResetAiState event,
    Emitter<AiState> emit,
  ) {
    emit(const AiInitial());
  }
}
