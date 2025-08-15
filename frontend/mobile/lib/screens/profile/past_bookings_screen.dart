import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../models/appointment.dart';
import '../../core/services/appointments_service.dart';

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
      final response = await _appointmentsService.getCompletedAppointments();

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

                        // Notification icon
                        Container(
                          width: 18.74,
                          height: 14.56,
                          margin: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.notifications_outlined,
                            size: 18,
                            color: Color(0xFF525252),
                          ),
                        ),

                        // Avatar
                        Container(
                          width: 53,
                          height: 53,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              // Outer circle with border
                              Container(
                                width: 53,
                                height: 53,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF384455),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/avatar_image-56586a.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              // Online status indicator
                              Positioned(
                                right: 1.5,
                                bottom: 1.5,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF27D79E),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Page Title Section
                Container(
                  width: double.infinity,
                  height: 64,
                  color: const Color(0xFFFAFAFA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Past Bookings',
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
                          'Past Bookings',
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
            _buildBottomNavigation(),

            // Floating Action Button for Chatbot
            _buildFloatingChatbotButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 88,
        color: const Color(0xFFF2F2F2),
        child: Column(
          children: [
            // Tab bar icons
            Container(
              height: 46.25,
              padding: const EdgeInsets.symmetric(
                horizontal: 41.22,
                vertical: 9.3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavIcon(Icons.home, false),
                  _buildNavIcon(Icons.search, false),
                  _buildNavIcon(Icons.notifications, false),
                  _buildNavIcon(Icons.settings, false),
                ],
              ),
            ),
            // Tab bar labels
            Container(
              height: 35.01,
              padding: const EdgeInsets.symmetric(horizontal: 37.69),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF85A3BB),
                      height: 1.83,
                    ),
                  ),
                  Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF85A3BB),
                      height: 1.83,
                    ),
                  ),
                  Text(
                    'Notification',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF85A3BB),
                      height: 1.83,
                    ),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF85A3BB),
                      height: 1.83,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return SizedBox(
      width: 23.33,
      height: 26.65,
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? const Color(0xFFFF5B00) : const Color(0xFF809FB8),
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
