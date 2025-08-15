enum Environment { development, staging, production, mockMode }

class EnvironmentConfig {
  // Switch back to staging to test IP fallback
  static const Environment _currentEnvironment = Environment.staging;

  static Environment get currentEnvironment => _currentEnvironment;

  static const Map<Environment, String> _baseUrls = {
    Environment.development:
        'http://10.0.2.2:8000', // Android emulator localhost mapping
    Environment.staging:
        'https://anuhasip-gov-portal-backend.hf.space', // Hugging Face staging
    Environment.production: 'https://your-production-url.com', // Production URL
    Environment.mockMode: 'https://mock-server.local', // Mock mode for testing
  };

  // Fallback URLs for network issues
  static const Map<Environment, List<String>> _fallbackUrls = {
    Environment.staging: [
      'https://anuhasip-gov-portal-backend.hf.space',
      'https://54.211.9.90', // Direct IP address fallback
      'http://54.211.9.90', // HTTP fallback if HTTPS fails
    ],
    Environment.mockMode: [], // No fallbacks in mock mode
  };

  static String get baseUrl => _baseUrls[_currentEnvironment]!;

  static List<String> get fallbackUrls =>
      _fallbackUrls[_currentEnvironment] ?? [];

  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isMockMode => _currentEnvironment == Environment.mockMode;

  // API Configuration
  static const String apiVersion = '/api';

  // Endpoints
  static const String citizensRegister = '$apiVersion/citizens/register';
  static const String citizensLogin = '$apiVersion/citizens/login';

  // KYC Endpoints
  static const String kycUploadNicFront =
      '$apiVersion/citizen/kyc/upload-nic-front';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Debug settings
  static bool get enableApiLogs => isDevelopment || isStaging;
  static bool get enableDetailedErrors => isDevelopment;
}
