import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../../models/api_response.dart';

class HttpClientService {
  static final HttpClientService _instance = HttpClientService._internal();
  factory HttpClientService() => _instance;
  HttpClientService._internal();

  late http.Client _client;
  String? _authToken;

  void initialize() {
    _client = http.Client();

    // Enable additional debugging for network issues
    if (ApiConfig.enableApiLogs) {
      print('HTTP Client initialized');
      print('Base URL: ${ApiConfig.baseUrl}');
      print('Fallback URLs: ${ApiConfig.fallbackUrls}');
    }
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.headers);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      print('GET Request: $uri');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool useFormEncoding = false,
  }) async {
    // Mock mode for testing without internet
    if (ApiConfig.isMockMode) {
      return _handleMockResponse<T>(endpoint, body, fromJson);
    }

    // Try with main URL first, then fallback URLs if it fails
    final attempts = [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls];

    for (int i = 0; i < attempts.length; i++) {
      try {
        final baseUrl = attempts[i];
        final uri = _buildUriWithCustomBase(baseUrl, endpoint, queryParameters);

        if (ApiConfig.enableApiLogs) {
          print('POST Request (attempt ${i + 1}): $uri');
          print(
            'POST Body: ${useFormEncoding ? body.toString() : jsonEncode(body)}',
          );
        }

        final headers = Map<String, String>.from(_headers);
        String requestBody;

        if (useFormEncoding) {
          headers['Content-Type'] = 'application/x-www-form-urlencoded';
          requestBody =
              body?.entries
                  .map(
                    (e) =>
                        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
                  )
                  .join('&') ??
              '';
        } else {
          requestBody = body != null ? jsonEncode(body) : '';
        }

        final response = await _client
            .post(uri, headers: headers, body: requestBody)
            .timeout(
              Duration(seconds: 15),
            ); // Reduced timeout for faster fallback

        if (ApiConfig.enableApiLogs) {
          print('POST attempt ${i + 1} successful: ${response.statusCode}');
        }

        return _handleResponse<T>(response, fromJson);
      } catch (e) {
        if (ApiConfig.enableApiLogs) {
          print('POST attempt ${i + 1} failed: $e');
        }

        // If this was the last attempt, return the error
        if (i == attempts.length - 1) {
          return _handleError<T>(e);
        }
        // Otherwise, continue to next attempt
      }
    }

    return _handleError<T>('All connection attempts failed');
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      print('PUT Request: $uri');

      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      print('DELETE Request: $uri');

      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? additionalFields,
    T Function(dynamic)? fromJson,
  }) async {
    // Handle mock mode
    if (ApiConfig.isMockMode) {
      return await _handleMockResponse<T>(endpoint, null, fromJson);
    }

    try {
      final uri = _buildUri(endpoint, null);
      print('UPLOAD Request: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Add headers (excluding Content-Type as it will be set by MultipartRequest)
      final headers = Map<String, String>.from(_headers);
      headers.remove('Content-Type'); // Let MultipartRequest handle this
      request.headers.addAll(headers);

      // Add the file
      var multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      );
      request.files.add(multipartFile);

      // Add additional fields if provided
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      print('Uploading file: ${file.path}');

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    return _buildUriWithCustomBase(
      ApiConfig.baseUrl,
      endpoint,
      queryParameters,
    );
  }

  Uri _buildUriWithCustomBase(
    String baseUrl,
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) {
    final baseUri = Uri.parse(baseUrl);
    final uri = baseUri.replace(
      path: baseUri.path + endpoint,
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    return uri;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    try {
      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle both wrapped and direct response formats
        T? parsedData;
        if (fromJson != null) {
          // Try to parse from 'data' field first (wrapped format)
          if (responseData['data'] != null) {
            parsedData = fromJson(responseData['data']);
          } else {
            // If no 'data' field, parse the entire response (direct format)
            parsedData = fromJson(responseData);
          }
        }

        return ApiResponse<T>.success(
          message: responseData['message'] ?? 'Success',
          data: parsedData ?? responseData['data'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>.error(
          message: responseData['message'] ?? 'An error occurred',
          errors: responseData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (ApiConfig.enableApiLogs) {
      print('HTTP Error: $error');
    }

    if (error is SocketException) {
      if (error.message.contains('Failed host lookup')) {
        return ApiResponse<T>.error(
          message:
              'Cannot connect to server. Please check your internet connection and try again.',
        );
      }
      return ApiResponse<T>.error(
        message: 'No internet connection. Please check your network.',
      );
    } else if (error is http.ClientException) {
      return ApiResponse<T>.error(
        message: 'Network error. Please check your connection and try again.',
      );
    } else if (error.toString().contains('TimeoutException')) {
      return ApiResponse<T>.error(
        message: 'Request timeout. Please try again.',
      );
    } else if (error.toString().contains('HandshakeException')) {
      return ApiResponse<T>.error(
        message: 'SSL connection error. Please try again.',
      );
    } else if (error.toString().contains('FormatException')) {
      return ApiResponse<T>.error(
        message: 'Invalid response format from server.',
      );
    } else {
      return ApiResponse<T>.error(
        message:
            ApiConfig.enableDetailedErrors
                ? 'An unexpected error occurred: ${error.toString()}'
                : 'An unexpected error occurred. Please try again.',
      );
    }
  }

  void dispose() {
    _client.close();
  }

  // Mock response handler for testing without internet
  Future<ApiResponse<T>> _handleMockResponse<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  ) async {
    if (ApiConfig.enableApiLogs) {
      print('MOCK Response for endpoint: $endpoint');
      print('MOCK Request body: $body');
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock login response
    if (endpoint.contains('/login')) {
      final mockResponseData = {
        'access_token': 'mock_jwt_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
        'token_type': 'bearer',
      };

      if (ApiConfig.enableApiLogs) {
        print('MOCK Login response: $mockResponseData');
      }

      return ApiResponse<T>.success(
        message: 'Login successful (Mock)',
        data:
            fromJson != null
                ? fromJson(mockResponseData)
                : mockResponseData as T,
        statusCode: 200,
      );
    }

    // Mock registration response
    if (endpoint.contains('/register')) {
      final mockResponseData = {
        'message': 'Registration successful',
        'user_id': 'mock_user_123',
      };

      return ApiResponse<T>.success(
        message: 'Registration successful (Mock)',
        data:
            fromJson != null
                ? fromJson(mockResponseData)
                : mockResponseData as T,
        statusCode: 201,
      );
    }

    // Mock KYC upload response
    if (endpoint.contains('/kyc/upload-nic-front') ||
        endpoint.contains('/kyc/upload-nic-back') ||
        endpoint.contains('/kyc/upload-selfie')) {
      final mockResponseData = {
        'message': 'File uploaded successfully',
        'file_id': 'mock_file_${DateTime.now().millisecondsSinceEpoch}',
        'upload_url': 'https://mock-storage.local/uploads/file123.jpg',
      };

      if (ApiConfig.enableApiLogs) {
        print('MOCK KYC Upload response: $mockResponseData');
      }

      return ApiResponse<T>.success(
        message: 'File uploaded successfully (Mock)',
        data:
            fromJson != null
                ? fromJson(mockResponseData)
                : mockResponseData as T,
        statusCode: 200,
      );
    }

    // Default mock response
    return ApiResponse<T>.success(
      message: 'Mock response',
      data: {} as T,
      statusCode: 200,
    );
  }
}
