import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';

class OnboardingScreen6 extends ConsumerWidget {
  const OnboardingScreen6({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background illustration image
          Positioned(
            left: -screenWidth * 0.175,
            top: screenHeight * 0.52,
            child: Container(
              width: screenWidth * 1.18,
              height: screenWidth * 1.18,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/onboarding6_illustration.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicators at the top
                  SizedBox(height: screenHeight * 0.03), // Much smaller spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dot 1
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.043),
                      // Dot 2
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.043),
                      // Dot 3
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.043),
                      // Dot 4
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.043),
                      // Dot 5 (current - black)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: screenHeight * 0.01,
                  ), // Small spacing for consistent height
                  // Skip all button (adding it since it's missing in screen 6)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(navigationProvider.notifier)
                            .completeOnboarding();
                        print('Skip all pressed - Navigate to main app');
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
                  ),

                  SizedBox(
                    height: screenHeight * 0.06,
                  ), // Reduced spacing for higher positioning
                  // Main title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ), // Wider padding
                    child: Text(
                      'Book and Schedule for any service',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 36, // Fixed larger font size
                        color: Colors.black,
                        height: 1.2,
                        letterSpacing: 0.5, // Better letter spacing
                      ),
                      textAlign: TextAlign.center, // Center align for beauty
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ), // Wider padding
                    child: Text(
                      'Mention about Booking and scheduling',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 20, // Fixed larger font size
                        color: Colors.black,
                        height: 1.4,
                        letterSpacing: 0.3, // Better letter spacing
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
                    ref.read(navigationProvider.notifier).previousPage();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5B00),
                      shape: BoxShape.circle,
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
                    ref.read(navigationProvider.notifier).nextPage();
                    ref.read(navigationProvider.notifier).completeOnboarding();
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5B00),
                      shape: BoxShape.circle,
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
