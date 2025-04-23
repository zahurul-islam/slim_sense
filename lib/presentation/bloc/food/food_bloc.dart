import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/food_repository_interface.dart';
import '../../../data/models/food_log_model.dart';
import 'food_event.dart';
import 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FoodRepositoryInterface foodRepository;
  StreamSubscription? _foodLogsSubscription;

  FoodBloc({required this.foodRepository}) : super(FoodInitial()) {
    on<FoodStarted>(_onFoodStarted);
    on<FoodLogsRequested>(_onFoodLogsRequested);
    on<FoodLogAdded>(_onFoodLogAdded);
    on<FoodLogUpdated>(_onFoodLogUpdated);
    on<FoodLogDeleted>(_onFoodLogDeleted);
    on<FoodSearchRequested>(_onFoodSearchRequested);
    on<FoodNutritionRequested>(_onFoodNutritionRequested);
    on<FoodBarcodeLookupRequested>(_onFoodBarcodeLookupRequested);
    on<FavoriteFoodsRequested>(_onFavoriteFoodsRequested);
    on<DailyNutritionSummaryRequested>(_onDailyNutritionSummaryRequested);
  }

  Future<void> _onFoodStarted(
    FoodStarted event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    await _foodLogsSubscription?.cancel();
    _foodLogsSubscription = foodRepository.getFoodLogs(event.userId).listen((
      foodLogs,
    ) {
      if (!isClosed) {
        emit(FoodLogsLoaded(foodLogs));
      }
    });
  }

  Future<void> _onFoodLogsRequested(
    FoodLogsRequested event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final foodLogs = await foodRepository.getFoodLogsByDate(
        event.userId,
        event.date,
      );
      emit(FoodLogsLoaded(foodLogs));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFoodLogAdded(
    FoodLogAdded event,
    Emitter<FoodState> emit,
  ) async {
    try {
      await foodRepository.addFoodLog(event.foodLog);
      emit(const FoodLogSuccess('Food log added successfully'));

      // Automatically update food logs and nutrition summary
      add(
        FoodLogsRequested(
          userId: event.foodLog.userId,
          date: event.foodLog.loggedAt,
        ),
      );

      add(
        DailyNutritionSummaryRequested(
          userId: event.foodLog.userId,
          date: event.foodLog.loggedAt,
        ),
      );
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFoodLogUpdated(
    FoodLogUpdated event,
    Emitter<FoodState> emit,
  ) async {
    try {
      await foodRepository.updateFoodLog(event.foodLog);
      emit(const FoodLogSuccess('Food log updated successfully'));

      // Automatically update food logs and nutrition summary
      add(
        FoodLogsRequested(
          userId: event.foodLog.userId,
          date: event.foodLog.loggedAt,
        ),
      );

      add(
        DailyNutritionSummaryRequested(
          userId: event.foodLog.userId,
          date: event.foodLog.loggedAt,
        ),
      );
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFoodLogDeleted(
    FoodLogDeleted event,
    Emitter<FoodState> emit,
  ) async {
    try {
      // Get the food log before deleting to know the userId and date
      final foodLog = await foodRepository.getFoodLogById(event.foodLogId);
      await foodRepository.deleteFoodLog(event.foodLogId);
      emit(const FoodLogSuccess('Food log deleted successfully'));

      if (foodLog != null) {
        // Automatically update food logs and nutrition summary
        add(FoodLogsRequested(userId: foodLog.userId, date: foodLog.loggedAt));

        add(
          DailyNutritionSummaryRequested(
            userId: foodLog.userId,
            date: foodLog.loggedAt,
          ),
        );
      }
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFoodSearchRequested(
    FoodSearchRequested event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final searchResults = await foodRepository.searchFood(event.query);
      emit(FoodSearchLoaded(searchResults));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFoodNutritionRequested(
    FoodNutritionRequested event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final nutrition = await foodRepository.getFoodNutrition(
        foodName: event.foodName,
        brand: event.brand,
        servingSize: event.servingSize,
        servingUnit: event.servingUnit,
      );
      emit(FoodNutritionLoaded(nutrition));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFoodBarcodeLookupRequested(
    FoodBarcodeLookupRequested event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final foodInfo = await foodRepository.lookupBarcode(event.barcode);
      emit(FoodBarcodeLoaded(foodInfo));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onFavoriteFoodsRequested(
    FavoriteFoodsRequested event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final favoriteFoods = await foodRepository.getFavoriteFoods(event.userId);
      emit(FavoriteFoodsLoaded(favoriteFoods));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onDailyNutritionSummaryRequested(
    DailyNutritionSummaryRequested event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final summary = await foodRepository.getDailyNutritionSummary(
        userId: event.userId,
        date: event.date,
      );
      emit(DailyNutritionSummaryLoaded(summary));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _foodLogsSubscription?.cancel();
    return super.close();
  }
}
