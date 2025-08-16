import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';

class MinistryPublicSecurityScreen extends StatefulWidget {
  const MinistryPublicSecurityScreen({super.key});

  @override
  State<MinistryPublicSecurityScreen> createState() =>
      _MinistryPublicSecurityScreenState();
}

class _MinistryPublicSecurityScreenState
    extends State<MinistryPublicSecurityScreen> {
  final List<Map<String, dynamic>> _departments = [
    {
      'title': 'Sri Lanka Police',
      'description': '',
      'icon': 'assets/images/ministry_public_security/sri_lanka_police.png',
    },
    {
      'title': 'National Secretariat for Non-Governmental Organizations',
      'description': '',
      'icon': 'assets/images/ministry_public_security/ngo_secretariat.png',
    },
    {
      'title': 'National Dangerous Drugs Control Board',
      'description': '',
      'icon': 'assets/images/ministry_public_security/drugs_control_board.png',
    },
    {
      'title': 'National Police Academy',
      'description': '',
      'icon': 'assets/images/ministry_public_security/police_academy.png',
    },
    {
      'title': 'Department of Immigration and Emigration',
      'description': '',
      'icon':
          'assets/images/ministry_public_security/immigration_emigration.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFFFAFAFA),
          ),

          // Header
          Container(
            width: double.infinity,
            height: 82,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Color(0xFF525252),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Title
                const Expanded(
                  child: Text(
                    'Ministry of Public Security',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                      height: 1.11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Description text
                    const Text(
                      'Access services and information from various departments under the Ministry of Public Security.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF737373),
                        height: 1.43,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Departments list
                    for (int i = 0; i < _departments.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDepartmentCard(_departments[i]),
                      ),

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: const CustomBottomNavigationBar(currentPage: 'home'),

      // Floating Action Button for Chatbot
      floatingActionButton: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                  return const ChatbotOverlay(
                    currentPage: 'Ministry Public Security',
                  );
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> department) {
    return GestureDetector(
      onTap: () {
        if (department['title'] == 'Department of Immigration and Emigration') {
          Navigator.pushNamed(context, '/immigration_emigration');
        }
      },
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon section
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: const Color(0xFFFF5B00)),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: AssetImage(department['icon']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      department['title'],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF171717),
                        height: 1.21,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (department['description'].isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        department['description'],
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF737373),
                          height: 1.21,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.43),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF809FB8),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
