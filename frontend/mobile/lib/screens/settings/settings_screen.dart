import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../core/services/token_storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;

  void _navigateToChangePassword() {
    Navigator.pushNamed(context, '/change_password');
  }

  void _navigateToLanguageSettings() {
    Navigator.pushNamed(context, '/language_settings');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: _buildLogoutDialog(),
        );
      },
    );
  }

  void _showDeactivateDialog() {
    Navigator.pushNamed(context, '/deactivate_account');
  }

  void _handleLogout() async {
    // Clear token on logout
    await TokenStorageService.clearToken();
    Navigator.of(context).pop(); // Close dialog
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SafeArea(
            bottom: false, // Don't apply SafeArea to bottom
            child: Column(
              children: [
                // Header with Gov Portal (only header)
                _buildGovPortalHeader(),

                // Content
                Expanded(
                  child: Container(
                    color: const Color(0xFFF9FAFB),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Change Password Card
                          _buildSettingsCard(
                            icon: Icons.lock_outline,
                            title: AppLocalizations.of(context)!.changePassword,
                            onTap: _navigateToChangePassword,
                            showArrow: true,
                          ),

                          const SizedBox(height: 12),

                          // Language Card
                          _buildLanguageCard(),

                          const SizedBox(height: 12),

                          // Dark Mode Card
                          _buildDarkModeCard(),

                          const SizedBox(height: 12),

                          // Logout Card
                          _buildActionCard(
                            icon: Icons.logout,
                            title: 'Logout',
                            isDestructive: true,
                            onTap: _showLogoutDialog,
                          ),

                          const SizedBox(height: 12),

                          // Deactivate Account Card
                          _buildActionCard(
                            icon: Icons.person_remove,
                            title: 'Deactivate Account',
                            isDestructive: true,
                            onTap: _showDeactivateDialog,
                          ),

                          const Spacer(), // Push content up but maintain bottom spacing

                          const SizedBox(
                            height: 20,
                          ), // Reduced space for bottom navigation
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavigationBar(currentPage: 'settings'),
          ),

          // Floating Action Button for Chatbot
          _buildFloatingChatbotButton(),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          child: Row(
            children: [
              // Icon
              Icon(icon, size: 20, color: const Color(0xFFFF5B00)),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1F2937),
                    height: 1.5,
                  ),
                ),
              ),
              // Arrow
              if (showArrow)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return GestureDetector(
      onTap: _navigateToLanguageSettings,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          child: Row(
            children: [
              // Icon
              const Icon(Icons.language, size: 20, color: Color(0xFFFF5B00)),
              const SizedBox(width: 12),
              // Title
              const Expanded(
                child: Text(
                  'Language',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1F2937),
                    height: 1.5,
                  ),
                ),
              ),
              // Language text and arrow
              const Text(
                'English',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkModeCard() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
        child: Row(
          children: [
            // Icon
            const Icon(
              Icons.dark_mode_outlined,
              size: 20,
              color: Color(0xFFFF5B00),
            ),
            const SizedBox(width: 12),
            // Title
            const Expanded(
              child: Text(
                'Dark Mode',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
            ),
            // Toggle Switch
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              child: Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      _isDarkMode
                          ? const Color(0xFFFF5B00)
                          : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      _isDarkMode
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? const Color(0xFFEF4444) : const Color(0xFFFF5B00);
    final borderColor =
        isDestructive ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          child: Row(
            children: [
              // Icon
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: color,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingChatbotButton() {
    return Positioned(
      bottom:
          110, // Adjusted position to account for larger navbar (100px + 10px margin)
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
                  return const ChatbotOverlay(currentPage: 'Settings');
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

  Widget _buildLogoutDialog() {
    return Container(
      width: 377,
      height: 175,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          const SizedBox(height: 36),
          const Text(
            'Are you sure to logout ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 38),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5B00).withOpacity(0.37),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF5B00).withOpacity(0.37),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF262626),
                            height: 1.21,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Yes Button
                Expanded(
                  child: GestureDetector(
                    onTap: _handleLogout,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5B00),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.21,
                          ),
                        ),
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

  Widget _buildGovPortalHeader() {
    return Container(
      width: double.infinity,
      height: 104,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
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
                        image: AssetImage('assets/images/gov_portal_logo.png'),
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
          ],
        ),
      ),
    );
  }
}
