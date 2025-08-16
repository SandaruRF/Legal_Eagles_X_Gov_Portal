import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/navigation_debug_widget.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'English';
  String tempSelectedLanguage = 'English'; // For UI display only
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 2.0, // Start at English position (rightmost)
      end: 2.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
      tempSelectedLanguage = language;
    });

    // Update app language immediately when user selects a language
    String languageCode;
    switch (language) {
      case 'Sinhala':
        languageCode = 'si';
        break;
      case 'Tamil':
        languageCode = 'ta';
        break;
      case 'English':
      default:
        languageCode = 'en';
        break;
    }

    // Change app language immediately
    ref.read(languageProvider.notifier).changeLanguage(languageCode);

    double targetPosition;
    switch (language) {
      case 'Sinhala':
        targetPosition = 0.0; // Leftmost position
        break;
      case 'Tamil':
        targetPosition = 1.0; // Middle position
        break;
      case 'English':
      default:
        targetPosition = 2.0; // Rightmost position
        break;
    }

    _slideAnimation = Tween<double>(
      begin: _slideAnimation.value,
      end: targetPosition,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Debug widget
          const NavigationDebugWidget(),

          // Background image - positioned exactly as in Figma design
          Positioned(
            left:
                -(screenWidth *
                    0.7), // Enlarged: moved further left for better coverage
            top:
                -(screenHeight *
                    0.06), // Enlarged: moved further up for better coverage
            child: Container(
              width: screenWidth * 2.6, // Enlarged: increased from 2.26 to 2.6
              height:
                  screenWidth * 2.6, // Enlarged: square aspect ratio maintained
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_top.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Full-screen content container
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                left: 21,
                right: 21,
                top:
                    topPadding +
                    (screenHeight * 0.05), // Account for notch plus spacing
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.07,
                      left: screenWidth * 0.18,
                    ),
                    child: Text(
                      'Gov Portal',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: screenWidth * 0.1,
                        color: const Color(0xFF171717),
                        height: 0.6,
                      ),
                    ),
                  ),

                  // Main illustration
                  Expanded(
                    flex:
                        2, // Reduced from 3 to 2 to give more space to bottom content
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * 0.9,
                          maxHeight:
                              screenHeight * 0.35, // Slightly reduced height
                        ),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/main_illustration.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Additional spacing to push language selection higher
                  SizedBox(height: screenHeight * 0.02),

                  // Bottom section with language selection and button
                  Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          bottomPadding +
                          30, // Increased padding to move content higher
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Language selection label
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 8),
                          child: Text(
                            AppLocalizations.of(context)!.selectLanguage,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: screenWidth * 0.04,
                              color: Colors.black,
                              height: 1.3125,
                            ),
                          ),
                        ),

                        // Language selection container with sliding animation
                        Container(
                          height: 53,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8C1F28), Color(0xFFFF5B00)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Sliding white button
                              AnimatedBuilder(
                                animation: _slideAnimation,
                                builder: (context, child) {
                                  final containerWidth =
                                      screenWidth -
                                      42; // Total width minus horizontal margins
                                  final separatorWidth =
                                      2; // Width of separators
                                  final totalSeparatorWidth =
                                      separatorWidth * 2; // Two separators
                                  final availableWidth =
                                      containerWidth -
                                      16 -
                                      totalSeparatorWidth; // Subtract padding and separators
                                  final buttonWidth =
                                      availableWidth /
                                      3; // Width of one section
                                  final sectionWidth =
                                      (containerWidth - 16) /
                                      3; // Total section width including separators
                                  final leftPosition =
                                      8 +
                                      (_slideAnimation.value * sectionWidth);

                                  return Positioned(
                                    left: leftPosition,
                                    top: 8,
                                    child: Container(
                                      width:
                                          buttonWidth > 0
                                              ? buttonWidth
                                              : 80, // Fallback width if calculation fails
                                      height: 37,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            offset: const Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Language options
                              Row(
                                children: [
                                  // Sinhala
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectLanguage('Sinhala'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'සිංහල',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.05,
                                            color:
                                                selectedLanguage == 'Sinhala'
                                                    ? const Color(0xFF1C120D)
                                                    : Colors.white,
                                            height: 1.05,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Separator line
                                  Container(
                                    width: 1,
                                    height: 37,
                                    color: Colors.white.withOpacity(0.3),
                                  ),

                                  // Tamil
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectLanguage('Tamil'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'தமிழ்',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: screenWidth * 0.05,
                                            color:
                                                selectedLanguage == 'Tamil'
                                                    ? const Color(0xFF1C120D)
                                                    : Colors.white,
                                            height: 1.05,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Separator line
                                  Container(
                                    width: 1,
                                    height: 37,
                                    color: Colors.white.withOpacity(0.3),
                                  ),

                                  // English
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectLanguage('English'),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'English',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenWidth * 0.05,
                                            color:
                                                selectedLanguage == 'English'
                                                    ? const Color(0xFF1C120D)
                                                    : Colors.white,
                                            height: 1.05,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // Reduced from 0.03 to 0.02
                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          height: 53,
                          child: ElevatedButton(
                            onPressed: () {
                              // Use Riverpod to navigate to the second onboarding screen
                              ref.read(navigationProvider.notifier).nextPage();
                              Navigator.pushNamed(context, '/onboarding2');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5B00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.63),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.getStarted,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                height: 1.21,
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
        ],
      ),
    );
  }
}
