import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../providers/user_provider.dart';

class HomePageSignedIn extends ConsumerStatefulWidget {
  const HomePageSignedIn({super.key});

  @override
  ConsumerState<HomePageSignedIn> createState() => _HomePageSignedInState();
}

class _HomePageSignedInState extends ConsumerState<HomePageSignedIn> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).fetchUserProfile();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    final backgroundColor =
        isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFFAFAFA);
    final headerColor = isDarkMode ? const Color(0xFF374151) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final borderColor =
        isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: headerColor,
          ),

          // Header
          Container(
            width: double.infinity,
            height: 104,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(bottom: BorderSide(color: borderColor, width: 1)),
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
                        Text(
                          AppLocalizations.of(context)!.govPortal,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
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
                      color:
                          isDarkMode ? const Color(0xFF374151) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.governmentAssistant,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.askMeAnything,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          isDarkMode
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF737373),
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
                            color:
                                isDarkMode
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.helloGreeting,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color:
                                  isDarkMode
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF404040),
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
                                    color:
                                        isDarkMode
                                            ? const Color(0xFF4B5563)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          isDarkMode
                                              ? const Color(0xFF6B7280)
                                              : const Color(0xFFD4D4D4),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.typeYourQuestion,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isDarkMode
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFFADAEBC),
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
                  Text(
                    AppLocalizations.of(context)!.digitalVault,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: textColor,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.digitalIdentityCard,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.33,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.fullName ?? 'Loading...',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.56,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.created,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.33,
                                    ),
                                  ),
                                  Text(
                                    user?.createdAt != null
                                        ? () {
                                          final date = user!.createdAt!;
                                          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                                        }()
                                        : 'Loading...',
                                    style: const TextStyle(
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
                                    AppLocalizations.of(context)!.nicNumber,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.33,
                                    ),
                                  ),
                                  Text(
                                    user?.nicNo ?? 'Loading...',
                                    style: const TextStyle(
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
                      Text(
                        AppLocalizations.of(context)!.governmentSectors,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                          height: 1.56,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/government_sectors');
                        },
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.seeMore,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color:
                                    isDarkMode
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF525252),
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color:
                                  isDarkMode
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF525252),
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
                          AppLocalizations.of(context)!.publicAdministration,
                          AppLocalizations.of(
                            context,
                          )!.publicAdministrationDesc,
                          'assets/images/home_public_admin.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSectorCard(
                          AppLocalizations.of(context)!.publicSecurity,
                          AppLocalizations.of(context)!.publicSecurityDesc,
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
                          AppLocalizations.of(context)!.financeAndPlanning,
                          AppLocalizations.of(context)!.financeAndPlanningDesc,
                          'assets/images/home_finance_planning.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSectorCard(
                          AppLocalizations.of(context)!.health,
                          AppLocalizations.of(context)!.healthDesc,
                          'assets/images/home_health.png',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Recently Asked Questions section
                  Text(
                    AppLocalizations.of(context)!.recentlyAskedQuestions,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: textColor,
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
      bottomNavigationBar: const CustomBottomNavigationBar(currentPage: 'home'),

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
                  return const ChatbotOverlay(currentPage: 'Home');
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
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final cardColor = isDarkMode ? const Color(0xFF374151) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E5E5);
    final textColor =
        isDarkMode ? const Color(0xFFE5E7EB) : const Color(0xFF404040);
    final secondaryTextColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF737373);

    return GestureDetector(
      onTap: () => _navigateToChat(question),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColor,
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
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: secondaryTextColor,
                height: 1.21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorCard(String title, String description, String imagePath) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final cardColor = isDarkMode ? const Color(0xFF374151) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E5E5);
    final titleColor =
        isDarkMode ? const Color(0xFFE5E7EB) : const Color(0xFF171717);
    final descriptionColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF737373);

    return GestureDetector(
      onTap: () => _navigateToSector(title),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
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
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: titleColor,
                height: 1.21,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: descriptionColor,
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
}
