import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  void _handleLogout() {
    Navigator.of(context).pop(); // Close dialog
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 60,
              color: const Color(0xFF404040),
              child: Row(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 17.5,
                        height: 20,
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Title
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // Change Password Card
                    _buildSettingsCard(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
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

                    const SizedBox(height: 386),

                    // Deactivate Account Card
                    _buildActionCard(
                      icon: Icons.person_remove,
                      title: 'Deactivate Account',
                      isDestructive: true,
                      onTap: _showDeactivateDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 14,
              height: 16,
              child: Icon(icon, size: 14, color: const Color(0xFFFF5B00)),
            ),
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
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return GestureDetector(
      onTap: _navigateToLanguageSettings,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                SizedBox(
                  width: 20,
                  height: 16,
                  child: const Icon(
                    Icons.language,
                    size: 20,
                    color: Color(0xFFFF5B00),
                  ),
                ),
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
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Icon
          SizedBox(
            width: 12,
            height: 16,
            child: const Icon(
              Icons.dark_mode_outlined,
              size: 12,
              color: Color(0xFFFF5B00),
            ),
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
          SizedBox(
            width: 44,
            height: 24,
            child: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFFFF5B00),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE5E7EB),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: 16,
              height: 16,
              child: Icon(icon, size: 16, color: color),
            ),
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
}
