import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../models/appointment.dart';
import '../../core/services/appointments_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final AppointmentsService _appointmentsService = AppointmentsService();
  List<Appointment> _allAppointments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAllBookings();
  }

  Future<void> _fetchAllBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch appointments from all 4 statuses
      final List<Future<dynamic>> futures = [
        _appointmentsService.getAppointmentsByStatus('Completed'),
        _appointmentsService.getAppointmentsByStatus('Confirmed'),
        _appointmentsService.getAppointmentsByStatus('Booked'),
        _appointmentsService.getAppointmentsByStatus('Cancelled'),
      ];

      final responses = await Future.wait(futures);

      List<Appointment> allAppointments = [];

      for (var response in responses) {
        if (response.success && response.data != null) {
          allAppointments.addAll(response.data!);
        }
      }

      setState(() {
        _allAppointments = allAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load bookings: ${e.toString()}';
        _isLoading = false;
      });
    }
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
                              const SizedBox(width: 12),
                              const Text(
                                'Gov Portal',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF171717),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 24), // Balance the back button
                      ],
                    ),
                  ),
                ),

                // Page Title Section (My Bookings title)
                Container(
                  width: double.infinity,
                  height: 64,
                  color: const Color(0xFFFAFAFA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'My Bookings',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF171717),
                        height: 1.21,
                      ),
                    ),
                  ),
                ),

                // Content Section
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Section title
                        const Text(
                          'My Bookings',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
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
                                  : _allAppointments.isEmpty
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
              bottom: -10, // Lowered by 10 pixels to match past bookings
              left: 0,
              right: 0,
              child: const CustomBottomNavigationBar(
                currentPage: 'my_bookings',
              ),
            ),

            // Floating Action Button for Chatbot
            _buildFloatingChatbotButton(),
          ],
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
          const Text(
            'Error Loading Bookings',
            style: TextStyle(
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
            onPressed: _fetchAllBookings,
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Color(0xFF737373),
          ),
          SizedBox(height: 16),
          Text(
            'No Bookings Found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You don\'t have any appointments yet.',
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
      onRefresh: _fetchAllBookings,
      color: const Color(0xFFFF5B00),
      child: ListView.builder(
        itemCount: _allAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _allAppointments[index];
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
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF279541);
      case 'confirmed':
        return const Color(0xFF2563EB);
      case 'booked':
        return const Color(0xFFFF5B00);
      case 'cancelled':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF737373);
    }
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
                  return const ChatbotOverlay(currentPage: 'My Bookings');
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
}
