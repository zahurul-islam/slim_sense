import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/weight_log_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'weight_repository_interface.dart';

class WeightRepository implements WeightRepositoryInterface {
  final FirebaseFirestore firestore;

  WeightRepository({required this.firestore});

  // Get weight logs stream for a user
  Stream<List<WeightLogModel>> getWeightLogs(String userId) {
    return firestore
        .collection(AppConstants.weightLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        WeightLogModel.fromMap({...doc.data(), 'id': doc.id}),
                  )
                  .toList(),
        );
  }

  // Get weight logs for a date range
  @override
  Future<List<WeightLogModel>> getWeightLogsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot =
          await firestore
              .collection(AppConstants.weightLogsCollection)
              .where('userId', isEqualTo: userId)
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: startDate.toIso8601String(),
              )
              .where(
                'timestamp',
                isLessThanOrEqualTo: endDate.toIso8601String(),
              )
              .orderBy('timestamp', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => WeightLogModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  // Add weight log
  @override
  Future<String> addWeightLog(WeightLogModel weightLog) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.weightLogsCollection)
          .add(weightLog.toMap());

      return docRef.id;
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  // Update weight log
  @override
  Future<void> updateWeightLog(WeightLogModel weightLog) async {
    try {
      await firestore
          .collection(AppConstants.weightLogsCollection)
          .doc(weightLog.id)
          .update(weightLog.toMap());
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  // Delete weight log
  @override
  Future<void> deleteWeightLog(String weightLogId) async {
    try {
      await firestore
          .collection(AppConstants.weightLogsCollection)
          .doc(weightLogId)
          .delete();
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  // Get latest weight log
  Future<WeightLogModel?> getLatestWeightLog(String userId) async {
    try {
      final snapshot =
          await firestore
              .collection(AppConstants.weightLogsCollection)
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;

      return WeightLogModel.fromMap({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      debugPrint('Error fetching latest weight log: $e');
      return null;
    }
  }

  // Get weight statistics
  Future<Map<String, dynamic>> getWeightStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final weightLogs = await getWeightLogsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (weightLogs.isEmpty) {
        return {
          'startWeight': 0.0,
          'currentWeight': 0.0,
          'lowestWeight': 0.0,
          'highestWeight': 0.0,
          'weightChange': 0.0,
          'weightChangePercentage': 0.0,
          'averageWeight': 0.0,
          'totalLogs': 0,
        };
      }

      final weights = weightLogs.map((log) => log.weightInKg).toList();
      final startWeight = weightLogs.last.weightInKg;
      final currentWeight = weightLogs.first.weightInKg;
      final lowestWeight = weights.reduce((a, b) => a < b ? a : b);
      final highestWeight = weights.reduce((a, b) => a > b ? a : b);
      final weightChange = currentWeight - startWeight;
      final weightChangePercentage = (weightChange / startWeight) * 100;
      final averageWeight = weights.reduce((a, b) => a + b) / weights.length;

      return {
        'startWeight': startWeight,
        'currentWeight': currentWeight,
        'lowestWeight': lowestWeight,
        'highestWeight': highestWeight,
        'weightChange': weightChange,
        'weightChangePercentage': weightChangePercentage,
        'averageWeight': averageWeight,
        'totalLogs': weightLogs.length,
      };
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  // Get body fat statistics
  Future<Map<String, dynamic>> getBodyFatStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final weightLogs = await getWeightLogsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final logsWithBodyFat =
          weightLogs.where((log) => log.bodyFatPercentage != null).toList();

      if (logsWithBodyFat.isEmpty) {
        return {
          'startBodyFat': 0.0,
          'currentBodyFat': 0.0,
          'lowestBodyFat': 0.0,
          'highestBodyFat': 0.0,
          'bodyFatChange': 0.0,
          'bodyFatChangePercentage': 0.0,
          'averageBodyFat': 0.0,
          'totalLogs': 0,
        };
      }

      final bodyFatPercentages =
          logsWithBodyFat.map((log) => log.bodyFatPercentage!).toList();
      final startBodyFat = logsWithBodyFat.last.bodyFatPercentage!;
      final currentBodyFat = logsWithBodyFat.first.bodyFatPercentage!;
      final lowestBodyFat = bodyFatPercentages.reduce((a, b) => a < b ? a : b);
      final highestBodyFat = bodyFatPercentages.reduce((a, b) => a > b ? a : b);
      final bodyFatChange = currentBodyFat - startBodyFat;
      final bodyFatChangePercentage = (bodyFatChange / startBodyFat) * 100;
      final averageBodyFat =
          bodyFatPercentages.reduce((a, b) => a + b) /
          bodyFatPercentages.length;

      return {
        'startBodyFat': startBodyFat,
        'currentBodyFat': currentBodyFat,
        'lowestBodyFat': lowestBodyFat,
        'highestBodyFat': highestBodyFat,
        'bodyFatChange': bodyFatChange,
        'bodyFatChangePercentage': bodyFatChangePercentage,
        'averageBodyFat': averageBodyFat,
        'totalLogs': logsWithBodyFat.length,
      };
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  // Sync weight logs with server (for offline support)
  Future<void> syncWeightLogs(List<WeightLogModel> unsyncedLogs) async {
    try {
      final batch = firestore.batch();

      for (final log in unsyncedLogs) {
        if (log.id.isEmpty) {
          // New log without ID
          final newDocRef =
              firestore.collection(AppConstants.weightLogsCollection).doc();
          batch.set(newDocRef, {...log.toMap(), 'isSynced': true});
        } else {
          // Existing log to update
          final docRef = firestore
              .collection(AppConstants.weightLogsCollection)
              .doc(log.id);
          batch.update(docRef, {...log.toMap(), 'isSynced': true});
        }
      }

      await batch.commit();
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }
}
