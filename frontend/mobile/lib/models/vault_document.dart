// Available vault document types
enum VaultDocumentType {
  nic('NIC'),
  passport('Passport'),
  license('License'),
  birthCertificate('BirthCertificate');

  const VaultDocumentType(this.value);
  final String value;

  static VaultDocumentType? fromString(String value) {
    print('VaultDocumentType.fromString called with: "$value"');
    switch (value.toLowerCase()) {
      case 'nic':
        print('Parsed as NIC');
        return VaultDocumentType.nic;
      case 'passport':
        print('Parsed as Passport');
        return VaultDocumentType.passport;
      case 'license':
        print('Parsed as License');
        return VaultDocumentType.license;
      case 'birthcertificate':
        print('Parsed as BirthCertificate');
        return VaultDocumentType.birthCertificate;
      default:
        print('No match found for: "$value", defaulting to null');
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
    print('VaultDocument.fromJson called with: $json');

    final documentType =
        VaultDocumentType.fromString(json['document_type'] ?? '') ??
        VaultDocumentType.nic;

    print('Document type parsed as: $documentType');

    final documentUrls =
        json['document_urls'] != null
            ? List<String>.from(json['document_urls'])
            : <String>[];

    print('Document URLs: $documentUrls');

    final uploadedAt =
        json['uploaded_at'] != null
            ? DateTime.parse(json['uploaded_at'])
            : DateTime.now();

    final expiryDate =
        json['expiry_date'] != null
            ? DateTime.parse(json['expiry_date'])
            : null;

    final document = VaultDocument(
      documentId: json['document_id'] ?? '',
      documentType: documentType,
      documentUrls: documentUrls,
      uploadedAt: uploadedAt,
      expiryDate: expiryDate,
    );

    print(
      'Created VaultDocument: ID=${document.documentId}, Type=${document.displayName}',
    );
    return document;
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
