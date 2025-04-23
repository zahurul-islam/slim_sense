import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final double? currentWeight;
  final double? targetWeight;
  final double? height;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? activityLevel;
  final int? dailyCalorieGoal;
  final Map<String, double>? macroTargets;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;
  final bool isPremium;
  final String? stripeCustomerId;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.currentWeight,
    this.targetWeight,
    this.height,
    this.gender,
    this.dateOfBirth,
    this.activityLevel,
    this.dailyCalorieGoal,
    this.macroTargets,
    this.dietaryPreferences,
    this.allergies,
    this.isPremium = false,
    this.stripeCustomerId,
  });

  // Aliases for compatibility with backend naming
  double? get height_cm => height;
  double? get current_weight => currentWeight;
  double? get target_weight => targetWeight;
  double? get starting_weight =>
      currentWeight; // Using currentWeight as fallback
  int? get calorie_goal => dailyCalorieGoal;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    createdAt,
    lastLoginAt,
    currentWeight,
    targetWeight,
    height,
    gender,
    dateOfBirth,
    activityLevel,
    dailyCalorieGoal,
    macroTargets,
    dietaryPreferences,
    allergies,
    isPremium,
    stripeCustomerId,
  ];

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt:
          map['lastLoginAt'] != null
              ? DateTime.parse(map['lastLoginAt'] as String)
              : null,
      currentWeight: (map['currentWeight'] as num?)?.toDouble(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      gender: map['gender'] as String?,
      dateOfBirth:
          map['dateOfBirth'] != null
              ? DateTime.parse(map['dateOfBirth'] as String)
              : null,
      activityLevel: map['activityLevel'] as String?,
      dailyCalorieGoal: map['dailyCalorieGoal'] as int?,
      macroTargets:
          map['macroTargets'] != null
              ? Map<String, double>.from(
                (map['macroTargets'] as Map).map(
                  (key, value) =>
                      MapEntry(key as String, (value as num).toDouble()),
                ),
              )
              : null,
      dietaryPreferences:
          map['dietaryPreferences'] != null
              ? List<String>.from(map['dietaryPreferences'] as List)
              : null,
      allergies:
          map['allergies'] != null
              ? List<String>.from(map['allergies'] as List)
              : null,
      isPremium: map['isPremium'] as bool? ?? false,
      stripeCustomerId: map['stripeCustomerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'height': height,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'activityLevel': activityLevel,
      'dailyCalorieGoal': dailyCalorieGoal,
      'macroTargets': macroTargets,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'isPremium': isPremium,
      'stripeCustomerId': stripeCustomerId,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? currentWeight,
    double? targetWeight,
    double? height,
    String? gender,
    DateTime? dateOfBirth,
    String? activityLevel,
    int? dailyCalorieGoal,
    Map<String, double>? macroTargets,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    bool? isPremium,
    String? stripeCustomerId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      macroTargets: macroTargets ?? this.macroTargets,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      isPremium: isPremium ?? this.isPremium,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
    );
  }

  // Helper getters
  bool get hasCompletedProfile =>
      currentWeight != null &&
      targetWeight != null &&
      height != null &&
      gender != null &&
      dateOfBirth != null &&
      activityLevel != null;

  double? get bmi {
    if (currentWeight == null || height == null) return null;
    final heightInMeters = height! / 100;
    return currentWeight! / (heightInMeters * heightInMeters);
  }

  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}
