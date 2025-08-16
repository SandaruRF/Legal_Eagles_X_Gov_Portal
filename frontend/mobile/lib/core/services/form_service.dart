import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/api_response.dart';
import '../config/environment_config.dart';
import 'token_storage_service.dart';

class FormService {
  static String get baseUrl => EnvironmentConfig.baseUrl;

  /// Get form template by form ID
  ///
  /// Current API returns: {status: "success", form: {form_id, name, form_template: "pdf_url"}}
  ///
  /// For true dynamic forms, the API should return:
  /// {status: "success", form: {form_id, name, fields: {"Field Name": "default_value", ...}}}
  ///
  /// The frontend currently creates form fields based on form name as a fallback.
  Future<ApiResponse<Map<String, dynamic>>> getFormTemplate(
    String formId,
  ) async {
    try {
      print('GET Request: $baseUrl/api/forms/$formId');

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return ApiResponse.error(message: 'Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/forms/$formId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Log the response for debugging
        print('Form template response: $data');

        return ApiResponse.success(
          message: 'Form template fetched successfully',
          data: data,
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to fetch form template',
        );
      }
    } catch (e) {
      print('Error fetching form template: $e');
      return ApiResponse.error(message: 'Network error: ${e.toString()}');
    }
  }

  /// Submit form data
  Future<ApiResponse<Map<String, dynamic>>> submitForm(
    String formId,
    Map<String, dynamic> formData,
  ) async {
    try {
      print('POST Request: $baseUrl/api/forms/$formId/submit');
      print('Form Data: $formData');

      // Get auth token and citizen ID
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final citizenId = await TokenStorageService.getCitizenId();
      final userId = await TokenStorageService.getUserId();

      if (token == null) {
        return ApiResponse.error(message: 'Authentication token not found');
      }

      // Use citizen_id if available, otherwise fallback to user_id
      // If neither is available, try to extract from form data or use a default
      String? finalCitizenId = citizenId ?? userId;

      // If still no citizen_id, try to use NIC from form data as fallback
      if (finalCitizenId == null) {
        final nicValue =
            formData['NIC No'] ?? formData['nic_no'] ?? formData['nic'];
        if (nicValue != null && nicValue.toString().isNotEmpty) {
          finalCitizenId = nicValue.toString();
          print('Using NIC as citizen_id fallback: $finalCitizenId');
        }
      }

      if (finalCitizenId == null) {
        return ApiResponse.error(
          message: 'User ID not found. Please log in again.',
        );
      }

      // Structure the data as expected by the API
      final requestBody = {'form_data': formData, 'citizen_id': finalCitizenId};

      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/api/forms/$formId/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(
          message: 'Form submitted successfully',
          data: data,
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to submit form',
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      return ApiResponse.error(message: 'Network error: ${e.toString()}');
    }
  }
}
