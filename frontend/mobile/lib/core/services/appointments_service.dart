import '../../models/appointment.dart';
import '../../models/api_response.dart';
import 'http_client_service.dart';

class AppointmentsService {
  static final AppointmentsService _instance = AppointmentsService._internal();
  factory AppointmentsService() => _instance;
  AppointmentsService._internal();

  final HttpClientService _httpClient = HttpClientService();

  /// Get appointments by status
  Future<ApiResponse<List<Appointment>>> getAppointments({
    required String status,
  }) async {
    try {
      print('Fetching appointments with status: $status');

      final response = await _httpClient.get(
        '/api/appointments/get-apointments',
        queryParameters: {'status': status},
      );

      print('Appointments API Response Status: ${response.statusCode}');
      print('Appointments API Response Data: ${response.data}');
      print('Appointments API Response Message: ${response.message}');

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        // Check if the response has the expected structure
        if (responseData['status'] == 'success' &&
            responseData['appointments'] != null) {
          final List<dynamic> appointmentsData =
              responseData['appointments'] as List<dynamic>;

          final appointments =
              appointmentsData
                  .map(
                    (json) =>
                        Appointment.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();

          print('Parsed ${appointments.length} appointments');

          return ApiResponse<List<Appointment>>.success(
            data: appointments,
            message: 'Appointments fetched successfully',
          );
        } else {
          return ApiResponse<List<Appointment>>.error(
            message: 'Invalid response format from server',
          );
        }
      } else {
        // Handle authentication error specifically
        if (response.statusCode == 401) {
          return ApiResponse<List<Appointment>>.error(
            message: 'Authentication failed. Please log in again.',
          );
        }

        return ApiResponse<List<Appointment>>.error(
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to fetch appointments',
        );
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      return ApiResponse<List<Appointment>>.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get completed appointments
  Future<ApiResponse<List<Appointment>>> getCompletedAppointments() {
    return getAppointments(status: 'Completed');
  }

  /// Get pending appointments
  Future<ApiResponse<List<Appointment>>> getPendingAppointments() {
    return getAppointments(status: 'Pending');
  }

  /// Get cancelled appointments
  Future<ApiResponse<List<Appointment>>> getCancelledAppointments() {
    return getAppointments(status: 'Cancelled');
  }

  /// Get all appointments (no status filter)
  Future<ApiResponse<List<Appointment>>> getAllAppointments() async {
    try {
      print('Fetching all appointments');

      final response = await _httpClient.get(
        '/api/appointments/get-apointments',
      );

      print('All Appointments API Response: ${response.data}');

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;

        // Check if the response has the expected structure
        if (responseData['status'] == 'success' &&
            responseData['appointments'] != null) {
          final List<dynamic> appointmentsData =
              responseData['appointments'] as List<dynamic>;

          final appointments =
              appointmentsData
                  .map(
                    (json) =>
                        Appointment.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();

          print('Parsed ${appointments.length} appointments');

          return ApiResponse<List<Appointment>>.success(
            data: appointments,
            message: 'All appointments fetched successfully',
          );
        } else {
          return ApiResponse<List<Appointment>>.error(
            message: 'Invalid response format from server',
          );
        }
      } else {
        return ApiResponse<List<Appointment>>.error(
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to fetch appointments',
        );
      }
    } catch (e) {
      print('Error fetching all appointments: $e');
      return ApiResponse<List<Appointment>>.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
