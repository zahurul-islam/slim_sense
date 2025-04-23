import 'package:equatable/equatable.dart';
import '../../../data/models/food_log_model.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];
}

class FoodInitial extends FoodState {}

class FoodLoading extends FoodState {}

class FoodLogsLoaded extends FoodState {
  final List<FoodLogModel> foodLogs;

  const FoodLogsLoaded(this.foodLogs);

  @override
  List<Object> get props => [foodLogs];
}

class FoodLogSuccess extends FoodState {
  final String message;

  const FoodLogSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class FoodSearchLoaded extends FoodState {
  final List<Map<String, dynamic>> searchResults;

  const FoodSearchLoaded(this.searchResults);

  @override
  List<Object> get props => [searchResults];
}

class FoodNutritionLoaded extends FoodState {
  final Map<String, dynamic> nutrition;

  const FoodNutritionLoaded(this.nutrition);

  @override
  List<Object> get props => [nutrition];
}

class FoodBarcodeLoaded extends FoodState {
  final Map<String, dynamic> foodInfo;

  const FoodBarcodeLoaded(this.foodInfo);

  @override
  List<Object> get props => [foodInfo];
}

class FavoriteFoodsLoaded extends FoodState {
  final List<FoodLogModel> favoriteFoods;

  const FavoriteFoodsLoaded(this.favoriteFoods);

  @override
  List<Object> get props => [favoriteFoods];
}

class DailyNutritionSummaryLoaded extends FoodState {
  final Map<String, dynamic> summary;

  const DailyNutritionSummaryLoaded(this.summary);

  @override
  List<Object> get props => [summary];
}

class FoodError extends FoodState {
  final String message;

  const FoodError(this.message);

  @override
  List<Object> get props => [message];
}
