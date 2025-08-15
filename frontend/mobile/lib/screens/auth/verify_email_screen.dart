import 'package:flutter/material.dart';
import 'dart:async';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  int _remainingTime = 50;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOTP() {
    setState(() {
      _remainingTime = 50;
    });
    _startTimer();
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

                    // Confirm Your Email title
                    const Center(
                      child: Text(
                        'Confirm Your Email',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C120D),
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Check your inbox instruction
                    const Center(
                      child: Text(
                        'Check your inbox and enter the otp',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF909090),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 21),

                    // OTP input fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD4D4D4),
                              ),
                            ),
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF171717),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 169),

                    // Time remaining text
                    Center(
                      child: Text(
                        'Time Remaining  ${_remainingTime}s',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFC5C5C5),
                          height: 1.91,
                        ),
                      ),
                    ),

                    const SizedBox(height: 72),

                    // Resend OTP button
                    Center(
                      child: GestureDetector(
                        onTap: _remainingTime == 0 ? _resendOTP : null,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color:
                                _remainingTime == 0
                                    ? const Color(0xFFFF5B00)
                                    : const Color(0xFFC5C5C5),
                            height: 1.91,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 150), // Large spacing as in design
                    // Submit button
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to email confirmation success screen
                          Navigator.pushNamed(context, '/email_confirmation');
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
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
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
