import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class EnvConfig {
  static final _logger = Logger();

  static String get openRouterApiKey {
    final key = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (key.isEmpty) {
      _logger.e('OPENROUTER_API_KEY not found in environment variables');
    }
    return key;
  }

  static String get openRouterModel =>
      dotenv.env['OPENROUTER_MODEL'] ?? 'microsoft/mai-ds-r1:free';

  static String get openRouterUrl =>
      dotenv.env['OPENROUTER_URL'] ??
      'https://openrouter.ai/api/v1/chat/completions';

  // Add other environment variables as needed

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      _logger.i('Environment variables loaded successfully');
      _logger.i('Available env variables: ${dotenv.env.keys.join(', ')}');

      // Check if the API key is loaded
      final apiKey = dotenv.env['OPENROUTER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _logger.e('OPENROUTER_API_KEY is missing or empty in .env file');

        // Check if .env file exists
        final file = File('.env');
        if (await file.exists()) {
          _logger.i('.env file exists');
          final content = await file.readAsString();
          _logger.i('.env file content length: ${content.length}');
        } else {
          _logger.e('.env file does not exist');
        }
      } else {
        _logger.i('OPENROUTER_API_KEY found with length: ${apiKey.length}');
      }
    } catch (e) {
      _logger.e('Error loading environment variables: $e');
    }
  }
}
