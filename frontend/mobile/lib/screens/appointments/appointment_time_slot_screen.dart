import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/http_client_service.dart';
import '../../core/services/token_storage_service.dart';
import '../../core/config/environment_config.dart';

class AppointmentTimeSlotScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String locationId;
  final Map<String, dynamic> formData;

  const AppointmentTimeSlotScreen({
    super.key,
    required this.serviceId,
    required this.locationId,
    required this.formData,
  });

  @override
  ConsumerState<AppointmentTimeSlotScreen> createState() =>
      _AppointmentTimeSlotScreenState();
}

class _AppointmentTimeSlotScreenState
    extends ConsumerState<AppointmentTimeSlotScreen> {
  Map<String, List<Map<String, dynamic>>>?
  availableSlots; // Date -> List of slots
  bool isLoading = true;
  String? error;
  String? selectedDate;
  String? selectedSlotId;
  final HttpClientService _httpClient = HttpClientService();

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    print('DEBUG: _loadAvailableSlots called');
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Use raw HTTP client instead of HttpClientService
      final uri = Uri.parse('${EnvironmentConfig.baseUrl}${EnvironmentConfig.appointmentSlots}/${widget.serviceId}/${widget.locationId}');
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
      );

      print('DEBUG: HTTP response status: ${response.statusCode}');
      print('DEBUG: HTTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('DEBUG: Parsed response data: $responseData');

        if (responseData['status'] == 'success' && responseData['available_slots'] != null) {
          // Group slots by date
          final Map<String, List<Map<String, dynamic>>> groupedSlots = {};

          final List<dynamic> slotsList = responseData['available_slots'];
          for (var slot in slotsList) {
            final date = slot['date'] ?? '';
            if (!groupedSlots.containsKey(date)) {
              groupedSlots[date] = [];
            }
            groupedSlots[date]!.add(Map<String, dynamic>.from(slot));
          }

          print('DEBUG: Grouped slots: $groupedSlots');
          setState(() {
            availableSlots = groupedSlots;
            isLoading = false;
            // Select first available date
            if (groupedSlots.isNotEmpty) {
              selectedDate = groupedSlots.keys.first;
            }
          });
        } else {
          throw Exception('Invalid response format or no available slots');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Exception in _loadAvailableSlots: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (selectedSlotId == null || selectedDate == null) return;

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
                Text('Booking appointment...'),
              ],
            ),
          ),
    );

    try {
      final bookingData = {
        'service_id': widget.serviceId,
        'location_id': widget.locationId,
        'slot_id': selectedSlotId,
        'date': selectedDate,
        'citizen_id': '12345', // TODO: Get from user context
        'form_data': widget.formData,
      };

      final response = await _httpClient.post(
        EnvironmentConfig.appointmentBook,
        body: bookingData,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (response.success) {
          _showSuccessDialog(response.data);
        } else {
          throw Exception(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(dynamic appointmentData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Appointment Booked!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your appointment has been successfully booked.'),
                const SizedBox(height: 16),
                if (appointmentData is Map<String, dynamic>) ...[
                  if (appointmentData['appointment_id'] != null)
                    Text(
                      'Appointment ID: ${appointmentData['appointment_id']}',
                    ),
                  if (appointmentData['reference_number'] != null)
                    Text('Reference: ${appointmentData['reference_number']}'),
                  const SizedBox(height: 8),
                  Text('Date: $selectedDate'),
                  if (selectedSlotId != null) ...[
                    Text('Time: ${_getSelectedSlotTime()}'),
                  ],
                ],
                const SizedBox(height: 16),
                const Text(
                  'Please arrive 15 minutes before your scheduled time.',
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

  Widget _buildTimeSlots(List<Map<String, dynamic>> slots) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final slotId = slot['slot_id'].toString();
        final isSelected = selectedSlotId == slotId;
        final isAvailable = slot['available'] == true;

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  setState(() {
                    selectedSlotId = slotId;
                  });
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: !isAvailable
                  ? Colors.grey.shade200
                  : isSelected
                      ? const Color(0xFFFF5B00)
                      : Colors.white,
              border: Border.all(
                color: !isAvailable
                    ? Colors.grey.shade400
                    : isSelected
                        ? const Color(0xFFFF5B00)
                        : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot['time'] ?? '',
                    style: TextStyle(
                      color: !isAvailable
                          ? Colors.grey
                          : isSelected
                              ? Colors.white
                              : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (slot['officer'] != null && slot['officer']['name'] != null)
                    Text(
                      slot['officer']['name'],
                      style: TextStyle(
                        color: !isAvailable
                            ? Colors.grey
                            : isSelected
                                ? Colors.white70
                                : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getSelectedSlotTime() {
    if (selectedDate == null ||
        selectedSlotId == null ||
        availableSlots == null) {
      return '';
    }

    final slots = availableSlots![selectedDate!];
    if (slots != null) {
      final selectedSlot = slots.firstWhere(
        (slot) => slot['slot_id'].toString() == selectedSlotId,
        orElse: () => {},
      );
      return selectedSlot['time'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
        backgroundColor: const Color(0xFFFF5B00),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      bottomNavigationBar:
          selectedSlotId != null
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
              'Error loading time slots',
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
              onPressed: _loadAvailableSlots,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (availableSlots == null || availableSlots!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No time slots available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please try selecting a different location or check back later.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Date selector
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: availableSlots!.keys.length,
            itemBuilder: (context, index) {
              final date = availableSlots!.keys.elementAt(index);
              final isSelected = selectedDate == date;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    selectedSlotId = null; // Reset slot selection
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF5B00) : Colors.white,
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFFFF5B00)
                              : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDayName(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Time slots for selected date
        Expanded(
          child:
              selectedDate != null && availableSlots![selectedDate] != null
                  ? _buildTimeSlots(availableSlots![selectedDate]!)
                  : const Center(
                    child: Text('Select a date to view available time slots'),
                  ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }
}
