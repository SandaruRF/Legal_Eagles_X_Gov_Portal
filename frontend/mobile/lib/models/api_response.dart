class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Handle success field that might be string or boolean
    bool successValue = false;
    if (json['success'] != null) {
      if (json['success'] is bool) {
        successValue = json['success'];
      } else if (json['success'] is String) {
        successValue = json['success'].toString().toLowerCase() == 'true';
      }
    }

    return ApiResponse<T>(
      success: successValue,
      message: json['message'] ?? '',
      data:
          fromJsonT != null && json['data'] != null
              ? fromJsonT(json['data'])
              : json['data'],
      errors: json['errors'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'status_code': statusCode,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
