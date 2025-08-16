import 'package:shared_preferences/shared_preferences.dart';

class FeedbackTrackingService {
  static const String _submittedFeedbackKey = 'submitted_feedback_appointments';

  /// Check if feedback has been submitted for a specific appointment
  static Future<bool> hasFeedbackBeenSubmitted(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final submittedAppointments =
        prefs.getStringList(_submittedFeedbackKey) ?? [];
    return submittedAppointments.contains(appointmentId);
  }

  /// Mark feedback as submitted for a specific appointment
  static Future<void> markFeedbackAsSubmitted(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final submittedAppointments =
        prefs.getStringList(_submittedFeedbackKey) ?? [];

    if (!submittedAppointments.contains(appointmentId)) {
      submittedAppointments.add(appointmentId);
      await prefs.setStringList(_submittedFeedbackKey, submittedAppointments);
    }
  }

  /// Clear all feedback tracking (for testing purposes)
  static Future<void> clearAllFeedbackTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_submittedFeedbackKey);
  }
}
