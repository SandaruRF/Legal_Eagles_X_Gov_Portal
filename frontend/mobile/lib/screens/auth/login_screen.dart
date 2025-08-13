import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nicEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nicEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.white,
          ),

          // Header
          Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF525252),
                    size: 18,
                  ),
                ),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gov Portal logo
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
                ),

                const SizedBox(width: 24), // Balance the back button
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),

                    // Login title
                    const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                          height: 1.04,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login form container
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
                          // NIC/Email field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NIC/Email',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF404040),
                                  height: 1.21,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD4D4D4),
                                  ),
                                ),
                                child: TextField(
                                  controller: _nicEmailController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your NIC or Email',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFADAEBC),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 17),

                          // Password field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF404040),
                                  height: 1.21,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD4D4D4),
                                  ),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFADAEBC),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot_password',
                                );
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF8C1F28),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 300), // Large spacing as in design
                    // Sign In button
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 17),
                      child: ElevatedButton(
                        onPressed: () {
                          // For testing, allow sign in without validation
                          Navigator.pushReplacementNamed(
                            context,
                            '/home_signed_in',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5B00),
                          foregroundColor: const Color(0xFFFCFAF7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Don't have an account text
                    const Center(
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF909090),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Chatbot floating action button
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
              // TODO: Open chatbot
              print('Chatbot tapped');
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
}
