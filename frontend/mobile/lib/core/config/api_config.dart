import 'environment_config.dart';

class ApiConfig {
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static String get apiVersion => EnvironmentConfig.apiVersion;

  // Endpoints
  static String get citizensRegister => EnvironmentConfig.citizensRegister;
  static String get citizensLogin => EnvironmentConfig.citizensLogin;
  static String get citizensMe => EnvironmentConfig.citizensMe;

  // KYC Endpoints
  static String get kycUploadNicFront => EnvironmentConfig.kycUploadNicFront;
  static String get kycUploadNicBack => EnvironmentConfig.kycUploadNicBack;
  static String get kycUploadSelfie => EnvironmentConfig.kycUploadSelfie;

  // Vault Endpoints
  static String get vaultDocuments => EnvironmentConfig.vaultDocuments;
  static String get vaultUpload => EnvironmentConfig.vaultUpload;

  // Forms Endpoints
  static String get forms => EnvironmentConfig.forms;

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
