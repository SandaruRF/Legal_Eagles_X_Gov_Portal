import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';
  static const String _citizenIdKey = 'citizen_id';

  // Save authentication token
  static Future<void> saveToken(String token, String tokenType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
  }

  // Get authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get token type
  static Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  // Get full authorization header
  static Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    final tokenType = await getTokenType();

    if (token != null && tokenType != null) {
      return '$tokenType $token';
    }
    return null;
  }

  // Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear authentication token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_citizenIdKey);
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save citizen ID
  static Future<void> saveCitizenId(String citizenId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_citizenIdKey, citizenId);
  }

  // Get citizen ID
  static Future<String?> getCitizenId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_citizenIdKey);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
