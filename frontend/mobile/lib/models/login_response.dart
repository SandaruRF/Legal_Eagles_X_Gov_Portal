class LoginResponse {
  final String accessToken;
  final String tokenType;

  const LoginResponse({required this.accessToken, required this.tokenType});

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'token_type': tokenType};
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle various possible field names for access token
    String accessToken = '';
    String tokenType = 'Bearer';

    // Try different field names for access token
    accessToken =
        json['access_token']?.toString() ??
        json['accessToken']?.toString() ??
        json['token']?.toString() ??
        json['authToken']?.toString() ??
        '';

    // Try different field names for token type
    tokenType =
        json['token_type']?.toString() ??
        json['tokenType']?.toString() ??
        json['type']?.toString() ??
        'Bearer';

    // If still no access token found, log the response for debugging
    if (accessToken.isEmpty) {
      print('LoginResponse: No access token found in response');
      print('Available keys: ${json.keys.toList()}');
      print('Full response: $json');

      // Check if this is a wrapped response format
      if (json['data'] is Map<String, dynamic>) {
        print('Found data field, trying to parse from data...');
        final dataMap = json['data'] as Map<String, dynamic>;
        accessToken =
            dataMap['access_token']?.toString() ??
            dataMap['accessToken']?.toString() ??
            dataMap['token']?.toString() ??
            dataMap['authToken']?.toString() ??
            '';
        tokenType =
            dataMap['token_type']?.toString() ??
            dataMap['tokenType']?.toString() ??
            dataMap['type']?.toString() ??
            'Bearer';
      }
    }

    return LoginResponse(accessToken: accessToken, tokenType: tokenType);
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
