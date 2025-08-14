class LoginResponse {
  final String accessToken;
  final String tokenType;

  const LoginResponse({required this.accessToken, required this.tokenType});

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'token_type': tokenType};
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }

  @override
  String toString() {
    return 'LoginResponse(tokenType: $tokenType, accessToken: ${accessToken.substring(0, 20)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.accessToken == accessToken &&
        other.tokenType == tokenType;
  }

  @override
  int get hashCode => accessToken.hashCode ^ tokenType.hashCode;
}
