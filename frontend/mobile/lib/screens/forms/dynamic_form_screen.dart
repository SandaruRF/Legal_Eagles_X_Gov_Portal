import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../core/services/http_client_service.dart';
import '../../core/services/token_storage_service.dart';
import '../../core/config/api_config.dart';
import '../../widgets/dynamic_form_widget.dart';
import '../../models/form_field_model.dart';
import '../../providers/auth_provider.dart';
import '../appointments/appointment_location_screen.dart';

class DynamicFormScreen extends ConsumerStatefulWidget {
  final String formId;
  final String formTitle;

  const DynamicFormScreen({
    super.key,
    required this.formId,
    required this.formTitle,
  });

  @override
  ConsumerState<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends ConsumerState<DynamicFormScreen> {
  void _showPassportSuccessDialog(String pdfUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text(
              'Your passport application was submitted successfully!',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(pdfUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open PDF URL')),
                    );
                  }
                },
                child: const Text('Download PDF'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _navigateToAppointmentBooking({
                    'service_id': "S001",
                    'form_title': widget.formTitle,
                    'pdf_url': pdfUrl,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ],
          ),
    );
  }

  List<FormFieldModel>? formFields;
  bool isLoading = true;
  String? error;
  final HttpClientService _httpClient = HttpClientService();

  @override
  void initState() {
    super.initState();
    _loadFormStructure();
  }

  Future<void> _loadFormStructure() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await _httpClient.get(
        '${ApiConfig.forms}/${widget.formId}',
        fromJson: (data) => data,
      );

      print('Form API Response: ${response.success}');
      print('Form API Data: ${response.data}');
      print('Form API Data Type: ${response.data.runtimeType}');

      if (response.success && response.data != null) {
        // Parse the response - it comes as a string that needs to be decoded
        dynamic parsedData;

        if (response.data is String) {
          parsedData = jsonDecode(response.data as String);
        } else if (response.data is Map) {
          parsedData = response.data as Map<String, dynamic>;
        } else {
          throw Exception('Invalid form data format');
        }

        // Extract form template from the nested structure
        List<dynamic> formJson;

        if (parsedData['form'] != null &&
            parsedData['form']['form_template'] != null) {
          formJson = parsedData['form']['form_template'] as List<dynamic>;
          print(
            'Form fields found in nested structure: ${formJson.length} fields',
          );
        } else if (parsedData['form_template'] != null) {
          formJson = parsedData['form_template'] as List<dynamic>;
          print(
            'Form fields found in direct structure: ${formJson.length} fields',
          );
        } else if (parsedData is List) {
          formJson = parsedData;
          print('Form fields found as direct array: ${formJson.length} fields');
        } else {
          print('Available keys in response: ${parsedData.keys}');
          throw Exception('Form template not found in response');
        }

        final fields =
            formJson
                .map((fieldJson) => FormFieldModel.fromJson(fieldJson))
                .toList();

        setState(() {
          formFields = fields;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load form');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading form...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Color(0xFF737373),
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load form',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF171717),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF737373),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadFormStructure,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (formFields == null || formFields!.isEmpty) {
      return const Center(
        child: Text(
          'No form fields available',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF737373),
          ),
        ),
      );
    }

