import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../../models/api_response.dart';
import '../../models/kyc_response.dart';
import 'http_client_service.dart';
import 'token_storage_service.dart';

class KYCService {
  final HttpClientService _httpClient = HttpClientService();

  /// Ensures auth token is set before making requests
  Future<void> _ensureAuthenticated() async {
    final token = await TokenStorageService.getToken();
    if (token != null) {
      _httpClient.setAuthToken(token);
    }
  }

  /// Upload NIC front image
  Future<ApiResponse<KYCStatusResponse>> uploadNicFront(File imageFile) async {
    await _ensureAuthenticated();
    return await _httpClient.uploadFile<KYCStatusResponse>(
      ApiConfig.kycUploadNicFront,
      file: imageFile,
      fieldName: 'file', // The field name expected by the backend
      fromJson:
          (data) => KYCStatusResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Upload NIC back image
  Future<ApiResponse<KYCStatusResponse>> uploadNicBack(File imageFile) async {
    await _ensureAuthenticated();
    return await _httpClient.uploadFile<KYCStatusResponse>(
      ApiConfig.kycUploadNicBack,
      file: imageFile,
      fieldName: 'file', // Backend expects 'file' parameter
      fromJson:
          (data) => KYCStatusResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Upload selfie image
  Future<ApiResponse<KYCStatusResponse>> uploadSelfie(File imageFile) async {
    await _ensureAuthenticated();
    return await _httpClient.uploadFile<KYCStatusResponse>(
      ApiConfig.kycUploadSelfie,
      file: imageFile,
      fieldName: 'file', // Backend expects 'file' parameter
      fromJson:
          (data) => KYCStatusResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}

// Provider for KYC service
final kycServiceProvider = Provider<KYCService>((ref) {
  return KYCService();
});
