enum Environment { development, staging, production, mockMode }

class EnvironmentConfig {
  // Switch to staging to use Hugging Face backend
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

  // Fallback URLs for network issues - simplified for Hugging Face
  static const Map<Environment, List<String>> _fallbackUrls = {
    Environment.staging: ['https://anuhasip-gov-portal-backend.hf.space'],
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
  static const String citizensMe = '$apiVersion/citizens/me';

  // KYC Endpoints
  static const String kycUploadNicFront =
      '$apiVersion/citizen/kyc/upload-nic-front';
  static const String kycUploadNicBack =
      '$apiVersion/citizen/kyc/upload-nic-back';
  static const String kycUploadSelfie = '$apiVersion/citizen/kyc/upload-selfie';

  // Vault Endpoints
  static const String vaultDocuments = '$apiVersion/citizen/vault/documents';
  static const String vaultUpload = '$apiVersion/citizen/vault/upload';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts - increased for Hugging Face backend
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Debug settings
  static bool get enableApiLogs => isDevelopment || isStaging;
  static bool get enableDetailedErrors => isDevelopment;
}
