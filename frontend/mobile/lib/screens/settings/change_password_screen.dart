import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    // Implement password update logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully'),
        backgroundColor: Color(0xFFFF5B00),
      ),
    );
    Navigator.pop(context);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70),

                    // Current Password Field
                    _buildPasswordField(
                      label: 'Current Password',
                      controller: _currentPasswordController,
                      isVisible: _isCurrentPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isCurrentPasswordVisible =
                              !_isCurrentPasswordVisible;
                        });
                      },
                    ),

                    const SizedBox(height: 84),

                    // New Password Field
                    _buildPasswordField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      isVisible: _isNewPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm New Password Field
                    _buildPasswordField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),

                    const SizedBox(height: 52),

                    // Change Password Text
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1F2937),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 395),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5B00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 9, top: 9),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF96999E),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Password Input Row
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Row(
              children: [
                // Password dots or visibility
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child:
                        isVisible
                            ? TextFormField(
                              controller: controller,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1F2937),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            )
                            : Row(
                              children: List.generate(
                                controller.text.isEmpty
                                    ? 3
                                    : controller.text.length,
                                (index) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: const CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Color(0xFF809FB8),
                                  ),
                                ),
                              ),
                            ),
                  ),
                ),

                // Visibility toggle button
                GestureDetector(
                  onTap: onVisibilityToggle,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                      color: const Color(0xFF809FB8),
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
