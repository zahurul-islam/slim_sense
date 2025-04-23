import 'package:cloud_firestore/cloud_firestore.dart';

class FoodLogModel {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;
  final DateTime loggedAt;
  final bool isSynced;
  final double? fiber;
  final String? photoUrl;
  final double? servingSize;
  final String? servingUnit;
  final bool isFavorite;

  FoodLogModel({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.loggedAt,
    this.isSynced = true,
    this.fiber,
    this.photoUrl,
    this.servingSize,
    this.servingUnit,
    this.isFavorite = false,
  });

  factory FoodLogModel.fromMap(Map<String, dynamic> map) {
    return FoodLogModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      foodName: map['foodName'] ?? '',
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      mealType: map['mealType'] ?? 'other',
      loggedAt: (map['loggedAt'] as Timestamp).toDate(),
      isSynced: map['isSynced'] ?? true,
      fiber: map['fiber']?.toDouble(),
      photoUrl: map['photoUrl'],
      servingSize: map['servingSize']?.toDouble(),
      servingUnit: map['servingUnit'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'isSynced': isSynced,
      'fiber': fiber,
      'photoUrl': photoUrl,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'isFavorite': isFavorite,
    };
  }

  FoodLogModel copyWith({
    String? id,
    String? userId,
    String? foodName,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? mealType,
    DateTime? loggedAt,
    bool? isSynced,
    double? fiber,
    String? photoUrl,
    double? servingSize,
    String? servingUnit,
    bool? isFavorite,
  }) {
    return FoodLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      mealType: mealType ?? this.mealType,
      loggedAt: loggedAt ?? this.loggedAt,
      isSynced: isSynced ?? this.isSynced,
      fiber: fiber ?? this.fiber,
      photoUrl: photoUrl ?? this.photoUrl,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
