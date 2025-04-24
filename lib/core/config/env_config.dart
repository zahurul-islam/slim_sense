import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get openRouterModel => dotenv.env['OPENROUTER_MODEL'] ?? 'microsoft/mai-ds-r1:free';
  static String get openRouterUrl => dotenv.env['OPENROUTER_URL'] ?? 'https://openrouter.ai/api/v1/chat/completions';
  
  // Add other environment variables as needed
  
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
