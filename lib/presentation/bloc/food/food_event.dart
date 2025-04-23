import 'package:equatable/equatable.dart';
import '../../../data/models/food_log_model.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object?> get props => [];
}

class FoodStarted extends FoodEvent {
  final String userId;

  const FoodStarted(this.userId);

  @override
  List<Object> get props => [userId];
}

class FoodLogsRequested extends FoodEvent {
  final String userId;
  final DateTime date;

  const FoodLogsRequested({
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [userId, date];
}

class FoodLogAdded extends FoodEvent {
  final FoodLogModel foodLog;

  const FoodLogAdded(this.foodLog);

  @override
  List<Object> get props => [foodLog];
}

class FoodLogUpdated extends FoodEvent {
  final FoodLogModel foodLog;

  const FoodLogUpdated(this.foodLog);

  @override
  List<Object> get props => [foodLog];
}

class FoodLogDeleted extends FoodEvent {
  final String foodLogId;

  const FoodLogDeleted(this.foodLogId);

  @override
  List<Object> get props => [foodLogId];
}

class FoodSearchRequested extends FoodEvent {
  final String query;

  const FoodSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

class FoodNutritionRequested extends FoodEvent {
  final String foodName;
  final String? brand;
  final double? servingSize;
  final String? servingUnit;

  const FoodNutritionRequested({
    required this.foodName,
    this.brand,
    this.servingSize,
    this.servingUnit,
  });

  @override
  List<Object?> get props => [foodName, brand, servingSize, servingUnit];
}

class FoodBarcodeLookupRequested extends FoodEvent {
  final String barcode;

  const FoodBarcodeLookupRequested(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class FavoriteFoodsRequested extends FoodEvent {
  final String userId;

  const FavoriteFoodsRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class DailyNutritionSummaryRequested extends FoodEvent {
  final String userId;
  final DateTime date;

  const DailyNutritionSummaryRequested({
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [userId, date];
}
