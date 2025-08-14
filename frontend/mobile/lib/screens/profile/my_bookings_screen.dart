import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
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
                          child: Container(
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

                        // Booking Card
                        Container(
                          width: double.infinity,
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
                                // Title and Mark as Complete button
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Driving License Medical Appointment',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF171717),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Mark as Complete button
                                    Container(
                                      height: 24,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5B00),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Mark as Complete',
                                        style: TextStyle(
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

                                // Submitted date
                                const Text(
                                  'Submitted: January 10, 2025 at 2:30 PM',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF525252),
                                    height: 1.21,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                // Appointment date
                                const Text(
                                  'Appointment: January 15, 2025 at 10:00 AM',
                                  style: TextStyle(
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
                        ),

                        const Spacer(),
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
                  return const ChatbotOverlay();
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
