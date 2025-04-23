import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

class FoodRecognitionService {
  final Dio dio;

  FoodRecognitionService({
    required this.dio,
  });

  /// Analyze food image and get nutritional information
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // Upload image to a food recognition API
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'food_image.jpg',
        ),
      });

      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/food-recognition',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.foodRecognitionApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to analyze image');
      }
    } catch (e) {
      print('Error analyzing food image: $e');
      rethrow;
    }
  }

  /// Extract text from food label image
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'label_image.jpg',
        ),
      });

      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/ocr',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.foodRecognitionApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['text'] as String;
      } else {
        throw Exception('Failed to extract text from image');
      }
    } catch (e) {
      print('Error extracting text from image: $e');
      rethrow;
    }
  }

  /// Parse nutritional information from extracted text
  Map<String, dynamic> parseNutritionalInfo(String text) {
    final nutritionInfo = <String, dynamic>{};
    
    // Regular expressions for common nutritional values
    final caloriesRegex = RegExp(r'calories[:\s]+(\d+)', caseSensitive: false);
    final proteinRegex = RegExp(r'protein[:\s]+(\d+\.?\d*)\s*g', caseSensitive: false);
    final carbsRegex = RegExp(r'carb(?:ohydrate)?s?[:\s]+(\d+\.?\d*)\s*g', caseSensitive: false);
    final fatRegex = RegExp(r'fat[:\s]+(\d+\.?\d*)\s*g', caseSensitive: false);
    final fiberRegex = RegExp(r'fiber[:\s]+(\d+\.?\d*)\s*g', caseSensitive: false);
    final sodiumRegex = RegExp(r'sodium[:\s]+(\d+\.?\d*)\s*mg', caseSensitive: false);
    
    // Extract values
    final caloriesMatch = caloriesRegex.firstMatch(text);
    if (caloriesMatch != null) {
      nutritionInfo['calories'] = int.parse(caloriesMatch.group(1)!);
    }
    
    final proteinMatch = proteinRegex.firstMatch(text);
    if (proteinMatch != null) {
      nutritionInfo['protein'] = double.parse(proteinMatch.group(1)!);
    }
    
    final carbsMatch = carbsRegex.firstMatch(text);
    if (carbsMatch != null) {
      nutritionInfo['carbs'] = double.parse(carbsMatch.group(1)!);
    }
    
    final fatMatch = fatRegex.firstMatch(text);
    if (fatMatch != null) {
      nutritionInfo['fat'] = double.parse(fatMatch.group(1)!);
    }
    
    final fiberMatch = fiberRegex.firstMatch(text);
    if (fiberMatch != null) {
      nutritionInfo['fiber'] = double.parse(fiberMatch.group(1)!);
    }
    
    final sodiumMatch = sodiumRegex.firstMatch(text);
    if (sodiumMatch != null) {
      nutritionInfo['sodium'] = double.parse(sodiumMatch.group(1)!);
    }
    
    return nutritionInfo;
  }

  /// Get portion size estimation from food image
  Future<Map<String, dynamic>> estimatePortionSize(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'portion_image.jpg',
        ),
      });

      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/portion-estimation',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.foodRecognitionApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to estimate portion size');
      }
    } catch (e) {
      print('Error estimating portion size: $e');
      rethrow;
    }
  }

  /// Get visual food guide for portion sizes
  List<Map<String, dynamic>> getVisualPortionGuides() {
    return [
      {
        'name': '3 oz meat',
        'visual': 'Size of a deck of cards',
        'icon': '🃏',
      },
      {
        'name': '1 cup vegetables',
        'visual': 'Size of a baseball',
        'icon': '⚾',
      },
      {
        'name': '1/2 cup rice/pasta',
        'visual': 'Size of a light bulb',
        'icon': '💡',
      },
      {
        'name': '1 tbsp',
        'visual': 'Size of your thumb tip',
        'icon': '👍',
      },
      {
        'name': '1 tsp',
        'visual': 'Size of a dice',
        'icon': '🎲',
      },
      {
        'name': '1 oz cheese',
        'visual': 'Size of your thumb',
        'icon': '🧀',
      },
    ];
  }
}
