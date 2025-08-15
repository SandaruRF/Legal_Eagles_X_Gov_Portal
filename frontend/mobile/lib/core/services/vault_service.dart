import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/vault_document.dart';
import '../../models/api_response.dart';
import 'http_client_service.dart';
import '../config/api_config.dart';

class VaultService {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();

  final HttpClientService _httpClient = HttpClientService();

  /// Fetch all vault documents for the current user
  Future<ApiResponse<List<VaultDocument>>> getVaultDocuments() async {
    try {
      final response = await _httpClient.get<List<VaultDocument>>(
        ApiConfig.vaultDocuments,
        fromJson: (data) {
          if (data is List) {
            return data
                .map(
                  (item) =>
                      VaultDocument.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          return <VaultDocument>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<VaultDocument>>.error(
        message: 'Failed to fetch vault documents: ${e.toString()}',
      );
    }
  }

  /// Upload multiple documents to vault (sends all files in a single request)
  Future<ApiResponse<VaultDocument>> uploadDocuments({
    required VaultDocumentType documentType,
    required List<String> filePaths,
    DateTime? expiryDate,
  }) async {
    try {
      if (filePaths.isEmpty) {
        return ApiResponse<VaultDocument>.error(
          message: 'No files selected for upload',
        );
      }

      // Create multipart request for multiple files
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vaultUpload}');
      var request = http.MultipartRequest('POST', uri);

      // Add authentication header
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add form fields
      request.fields['doc_type'] = documentType.value;
      if (expiryDate != null) {
        request.fields['expiry_date'] =
            expiryDate.toIso8601String().split('T')[0];
      }

      // Add all files
      for (String filePath in filePaths) {
        var multipartFile = await http.MultipartFile.fromPath(
          'files', // Backend expects 'files' field for multiple files
          filePath,
        );
        request.files.add(multipartFile);
      }

      if (ApiConfig.enableApiLogs) {
        print('UPLOAD Request: $uri');
        print('Upload headers: ${request.headers}');
        print('Upload fields: ${request.fields}');
        print('Upload files: ${request.files.length} files');
      }

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (ApiConfig.enableApiLogs) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      // Handle the response similar to HttpClientService
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
          final vaultDocument = VaultDocument.fromJson(responseData);

          return ApiResponse<VaultDocument>.success(
            message: 'Documents uploaded successfully',
            data: vaultDocument,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse<VaultDocument>.error(
            message: 'Failed to parse response: $e',
            statusCode: response.statusCode,
          );
        }
      } else {
        String errorMessage = 'Upload failed';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage =
              response.body.isNotEmpty ? response.body : errorMessage;
        }

        return ApiResponse<VaultDocument>.error(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<VaultDocument>.error(
        message: 'Failed to upload documents: ${e.toString()}',
      );
    }
  }

  /// Delete a document from vault
  Future<ApiResponse<void>> deleteDocument(String documentId) async {
    try {
      final response = await _httpClient.delete<void>(
        '${ApiConfig.vaultDocuments}/$documentId',
        fromJson: (data) {},
      );

      return response;
    } catch (e) {
      return ApiResponse<void>.error(
        message: 'Failed to delete document: ${e.toString()}',
      );
    }
  }
}
