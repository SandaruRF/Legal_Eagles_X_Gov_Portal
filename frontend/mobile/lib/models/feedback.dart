class FeedbackRequest {
  final String appointmentId;
  final int rating;
  final String? comment;

  FeedbackRequest({
    required this.appointmentId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}

class FeedbackResponse {
  final bool success;
  final String message;
  final dynamic data;

  FeedbackResponse({required this.success, required this.message, this.data});

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
