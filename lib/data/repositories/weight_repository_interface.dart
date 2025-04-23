import '../models/weight_log_model.dart';

abstract class WeightRepositoryInterface {
  Future<List<WeightLogModel>> getWeightLogsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<String> addWeightLog(WeightLogModel weightLog);
  
  Future<void> updateWeightLog(WeightLogModel weightLog);
  
  Future<void> deleteWeightLog(String weightLogId);
}
