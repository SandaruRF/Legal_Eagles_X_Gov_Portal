import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';

class OnboardingScreen2 extends ConsumerWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE4E4E4),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background rectangle with gradient border radius
          Positioned(
            left: 0,
            top: screenHeight * 0.19, // Responsive positioning
            child: Container(
              width:
                  screenWidth *
                  1.12, // Slightly wider than screen for Pixel Pro 9 XL
              height: screenHeight * 0.96,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                    screenWidth * 0.4,
                  ), // Responsive radius
                ),
              ),
            ),
          ),

          // Main chatbot illustration - centered and responsive
          Positioned(
            left:
                -screenWidth * 0.425, // Responsive centering for larger screens
            top: screenHeight * 0.22,
            child: Container(
              width: screenWidth * 1.87, // Responsive width
              height: screenWidth * 1.87, // Maintain aspect ratio
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/chatbot_illustration.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section with Skip all button
                  SizedBox(height: screenHeight * 0.01), // Small top spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle skip all action
                          print('Skip all pressed');
                        },
                        child: Text(
                          'Skip all',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 16, // Fixed larger font size
                            color: const Color(0xFF8C1F28),
                            height: 1.43,
                            decoration: TextDecoration.underline, // Underline
                            decorationColor: const Color(0xFF8C1F28),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.02), // Much smaller spacing
                  // Progress indicators
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First indicator (filled - black)
                        Container(
                          width: screenWidth * 0.03,
                          height: screenWidth * 0.03,
                          decoration: const BoxDecoration(
                            color: Color(0xFF000000),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.044),

                        // Remaining indicators (gradient filled)
                        for (int i = 0; i < 4; i++) ...[
                          Container(
                            width: screenWidth * 0.03,
                            height: screenWidth * 0.03,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (i < 3) SizedBox(width: screenWidth * 0.044),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * 0.04,
                  ), // Reduced spacing for higher positioning
                  // Main title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08, // Wider padding
                    ),
                    child: Text(
                      'Meet Our Guide',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 36, // Fixed larger font size for beauty
                        color: const Color(0xFF000000),
                        height: 1.2,
                        letterSpacing: 0.5, // Better letter spacing
                      ),
                      textAlign: TextAlign.center, // Center align for beauty
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons positioned at vertical center
          Positioned(
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            top:
                screenHeight * 0.5 -
                30, // Center vertically (half screen height minus half button height)
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left arrow button
                GestureDetector(
                  onTap: () {
                    // Handle back navigation using Riverpod
                    ref.read(navigationProvider.notifier).previousPage();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5B00),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // Right arrow button
                GestureDetector(
                  onTap: () {
                    // Handle forward navigation using Riverpod
                    ref.read(navigationProvider.notifier).nextPage();
                    // Navigate to the third onboarding page
                    Navigator.pushNamed(context, '/onboarding3');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5B00),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
