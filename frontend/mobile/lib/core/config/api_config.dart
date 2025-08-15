import 'environment_config.dart';

class ApiConfig {
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static String get apiVersion => EnvironmentConfig.apiVersion;

  // Endpoints
  static String get citizensRegister => EnvironmentConfig.citizensRegister;
  static String get citizensLogin => EnvironmentConfig.citizensLogin;

  // KYC Endpoints
  static String get kycUploadNicFront => EnvironmentConfig.kycUploadNicFront;

  // Headers
  static Map<String, String> get headers => EnvironmentConfig.headers;

  // Timeouts
  static Duration get connectTimeout => EnvironmentConfig.connectTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.receiveTimeout;

  // Debug settings
  static bool get enableApiLogs => EnvironmentConfig.enableApiLogs;
  static bool get enableDetailedErrors =>
      EnvironmentConfig.enableDetailedErrors;

  // Fallback URLs
  static List<String> get fallbackUrls => EnvironmentConfig.fallbackUrls;

  // Mock mode
  static bool get isMockMode => EnvironmentConfig.isMockMode;
}