    return DynamicFormWidget(
      formFields: formFields!,
      formTitle: widget.formTitle,
      onSubmit: _handleFormSubmission,
    );
  }

  Future<void> _handleFormSubmission(Map<String, dynamic> formData) async {
    // Check authentication status first
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      // User is not authenticated, show login dialog
      _showLoginRequiredDialog();
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
                ),
                SizedBox(height: 16),
                Text('Submitting form...'),
              ],
            ),
          ),
    );

    try {
      // Separate files from other form data
      final Map<String, dynamic> textData = {};
      final Map<String, File> fileData = {};

      for (final entry in formData.entries) {
        if (entry.value is File) {
          fileData[entry.key] = entry.value as File;
        } else {
          textData[entry.key] = entry.value;
        }
      }

      // Submit form with files using multipart request
      final response = await _submitFormWithFiles(textData, fileData);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (response['status'] == 'success') {
          // Check if there's a PDF document to download (mainly for passport applications)
          // if (response['pdf_url'] != null && response['pdf_url'].toString().isNotEmpty) {

          //     response['pdf_url'];

          // }

          // Determine next action based on form type

          void _showPassportSuccessDialog(String pdfUrl) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text(
                      'Your passport application was submitted successfully!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final uri = Uri.parse(pdfUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open PDF URL'),
                              ),
                            );
                          }
                        },
                        child: const Text('Download PDF'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _navigateToAppointmentBooking({
                            'service_id': "S001",
                            'form_title': widget.formTitle,
                            'pdf_url': pdfUrl,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5B00),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Next'),
                      ),
                    ],
                  ),
            );
          }

          if (_isPassportApplication()) {
            if (response['pdf_url'] != null &&
                response['pdf_url'].toString().isNotEmpty) {
              // Show dialog with Download PDF and Next buttons
              if (response['pdf_url'].endsWith('?')) {
                response['pdf_url'] = response['pdf_url'].substring(0, response['pdf_url'].length - 1);
              }              
              print('PDF URL: ${response['pdf_url']}');
              _showPassportSuccessDialog(response['pdf_url']);
            } else {
              _showSuccessDialog();
            }
          } else {
            _showSuccessDialog();
          }
        } else {
          throw Exception(response['message'] ?? 'Form submission failed');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show error dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to submit form: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // Assumes the upload endpoint returns a JSON like: {"file_url": "https://..."}
  Future<String?> uploadFile(File file, String uploadUrl) async {
    try {
      final uri = Uri.parse(
        uploadUrl,
      ); // e.g., 'https://api.yourapp.com/api/files/upload'
      final request = http.MultipartRequest('POST', uri);

      // Add authentication headers if needed
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      if (authHeader != null) {
        request.headers['Authorization'] = authHeader;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // The field name the backend expects for the file
          file.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // IMPORTANT: Adjust 'file_url' to match the key in your API's response
        return responseData['file_url'] as String?;
      } else {
        print('File upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _submitFormWithFiles(
    Map<String, dynamic> textData,
    Map<String, File> fileData,
  ) async {
    // --- Step 1: Upload all files and collect their URLs/IDs ---
    // final List<String> uploadedFileUrls = [];
    // for (final file in fileData.values) {
    //   // You need the correct upload URL from your backend team
    //   final String uploadUrl = '${ApiConfig.baseUrl}/api/files/upload';
    //   final url = await uploadFile(file, uploadUrl);
    //   if (url != null) {
    //     uploadedFileUrls.add(url);
    //   } else {
    //     throw Exception('Failed to upload one or more files.');
    //   }
    // }

    // --- Step 2: Add file URLs to your text data and submit as JSON ---
    // The backend will expect the file URLs in a specific field, e.g., 'attachments'
    final Map<String, dynamic> finalPayload = {...textData};

    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/forms/${widget.formId}/submit',
      );
      final authHeader = await TokenStorageService.getAuthorizationHeader();

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
        body: jsonEncode({
          'form_data': finalPayload,
        }), // Structure matches the API doc
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error submitting form: $e');
      throw Exception('Failed to submit form: $e');
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Authentication Required'),
            content: const Text(
              'You need to be logged in to submit forms. Please log in to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ],
          ),
    );
  }

  Future<void> _downloadDocument(String downloadUrl, String filename) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF5B00),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text('Downloading document...'),
                ],
              ),
            ),
      );

      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile, try to open the URL directly (might open in browser/download manager)
        final uri = Uri.parse(downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          if (mounted) {
            Navigator.pop(context); // Close download dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening download: $filename'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Cannot open download URL');
        }
      } else {
        // For other platforms, try to download to local storage
        final response = await HttpClientService().get(downloadUrl);

        if (response.success && response.data != null) {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$filename');

          // This is a simplified approach - in production you'd handle binary data properly
          await file.writeAsString(response.data.toString());

          if (mounted) {
            Navigator.pop(context); // Close download dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Document saved: ${file.path}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to download file');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close download dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isPassportApplication() {
    // Check if this is a passport application based on form title or form ID
    final formTitleLower = widget.formTitle.toLowerCase();
    final formIdLower = widget.formId.toLowerCase();

    return formTitleLower.contains('passport') ||
        formIdLower.contains('passport') ||
        formTitleLower.contains('travel document');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: Text('${widget.formTitle} submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _navigateToAppointmentBooking(
    Map<String, dynamic> formData,
  ) async {
    final serviceId = formData['service_id'] ?? widget.formId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AppointmentLocationScreen(
              serviceId: serviceId,
              formData: formData,
            ),
      ),
    );
  }
}
