import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/env_config.dart';

class OpenRouterService {
  final String apiUrl;
  final String apiKey;
  final String model;
  final _logger = Logger();

  OpenRouterService({String? apiUrl, String? apiKey, String? model})
    : this.apiUrl = apiUrl ?? EnvConfig.openRouterUrl,
      this.apiKey = apiKey ?? EnvConfig.openRouterApiKey,
      this.model = model ?? EnvConfig.openRouterModel;

  Future<String> getHealthCoachResponse(
    String prompt, {
    List<Map<String, String>>? history,
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    try {
      // Debug logging
      _logger.d('API URL: $apiUrl');
      _logger.d('API Key: ${apiKey.substring(0, 10)}...');
      _logger.d('API Key length: ${apiKey.length}');
      _logger.d('Model: $model');

      // Check if API key is empty
      if (apiKey.isEmpty) {
        _logger.e(
          'API key is empty! Environment variables may not be loading correctly.',
        );
        return 'Sorry, there was an error with the API configuration. Please try again later.';
      }
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

      // Use the direct API key for debugging
      final directApiKey =
          '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';

      _logger.d('Using direct API key for debugging');

      // Prepare headers with proper authorization
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $directApiKey',
        'HTTP-Referer': 'https://slim-sense.app',
        'X-Title': 'SlimSense Health Coach',
      };

      _logger.d('Headers: $headers');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
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

        // Handle specific error codes
        if (response.statusCode == 401) {
          _logger.e('Authentication error details: ${response.body}');

          // Try to parse the error message
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage = errorData['error']['message'];
            _logger.e('Error message: $errorMessage');

            if (errorMessage.contains('No auth credentials found')) {
              _logger.e('API key not being sent properly in the request');
            }
          } catch (e) {
            _logger.e('Failed to parse error response: $e');
          }

          return 'Sorry, there was an authentication error. Please check your API key configuration.';
        } else if (response.statusCode == 503) {
          // Implement retry logic for service unavailability
          if (retryCount < maxRetries) {
            _logger.i(
              'Service unavailable, retrying (${retryCount + 1}/$maxRetries)...',
            );
            // Wait for a bit before retrying (exponential backoff)
            await Future.delayed(
              Duration(milliseconds: 1000 * (retryCount + 1)),
            );
            return getHealthCoachResponse(
              prompt,
              history: history,
              retryCount: retryCount + 1,
              maxRetries: maxRetries,
            );
          }
          return 'Sorry, the AI service is temporarily unavailable. Please try again later.';
        } else {
          return 'Sorry, I encountered an error. Please try again later.';
        }
      }
    } catch (e) {
      _logger.e('Exception: $e');
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }
}
