import 'package:flutter/material.dart';
import 'selfie_preparation_screen.dart';

class SelfieInstructionsScreen extends StatelessWidget {
  final Function(String)? onUploadComplete;

  const SelfieInstructionsScreen({super.key, this.onUploadComplete});

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
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      'Take your face photo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                      ),
                    ),

                    const SizedBox(height: 37),

                    // Subtitle
                    const Text(
                      'Please your face into the marked area and take a\nclear photo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFADAEBC),
                        height: 1.71,
                      ),
                    ),

                    const SizedBox(height: 68),

                    // Instructions list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstructionItem(
                          'Make sure your in the bright environment',
                        ),

                        const SizedBox(height: 50),

                        _buildInstructionItem(
                          'Click "Continue" when prompted and follow the instruction',
                        ),

                        const SizedBox(height: 50),

                        _buildInstructionItem(
                          'Make sure your in the bright environment\nYou will need to move closer or away from the camera to complete this check',
                        ),
                      ],
                    ),

                    const SizedBox(height: 178),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SelfiePreparationScreen(
                                    onUploadComplete: onUploadComplete,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5B00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 2.23,
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

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bullet point
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFFF5B00),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '•',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 3),

        // Text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
                height: 1.375,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
