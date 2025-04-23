import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLogModel {
  final String id;
  final String userId;
  final double weightInKg;
  final double? heightInCm;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final String? note;
  final DateTime loggedAt;
  final bool isSynced;
  final List<String>? photos;

  // Aliases for compatibility with backend naming
  double get weight_kg => weightInKg;
  double? get height_cm => heightInCm;
  DateTime get logged_at => loggedAt;

  // Calculated metrics
  double? get bmi {
    if (heightInCm == null) return null;
    final heightInMeters = heightInCm! / 100;
    return weightInKg / (heightInMeters * heightInMeters);
  }

  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  WeightLogModel({
    required this.id,
    required this.userId,
    required this.weightInKg,
    this.heightInCm,
    this.bodyFatPercentage,
    this.muscleMass,
    this.note,
    required this.loggedAt,
    this.isSynced = true,
    this.photos,
  });

  factory WeightLogModel.fromMap(Map<String, dynamic> map) {
    return WeightLogModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      weightInKg: (map['weightInKg'] as num).toDouble(),
      heightInCm:
          map['heightInCm'] != null
              ? (map['heightInCm'] as num).toDouble()
              : null,
      bodyFatPercentage:
          map['bodyFatPercentage'] != null
              ? (map['bodyFatPercentage'] as num).toDouble()
              : null,
      muscleMass:
          map['muscleMass'] != null
              ? (map['muscleMass'] as num).toDouble()
              : null,
      note: map['note'],
      loggedAt: (map['loggedAt'] as Timestamp).toDate(),
      isSynced: map['isSynced'] ?? true,
      photos: map['photos'] != null ? List<String>.from(map['photos']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weightInKg': weightInKg,
      'heightInCm': heightInCm,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMass': muscleMass,
      'note': note,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'isSynced': isSynced,
      'photos': photos,
    };
  }

  WeightLogModel copyWith({
    String? id,
    String? userId,
    double? weightInKg,
    double? heightInCm,
    double? bodyFatPercentage,
    double? muscleMass,
    String? note,
    DateTime? loggedAt,
    bool? isSynced,
    List<String>? photos,
  }) {
    return WeightLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weightInKg: weightInKg ?? this.weightInKg,
      heightInCm: heightInCm ?? this.heightInCm,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      note: note ?? this.note,
      loggedAt: loggedAt ?? this.loggedAt,
      isSynced: isSynced ?? this.isSynced,
      photos: photos ?? this.photos,
    );
  }
}
