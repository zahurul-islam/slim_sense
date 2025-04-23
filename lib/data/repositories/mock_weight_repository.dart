import '../models/weight_log_model.dart';
import 'weight_repository_interface.dart';

class MockWeightRepository implements WeightRepositoryInterface {
  // In-memory storage for weight logs
  final List<WeightLogModel> _weightLogs = [];

  MockWeightRepository() {
    // Initialize with some sample data
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();

    // Add sample weight logs for the past 30 days
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Create a weight trend that shows progress (starting at 75kg and ending at 70kg)
      final weight = 75.0 - (i * 0.16);

      _weightLogs.add(
        WeightLogModel(
          id: 'weight-log-$i',
          userId: 'demo-user-id',
          weightInKg: weight,
          loggedAt: date,
          bodyFatPercentage: i % 3 == 0 ? 20.0 - (i * 0.1) : null,
          note: i % 7 == 0 ? 'Feeling good today!' : null,
        ),
      );
    }
  }

  @override
  Future<List<WeightLogModel>> getWeightLogsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter logs by date range
    return _weightLogs
        .where(
          (log) =>
              log.userId == userId &&
              log.loggedAt.isAfter(startDate) &&
              log.loggedAt.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  @override
  Future<String> addWeightLog(WeightLogModel weightLog) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate a unique ID
    final id = 'weight-log-${DateTime.now().millisecondsSinceEpoch}';

    // Create a new log with the generated ID
    final newLog = WeightLogModel(
      id: id,
      userId: weightLog.userId,
      weightInKg: weightLog.weightInKg,
      bodyFatPercentage: weightLog.bodyFatPercentage,
      muscleMass: weightLog.muscleMass,
      note: weightLog.note,
      loggedAt: weightLog.loggedAt,
      photos: weightLog.photos,
    );

    // Add to the in-memory storage
    _weightLogs.add(newLog);

    return id;
  }

  @override
  Future<void> updateWeightLog(WeightLogModel weightLog) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find the index of the log to update
    final index = _weightLogs.indexWhere((log) => log.id == weightLog.id);

    if (index != -1) {
      // Replace the log
      _weightLogs[index] = weightLog;
    }
  }

  @override
  Future<void> deleteWeightLog(String weightLogId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Remove the log
    _weightLogs.removeWhere((log) => log.id == weightLogId);
  }
}
