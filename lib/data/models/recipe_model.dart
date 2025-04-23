class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String imageUrl;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> tags;
  final String mealType; // breakfast, lunch, dinner, snack
  final String dietType; // keto, vegan, vegetarian, paleo, etc.
  final bool isFavorite;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tags,
    required this.mealType,
    required this.dietType,
    this.isFavorite = false,
  });

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    List<String>? tags,
    String? mealType,
    String? dietType,
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      tags: tags ?? this.tags,
      mealType: mealType ?? this.mealType,
      dietType: dietType ?? this.dietType,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'tags': tags,
      'mealType': mealType,
      'dietType': dietType,
      'isFavorite': isFavorite,
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      prepTimeMinutes: map['prepTimeMinutes'] ?? 0,
      cookTimeMinutes: map['cookTimeMinutes'] ?? 0,
      servings: map['servings'] ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(map['tags'] ?? []),
      mealType: map['mealType'] ?? '',
      dietType: map['dietType'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
