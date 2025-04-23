import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/weight_repository_interface.dart';
import '../../../data/models/weight_log_model.dart';
import 'weight_event.dart';
import 'weight_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepositoryInterface weightRepository;

  WeightBloc({required this.weightRepository}) : super(WeightInitial()) {
    on<LoadWeightLogs>(_onLoadWeightLogs);
    on<AddWeightLog>(_onAddWeightLog);
    on<UpdateWeightLog>(_onUpdateWeightLog);
    on<DeleteWeightLog>(_onDeleteWeightLog);
  }

  Future<void> _onLoadWeightLogs(
    LoadWeightLogs event,
    Emitter<WeightState> emit,
  ) async {
    emit(WeightLoading());
    try {
      final logs = await weightRepository.getWeightLogsByDateRange(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(WeightLogsLoaded(logs));
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }

  Future<void> _onAddWeightLog(
    AddWeightLog event,
    Emitter<WeightState> emit,
  ) async {
    try {
      await weightRepository.addWeightLog(event.weightLog);
      add(
        LoadWeightLogs(
          userId: event.weightLog.userId,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }

  Future<void> _onUpdateWeightLog(
    UpdateWeightLog event,
    Emitter<WeightState> emit,
  ) async {
    try {
      await weightRepository.updateWeightLog(event.weightLog);
      add(
        LoadWeightLogs(
          userId: event.weightLog.userId,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }

  Future<void> _onDeleteWeightLog(
    DeleteWeightLog event,
    Emitter<WeightState> emit,
  ) async {
    try {
      await weightRepository.deleteWeightLog(event.weightLogId);
      add(
        LoadWeightLogs(
          userId: event.userId,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }
}
