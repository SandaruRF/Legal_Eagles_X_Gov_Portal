import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../core/services/token_storage_service.dart';
import '../../core/config/environment_config.dart';

class AppointmentDocumentUploadScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String locationId;
  final String slotId;
  final String selectedDate;
  final Map<String, dynamic> formData;

  const AppointmentDocumentUploadScreen({
    super.key,
    required this.serviceId,
    required this.locationId,
    required this.slotId,
    required this.selectedDate,
    required this.formData,
  });

  @override
  ConsumerState<AppointmentDocumentUploadScreen> createState() =>
      _AppointmentDocumentUploadScreenState();
}

class _AppointmentDocumentUploadScreenState
    extends ConsumerState<AppointmentDocumentUploadScreen> {
  List<Map<String, dynamic>> requiredDocuments = [];
  Map<String, File?> uploadedFiles = {};
  bool isLoading = true;
  String? error;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadRequiredDocuments();
  }

  Future<void> _loadRequiredDocuments() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // For now, we'll use mock data. In a real app, this would come from an API
      // based on the service type
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

      setState(() {
        requiredDocuments = [
          {
            'id': 'national_id',
            'name': 'National ID Card',
            'description': 'Clear photo of both sides of your national ID card',
            'required': true,
            'accepted_formats': ['jpg', 'jpeg', 'png', 'pdf'],
          },
          {
            'id': 'supporting_docs',
            'name': 'Supporting Documents',
            'description': 'Any additional documents related to your application',
            'required': false,
            'accepted_formats': ['jpg', 'jpeg', 'png', 'pdf'],
          },
        ];

        // Initialize uploaded files map
        for (var doc in requiredDocuments) {
          uploadedFiles[doc['id']] = null;
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _pickFile(String documentId) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options for camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: const Column(
                      children: [
                        Icon(Icons.camera_alt, size: 48, color: Color(0xFFFF5B00)),
                        SizedBox(height: 8),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: const Column(
                      children: [
                        Icon(Icons.photo_library, size: 48, color: Color(0xFFFF5B00)),
                        SizedBox(height: 8),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            uploadedFiles[documentId] = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile(String documentId) {
    setState(() {
      uploadedFiles[documentId] = null;
    });
  }

  bool _areRequiredDocumentsUploaded() {
    for (var doc in requiredDocuments) {
      if (doc['required'] == true && uploadedFiles[doc['id']] == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _bookAppointment() async {
    if (!_areRequiredDocumentsUploaded()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isBooking = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
            ),
            SizedBox(height: 16),
            Text('Booking appointment...'),
          ],
        ),
      ),
    );

    try {
      // Build URL with query parameters
      final uri = Uri.parse('${EnvironmentConfig.baseUrl}${EnvironmentConfig.appointmentBook}').replace(
        queryParameters: {
          'service_id': widget.serviceId,
          'slot_id': widget.slotId,
        },
      );

      final authHeader = await TokenStorageService.getAuthorizationHeader();

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      if (authHeader != null) {
        request.headers['Authorization'] = authHeader;
      }

      // Add form fields
      request.fields['location_id'] = widget.locationId;
      request.fields['date'] = widget.selectedDate;
      request.fields['citizen_id'] = '12345'; // TODO: Get from user context
      request.fields['form_data'] = jsonEncode(widget.formData);

      // Add uploaded files
      for (var entry in uploadedFiles.entries) {
        if (entry.value != null) {
          final file = entry.value!;
          final multipartFile = await http.MultipartFile.fromPath(
            'files',
            file.path,
            filename: '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
          );
          request.files.add(multipartFile);
        }
      }

      // If no files uploaded, add empty field
      if (request.files.isEmpty) {
        request.files.add(http.MultipartFile.fromString('files', ''));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('DEBUG: Booking response status: ${response.statusCode}');
      print('DEBUG: Booking response body: ${response.body}');

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          isBooking = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          _showSuccessDialog(responseData);
        } else {
          throw Exception(response.body);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          isBooking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> appointmentData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Booked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your appointment has been successfully booked.'),
            const SizedBox(height: 16),
            if (appointmentData['appointment_id'] != null)
              Text('Appointment ID: ${appointmentData['appointment_id']}'),
            if (appointmentData['reference_number'] != null)
              Text('Reference: ${appointmentData['reference_number']}'),
            const SizedBox(height: 8),
            Text('Date: ${widget.selectedDate}'),
            const SizedBox(height: 16),
            const Text(
              'Please arrive 15 minutes before your scheduled time and bring the original documents.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ); // Go back to home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        backgroundColor: const Color(0xFFFF5B00),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      bottomNavigationBar: _areRequiredDocumentsUploaded() && !isBooking
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading documents',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequiredDocuments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header info
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5B00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFF5B00).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFF5B00)),
                  SizedBox(width: 8),
                  Text(
                    'Document Requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5B00),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload clear, readable photos or scans of the required documents. All documents should be valid and not expired.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Appointment Date: ${widget.selectedDate}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // Document list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: requiredDocuments.length,
            itemBuilder: (context, index) {
              final document = requiredDocuments[index];
              final documentId = document['id'];
              final uploadedFile = uploadedFiles[documentId];
              final isRequired = document['required'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              document['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Required',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        document['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accepted formats: ${(document['accepted_formats'] as List).join(', ').toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (uploadedFile != null) ...[
                        // File uploaded
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'File uploaded: ${uploadedFile.path.split('/').last}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeFile(documentId),
                                icon: const Icon(Icons.close, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _pickFile(documentId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Replace File'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF5B00),
                            side: const BorderSide(color: Color(0xFFFF5B00)),
                          ),
                        ),
                      ] else ...[
                        // No file uploaded
                        ElevatedButton.icon(
                          onPressed: () => _pickFile(documentId),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5B00),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
