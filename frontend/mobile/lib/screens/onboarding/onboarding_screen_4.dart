import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/navigation_debug_widget.dart';

class OnboardingScreen4 extends ConsumerWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Debug widget
          const NavigationDebugWidget(),

          // Background illustration image
          Positioned(
            left: -screenWidth * 0.058,
            top: screenHeight * 0.49,
            child: Container(
              width: screenWidth * 1.11,
              height: screenWidth * 1.11,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/onboarding4_illustration.png',
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
                  SizedBox(height: screenHeight * 0.125),
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
                      // Dot 3 (current - black)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black,
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
                      // Dot 5
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
                    ],
                  ),

                  // Skip all button
                  SizedBox(height: screenHeight * 0.02),
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
                          fontSize: 14,
                          color: const Color(0xFF8C1F28),
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Main title
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.058),
                    child: Text(
                      'Guidance to fill your forms',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        color: Colors.black,
                        height: 1.21,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.058),
                    child: Text(
                      'Mention about form filling',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                        color: Colors.black,
                        height: 1.65,
                      ),
                    ),
                  ),

                  // Spacer to push navigation buttons to bottom
                  const Spacer(),

                  // Navigation arrows (left and right)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: bottomPadding + 20,
                      left: screenWidth * 0.02,
                      right: screenWidth * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left arrow button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(navigationProvider.notifier)
                                .previousPage();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5B00),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),

                        // Right arrow button
                        GestureDetector(
                          onTap: () {
                            ref.read(navigationProvider.notifier).nextPage();
                            Navigator.pushNamed(context, '/onboarding5');
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5B00),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
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
        ],
      ),
    );
  }
}
