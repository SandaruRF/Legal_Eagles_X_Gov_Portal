import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePageWithoutLogin extends ConsumerStatefulWidget {
  const HomePageWithoutLogin({super.key});

  @override
  ConsumerState<HomePageWithoutLogin> createState() =>
      _HomePageWithoutLoginState();
}

class _HomePageWithoutLoginState extends ConsumerState<HomePageWithoutLogin> {
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 104,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Stack(
                  children: [
                    // Gov Portal logo and text
                    Positioned(
                      left: screenWidth / 2 - 59.45,
                      top: 12,
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 47,
                            height: 47,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/signup_logo.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Gov Portal text
                          const Text(
                            'Gov Portal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF171717),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // User icon
                    Positioned(
                      right: 22,
                      top: 15,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E1E7),
                          borderRadius: BorderRadius.circular(17.5),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF809FB8),
                          size: 20,
                        ),
                      ),
                    ),

                    // Red notification dot
                    Positioned(
                      right: 22,
                      top: 33,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF0000),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // AI Assistant Section
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
                            // Welcome message
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello! How can I help you with government',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFF404040),
                                      height: 1.21,
                                    ),
                                  ),
                                  Text(
                                    'services today?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFF404040),
                                      height: 1.21,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Search input and send button
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFD4D4D4),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: _questionController,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.black,
                                        height: 1.43,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Type your question...',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xFFADAEBC),
                                          height: 1.43,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 48,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5B00),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      // Handle send question
                                      print(
                                        'Send question: ${_questionController.text}',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Government Assistant info
                            Row(
                              children: [
                                // Avatar with border
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5B00),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Avatar image
                                      Positioned(
                                        left: -9,
                                        top: -11,
                                        child: Container(
                                          width: 63.24,
                                          height: 63.24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              31.62,
                                            ),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                'assets/images/home_chatbot_avatar.png',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Gold border
                                      Positioned(
                                        left: -4,
                                        top: -3,
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFFFEB600),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Government Assistant',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Color(0xFF171717),
                                          height: 1.5,
                                        ),
                                      ),
                                      Text(
                                        'Ask me anything about government services',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xFF737373),
                                          height: 1.43,
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

                      const SizedBox(height: 24),

                      // Government Sectors section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Government Sectors',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF171717),
                              height: 1.56,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              print('See More tapped');
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'See More',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xFF525252),
                                    height: 1.43,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF525252),
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Government sectors grid
                      _buildSectorsGrid(),

                      const SizedBox(height: 32),

                      // Recently Asked Questions
                      const Text(
                        'Recently Asked Questions',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Color(0xFF171717),
                          height: 1.21,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Questions list
                      _buildQuestionsList(),

                      // Bottom padding for navigation
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 82,
        decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
        child: Column(
          children: [
            // Orange highlight bar
            Container(
              width: 74.83,
              height: 3.22,
              margin: const EdgeInsets.only(left: 16.93, top: 4.83),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5B00),
                borderRadius: BorderRadius.circular(1.61),
              ),
            ),
            const SizedBox(height: 12),
            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem('Home', Icons.home, true),
                _buildNavItem('Search', Icons.search, false),
                _buildNavItem('Notification', Icons.notifications, false),
                _buildNavItem('Settings', Icons.settings, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFFFF5B00) : const Color(0xFF85A3BB),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isActive ? const Color(0xFFFF5B00) : const Color(0xFF85A3BB),
            height: 1.57,
          ),
        ),
      ],
    );
  }

  Widget _buildSectorsGrid() {
    return Column(
      children: [
        // First row
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
        // Second row
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
      ],
    );
  }

  Widget _buildSectorCard(String title, String description, String imagePath) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          // Icon with gradient border
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 9),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF171717),
                height: 1.21,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Description
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  color: Color(0xFF737373),
                  height: 1.21,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 17),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    final questions = [
      {'question': 'How to apply for a new passport?', 'time': '2 hours ago'},
      {
        'question': 'What documents needed for marriage certificate?',
        'time': '5 hours ago',
      },
      {'question': 'How to renew driving license online?', 'time': '1 day ago'},
    ];

    return Column(
      children:
          questions
              .map((q) => _buildQuestionCard(q['question']!, q['time']!))
              .toList(),
    );
  }

  Widget _buildQuestionCard(String question, String time) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF404040),
              height: 1.21,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF737373),
              height: 1.21,
            ),
          ),
        ],
      ),
    );
  }
}
