import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../../data/models/weight_log_model.dart';

@immutable
abstract class WeightEvent extends Equatable {
  const WeightEvent();

  @override
  List<Object> get props => [];
}

class LoadWeightLogs extends WeightEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadWeightLogs({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startDate, endDate];
}

class AddWeightLog extends WeightEvent {
  final WeightLogModel weightLog;

  const AddWeightLog(this.weightLog);

  @override
  List<Object> get props => [weightLog];
}

class UpdateWeightLog extends WeightEvent {
  final WeightLogModel weightLog;

  const UpdateWeightLog(this.weightLog);

  @override
  List<Object> get props => [weightLog];
}

class DeleteWeightLog extends WeightEvent {
  final String weightLogId;
  final String userId;

  const DeleteWeightLog({required this.weightLogId, required this.userId});

  @override
  List<Object> get props => [weightLogId, userId];
}
