import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/env_config.dart';

class OpenRouterService {
  // Use direct string values for now to debug
  final String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String apiKey =
      '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';
  final String model = 'microsoft/mai-ds-r1:free';
  final _logger = Logger();

  Future<String> getHealthCoachResponse(
    String prompt, {
    List<Map<String, String>>? history,
  }) async {
    try {
      // Debug logging
      _logger.d('API URL: $apiUrl');
      _logger.d('API Key length: ${apiKey.length}');
      _logger.d('Model: $model');
      final List<Map<String, String>> messages = [];

      // Add system message to define the AI's role
      messages.add({
        'role': 'system',
        'content':
            'You are a knowledgeable health coach assistant specialized in nutrition, fitness, and wellness. '
            'Provide personalized advice based on the user\'s health goals, current metrics, and lifestyle. '
            'Your responses should be evidence-based, supportive, and actionable. '
            'Focus on sustainable habits rather than quick fixes. '
            'When appropriate, suggest specific exercises, meal ideas, or wellness practices. '
            'If the user asks about serious medical conditions, remind them to consult healthcare professionals.',
      });

      // Add conversation history if provided
      if (history != null && history.isNotEmpty) {
        messages.addAll(history);
      }

      // Add the current user message
      messages.add({'role': 'user', 'content': prompt});

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer':
              'https://slim-sense.app', // Replace with your actual domain
          'X-Title': 'SlimSense Health Coach',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _logger.e('Error: ${response.statusCode}');
        _logger.e('Response: ${response.body}');
        return 'Sorry, I encountered an error. Please try again later.';
      }
    } catch (e) {
      _logger.e('Exception: $e');
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }
}
