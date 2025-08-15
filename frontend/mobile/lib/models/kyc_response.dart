class KYCStatusResponse {
  final String? citizenId;
  final String? nicFrontUrl;
  final String? nicBackUrl;
  final String? selfieUrl;
  final DateTime? nicFrontUploadedAt;
  final DateTime? nicBackUploadedAt;
  final DateTime? selfieUploadedAt;
  final String status;
  final DateTime? verificationCompletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KYCStatusResponse({
    this.citizenId,
    this.nicFrontUrl,
    this.nicBackUrl,
    this.selfieUrl,
    this.nicFrontUploadedAt,
    this.nicBackUploadedAt,
    this.selfieUploadedAt,
    required this.status,
    this.verificationCompletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory KYCStatusResponse.fromJson(Map<String, dynamic> json) {
    return KYCStatusResponse(
      citizenId: json['citizen_id'] as String?,
      nicFrontUrl: json['nic_front_url'] as String?,
      nicBackUrl: json['nic_back_url'] as String?,
      selfieUrl: json['selfie_url'] as String?,
      nicFrontUploadedAt:
          json['nic_front_uploaded_at'] != null
              ? DateTime.parse(json['nic_front_uploaded_at'] as String)
              : null,
      nicBackUploadedAt:
          json['nic_back_uploaded_at'] != null
              ? DateTime.parse(json['nic_back_uploaded_at'] as String)
              : null,
      selfieUploadedAt:
          json['selfie_uploaded_at'] != null
              ? DateTime.parse(json['selfie_uploaded_at'] as String)
              : null,
      status: json['status'] as String,
      verificationCompletedAt:
          json['verification_completed_at'] != null
              ? DateTime.parse(json['verification_completed_at'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citizen_id': citizenId,
      'nic_front_url': nicFrontUrl,
      'nic_back_url': nicBackUrl,
      'selfie_url': selfieUrl,
      'nic_front_uploaded_at': nicFrontUploadedAt?.toIso8601String(),
      'nic_back_uploaded_at': nicBackUploadedAt?.toIso8601String(),
      'selfie_uploaded_at': selfieUploadedAt?.toIso8601String(),
      'status': status,
      'verification_completed_at': verificationCompletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods to check upload status
  bool get isNicFrontUploaded => nicFrontUrl != null && nicFrontUrl!.isNotEmpty;
  bool get isNicBackUploaded => nicBackUrl != null && nicBackUrl!.isNotEmpty;
  bool get isSelfieUploaded => selfieUrl != null && selfieUrl!.isNotEmpty;
  bool get isAllUploaded =>
      isNicFrontUploaded && isNicBackUploaded && isSelfieUploaded;

  // Get completion percentage
  double get completionPercentage {
    int completed = 0;
    if (isNicFrontUploaded) completed++;
    if (isNicBackUploaded) completed++;
    if (isSelfieUploaded) completed++;
    return completed / 3.0;
  }
}
