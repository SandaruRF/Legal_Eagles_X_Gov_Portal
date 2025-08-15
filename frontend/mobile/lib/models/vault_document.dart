// Available vault document types
enum VaultDocumentType {
  nic('NIC'),
  passport('Passport'),
  license('License'),
  birthCertificate('BirthCertificate');

  const VaultDocumentType(this.value);
  final String value;

  static VaultDocumentType? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'nic':
        return VaultDocumentType.nic;
      case 'passport':
        return VaultDocumentType.passport;
      case 'license':
        return VaultDocumentType.license;
      case 'birthcertificate':
        return VaultDocumentType.birthCertificate;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case VaultDocumentType.nic:
        return 'National Identity Card';
      case VaultDocumentType.passport:
        return 'Passport';
      case VaultDocumentType.license:
        return 'License';
      case VaultDocumentType.birthCertificate:
        return 'Birth Certificate';
    }
  }
}

class VaultDocument {
  final String documentId;
  final VaultDocumentType documentType;
  final List<String> documentUrls;
  final DateTime uploadedAt;
  final DateTime? expiryDate;

  const VaultDocument({
    required this.documentId,
    required this.documentType,
    required this.documentUrls,
    required this.uploadedAt,
    this.expiryDate,
  });

  factory VaultDocument.fromJson(Map<String, dynamic> json) {
    return VaultDocument(
      documentId: json['document_id'] ?? '',
      documentType:
          VaultDocumentType.fromString(json['document_type'] ?? '') ??
          VaultDocumentType.nic,
      documentUrls:
          json['document_urls'] != null
              ? List<String>.from(json['document_urls'])
              : [],
      uploadedAt:
          json['uploaded_at'] != null
              ? DateTime.parse(json['uploaded_at'])
              : DateTime.now(),
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.parse(json['expiry_date'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'document_type': documentType.value,
      'document_urls': documentUrls,
      'uploaded_at': uploadedAt.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  // Convenience getters for UI
  bool get hasExpiry => expiryDate != null;
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  // Get user-friendly document type name
  String get displayName => documentType.displayName;

  // Get the first document URL (for display purposes)
  String? get primaryDocumentUrl =>
      documentUrls.isNotEmpty ? documentUrls.first : null;
}
