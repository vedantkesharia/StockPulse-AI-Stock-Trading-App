import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Load API keys from environment variables
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get awsLambdaUrl => dotenv.env['AWS_LAMBDA_URL'] ?? '';
  static String get awsApiKey => dotenv.env['AWS_API_KEY'] ?? '';
  static String get alphaVantageKey => dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? '';
  
  // App Configuration
  static const Duration cacheDuration = Duration(minutes: 5);
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Feature Flags - Load from environment
  static bool get useRealData => _parseBool(dotenv.env['USE_REAL_DATA']) ?? true;
  static bool get enableAWSIntegration => _parseBool(dotenv.env['ENABLE_AWS_INTEGRATION']) ?? true;
  static bool get enableGeminiAI => _parseBool(dotenv.env['ENABLE_GEMINI_AI']) ?? true;
  static bool get useMockData => _parseBool(dotenv.env['USE_MOCK_DATA']) ?? false;
  static bool get allowMockFallback => _parseBool(dotenv.env['ALLOW_MOCK_FALLBACK']) ?? false;
  
  // Mock Data Settings
  static const Duration mockDataDelay = Duration(milliseconds: 800);
  
  // Helper to parse boolean from string
  static bool? _parseBool(String? value) {
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }
}