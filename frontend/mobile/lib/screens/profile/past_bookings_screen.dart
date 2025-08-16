import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../models/appointment.dart';
import '../../core/services/appointments_service.dart';
import '../../core/services/token_storage_service.dart';
import '../../core/config/environment_config.dart';

class PastBookingsScreen extends StatefulWidget {
  const PastBookingsScreen({super.key});

  @override
  State<PastBookingsScreen> createState() => _PastBookingsScreenState();
}

class _PastBookingsScreenState extends State<PastBookingsScreen> {
  final AppointmentsService _appointmentsService = AppointmentsService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPastBookings();
  }

  Future<void> _fetchPastBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _appointmentsService.getAppointmentsByStatus(
        'Completed',
      );

      if (response.success && response.data != null) {
        setState(() {
          _appointments = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load past bookings: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview(String appointmentId, int rating, String comment) async {
    try {
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      final uri = Uri.parse('${EnvironmentConfig.baseUrl}/api/citizen/feedback/citizen/feedback/submit');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
        body: jsonEncode({
          'appointment_id': appointmentId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReviewDialog(Appointment appointment) {
    int selectedRating = 5;
    String comment = '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Rate Your Experience',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service: ${appointment.serviceName}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF525252),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rating:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              index < selectedRating ? Icons.star : Icons.star_border,
                              color: const Color(0xFFFF5B00),
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Comment (Optional):',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFF5B00)),
                        ),
                      ),
                      onChanged: (value) {
                        comment = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF525252),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitReview(appointment.appointmentId, selectedRating, comment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5B00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  height: 103,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 17.5,
                            height: 20,
                            child: const Icon(
                              Icons.arrow_back_ios,
                              size: 15,
                              color: Color(0xFF525252),
                            ),
                          ),
                        ),

                        // Gov Portal centered with logo
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Gov logo
                              Container(
                                width: 47,
                                height: 47,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/images/gov_portal_logo.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Gov Portal',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF171717),
                                  height: 1.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Section
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        // Section title
                        const Text(
                          'Past Bookings',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF171717),
                            height: 1.56,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Content based on loading state
                        Expanded(
                          child:
                              _isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFF5B00),
                                    ),
                                  )
                                  : _errorMessage.isNotEmpty
                                  ? _buildErrorWidget()
                                  : _appointments.isEmpty
                                  ? _buildEmptyWidget()
                                  : _buildAppointmentsList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Navigation
            Positioned(
              bottom: -10, // Lowered by 10 pixels
              left: 0,
              right: 0,
              child: const CustomBottomNavigationBar(
                currentPage: 'past_bookings',
              ),
            ),

            // Floating Action Button for Chatbot
            _buildFloatingChatbotButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingChatbotButton() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.transparent,
                builder: (BuildContext context) {
                  return const ChatbotOverlay(currentPage: 'Past Bookings');
                },
              );
            },
            child: const Center(
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF737373)),
          const SizedBox(height: 16),
          Text(
            'Error Loading Past Bookings',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF737373),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchPastBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Color(0xFF737373),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Past Bookings',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any completed appointments yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: _fetchPastBookings,
      color: const Color(0xFFFF5B00),
      child: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF171717),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    appointment.status,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.21,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),

            // Reference Number
            Text(
              'Reference: ${appointment.referenceNumber}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF525252),
                height: 1.21,
              ),
            ),
            const SizedBox(height: 7),

            // Submitted date
            Text(
              'Submitted: ${appointment.formattedCreatedDateTime}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF525252),
                height: 1.21,
              ),
            ),
            const SizedBox(height: 7),

            // Appointment date
            Text(
              'Appointment: ${appointment.formattedAppointmentDateTime}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF525252),
                height: 1.21,
              ),
            ),
            const SizedBox(height: 7),

            // Address
            Text(
              'Address: ${appointment.address}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF525252),
                height: 1.21,
              ),
            ),
            const SizedBox(height: 12),

            // Review Button
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _showReviewDialog(appointment),
                icon: const Icon(
                  Icons.star_border,
                  size: 16,
                  color: Color(0xFFFF5B00),
                ),
                label: const Text(
                  'Review',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF5B00),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF5B00)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF279541);
      case 'pending':
        return const Color(0xFFFF5B00);
      case 'cancelled':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF737373);
    }
  }
}
