import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../../models/api_response.dart';
import 'http_client_service.dart';

class KYCService {
  final HttpClientService _httpClient = HttpClientService();

  /// Upload NIC front image
  Future<ApiResponse<Map<String, dynamic>>> uploadNicFront(
    File imageFile,
  ) async {
    return await _httpClient.uploadFile<Map<String, dynamic>>(
      ApiConfig.kycUploadNicFront,
      file: imageFile,
      fieldName: 'image', // The field name expected by the backend
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Upload NIC back image (when endpoint is available)
  Future<ApiResponse<Map<String, dynamic>>> uploadNicBack(
    File imageFile,
  ) async {
    // TODO: Replace with actual endpoint when available
    return await _httpClient.uploadFile<Map<String, dynamic>>(
      '/api/citizen/kyc/upload-nic-back',
      file: imageFile,
      fieldName: 'image',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Upload selfie image (when endpoint is available)
  Future<ApiResponse<Map<String, dynamic>>> uploadSelfie(File imageFile) async {
    // TODO: Replace with actual endpoint when available
    return await _httpClient.uploadFile<Map<String, dynamic>>(
      '/api/citizen/kyc/upload-selfie',
      file: imageFile,
      fieldName: 'image',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Submit complete KYC for verification (when endpoint is available)
  Future<ApiResponse<Map<String, dynamic>>> submitKycForVerification() async {
    // TODO: Replace with actual endpoint when available
    return await _httpClient.post<Map<String, dynamic>>(
      '/api/citizen/kyc/submit',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}

// Provider for KYC service
final kycServiceProvider = Provider<KYCService>((ref) {
  return KYCService();
});
