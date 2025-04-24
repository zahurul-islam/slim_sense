import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Service for interacting with the OpenRouter API
class OpenRouterService {
  // Fixed API endpoint and credentials
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _apiKey =
      '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';
  static const String _model = 'microsoft/mai-ds-r1:free';

  final _logger = Logger();

  /// Get a response from the AI health coach
  Future<String> getHealthCoachResponse(
    String prompt, {
    List<Map<String, String>>? history,
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    try {
      _logger.i('Sending request to OpenRouter API');
      _logger.d('Model: $_model');

      // Prepare the messages array
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

      // Prepare the request body
      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
      };

      // Prepare headers with proper authorization
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://slim-sense.app',
        'X-Title': 'SlimSense Health Coach',
      };

      _logger.d('Request body: ${jsonEncode(requestBody)}');

      // Send the request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200) {
        _logger.i('Received successful response from OpenRouter API');
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _logger.e('Error: ${response.statusCode}');
        _logger.e('Response: ${response.body}');

        // Handle specific error codes
        if (response.statusCode == 401) {
          _logger.e('Authentication error');
          return 'Sorry, there was an authentication error. Please try again later.';
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
