import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';

class HomePageSignedIn extends StatefulWidget {
  const HomePageSignedIn({super.key});

  @override
  State<HomePageSignedIn> createState() => _HomePageSignedInState();
}

class _HomePageSignedInState extends State<HomePageSignedIn> {
  void _navigateToChat(String question) {
    // Navigate directly to chat interface with the question
    Navigator.pushNamed(context, '/chat_interface', arguments: question);
  }

  void _navigateToSector(String sectorTitle) {
    // Navigate to the appropriate ministry/sector screen based on title
    switch (sectorTitle) {
      case 'Public Security':
        Navigator.pushNamed(context, '/ministry_public_security');
        break;
      case 'Finance & Planning':
        // Add navigation for finance & planning when the screen is created
        // Navigator.pushNamed(context, '/ministry_finance_planning');
        break;
      case 'Public Administration':
        // Add navigation for public administration when the screen is created
        // Navigator.pushNamed(context, '/ministry_public_administration');
        break;
      case 'Health':
        // Add navigation for health when the screen is created
        // Navigator.pushNamed(context, '/ministry_health');
        break;
      default:
        // Show a coming soon message or navigate to government sectors screen
        Navigator.pushNamed(context, '/government_sectors');
        break;
    }
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.white,
          ),

          // Header
          Container(
            width: double.infinity,
            height: 104,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 33.5), // Balance space
                    // Gov Portal logo and text
                    Row(
                      children: [
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
                          ),
                        ),
                      ],
                    ),

                    // User icon with online indicator
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF809FB8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF27D79E),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chatbot section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chatbot profile
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 48,
                                  height: 49,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFF5B00),
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/home_chatbot_avatar.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -3,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFFEB600),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Government Assistant',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF171717),
                                    ),
                                  ),
                                  Text(
                                    'Ask me anything about government services',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF737373),
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Greeting message
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Hello! How can I help you with government services today?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF404040),
                              height: 1.21,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Input and send button
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/government_assistant',
                                  );
                                },
                                child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD4D4D4),
                                    ),
                                  ),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Type your question...',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFADAEBC),
                                        height: 1.43,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/government_assistant',
                                );
                              },
                              child: Container(
                                width: 48,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5B00),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Digital Vault section
                  const Text(
                    'Digital Vault',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF171717),
                      height: 1.56,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/digital_vault');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 148,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF8C1F28), Color(0xFFFF5B00)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top section with title and arrow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Digital Identity Card',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.33,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Name of the Card',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.56,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Bottom section with details
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Valid Until',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.33,
                                    ),
                                  ),
                                  Text(
                                    '12/2030',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Citizen ID',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.33,
                                    ),
                                  ),
                                  Text(
                                    '199812345678',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Government Sectors section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Government Sectors',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF171717),
                          height: 1.56,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/government_sectors');
                        },
                        child: Row(
                          children: [
                            const Text(
                              'See More',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF525252),
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFF525252),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Government sectors grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectorCard(
                          'Public Administration',
                          'NIC, Passport, Birth & Death Certificates, Land Records',
                          'assets/images/home_public_admin.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSectorCard(
                          'Public Security',
                          'Police Services, Crime Reports, Emergency Services',
                          'assets/images/home_public_security.png',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSectorCard(
                          'Finance & Planning',
                          'Business Registration, Job Portal, EPF/ETF Services',
                          'assets/images/home_finance_planning.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSectorCard(
                          'Health',
                          'Medical Records, Hospital Appointments, Public Health Announcements',
                          'assets/images/home_health.png',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Recently Asked Questions section
                  const Text(
                    'Recently Asked Questions',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF171717),
                      height: 1.21,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Question cards
                  _buildQuestionCard(
                    'How to apply for a new passport?',
                    '2 hours ago',
                  ),

                  const SizedBox(height: 12),

                  _buildQuestionCard(
                    'What documents needed for birth certificate?',
                    '5 hours ago',
                  ),

                  const SizedBox(height: 12),

                  _buildQuestionCard(
                    'How to renew driving license online?',
                    '1 day ago',
                  ),

                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 82,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F2),
          border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.search,
              label: 'Search',
              isSelected: false,
              onTap: () {
                Navigator.pushNamed(context, '/search');
              },
            ),
            _buildNavItem(
              icon: Icons.notifications,
              label: 'Notification',
              isSelected: false,
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: false,
              onTap: _navigateToSettings,
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: Container(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildQuestionCard(String question, String time) {
    return GestureDetector(
      onTap: () => _navigateToChat(question),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF404040),
                      height: 1.21,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 15,
                  color: Color(0xFF809FB8),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF737373),
                height: 1.21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorCard(String title, String description, String imagePath) {
    return GestureDetector(
      onTap: () => _navigateToSector(title),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: const Color(0xFFFF5B00)),
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF171717),
                height: 1.21,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF737373),
                  height: 1.21,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? const Color(0xFFFF5B00) : const Color(0xFF85A3BB),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isSelected
                      ? const Color(0xFFFF5B00)
                      : const Color(0xFF85A3BB),
              height: 1.57,
            ),
          ),
        ],
      ),
    );
  }
}
