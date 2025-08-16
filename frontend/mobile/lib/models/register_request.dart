class RegisterRequest {
  final String fullName;
  final String nicNo;
  final String phoneNo;
  final String email;
  final String password;

  const RegisterRequest({
    required this.fullName,
    required this.nicNo,
    required this.phoneNo,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'nic_no': nicNo,
      'phone_no': phoneNo,
      'email': email,
      'password': password,
    };
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      fullName: json['full_name'] ?? '',
      nicNo: json['nic_no'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'RegisterRequest(fullName: $fullName, email: $email, nicNo: $nicNo)';
  }
}
