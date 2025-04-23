import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../../data/models/weight_log_model.dart';

@immutable
abstract class WeightState extends Equatable {
  const WeightState();

  @override
  List<Object> get props => [];
}

class WeightInitial extends WeightState {}

class WeightLoading extends WeightState {}

class WeightLogsLoaded extends WeightState {
  final List<WeightLogModel> weightLogs;

  const WeightLogsLoaded(this.weightLogs);

  @override
  List<Object> get props => [weightLogs];
}

class WeightError extends WeightState {
  final String message;

  const WeightError(this.message);

  @override
  List<Object> get props => [message];
}
