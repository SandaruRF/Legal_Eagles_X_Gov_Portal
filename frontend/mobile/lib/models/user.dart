class User {
  final String? id;
  final String? citizenId;
  final String fullName;
  final String nicNo;
  final String phoneNo;
  final String email;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    this.citizenId,
    required this.fullName,
    required this.nicNo,
    required this.phoneNo,
    required this.email,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      citizenId: json['citizen_id']?.toString(),
      fullName: json['full_name'] ?? '',
      nicNo: json['nic_no'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'citizen_id': citizenId,
      'full_name': fullName,
      'nic_no': nicNo,
      'phone_no': phoneNo,
      'email': email,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? citizenId,
    String? fullName,
    String? nicNo,
    String? phoneNo,
    String? email,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      citizenId: citizenId ?? this.citizenId,
      fullName: fullName ?? this.fullName,
      nicNo: nicNo ?? this.nicNo,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, citizenId: $citizenId, fullName: $fullName, email: $email, nicNo: $nicNo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.citizenId == citizenId &&
        other.fullName == fullName &&
        other.nicNo == nicNo &&
        other.phoneNo == phoneNo &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        citizenId.hashCode ^
        fullName.hashCode ^
        nicNo.hashCode ^
        phoneNo.hashCode ^
        email.hashCode;
  }
}
