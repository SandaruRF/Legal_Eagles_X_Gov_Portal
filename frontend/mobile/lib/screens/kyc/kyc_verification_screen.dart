import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nic_front_upload_screen.dart';
import 'nic_back_upload_screen.dart';
import 'selfie_instructions_screen.dart';

class KYCVerificationScreen extends ConsumerStatefulWidget {
  const KYCVerificationScreen({super.key});

  @override
  ConsumerState<KYCVerificationScreen> createState() =>
      _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends ConsumerState<KYCVerificationScreen> {
  String? nicFrontImage;
  String? nicBackImage;
  String? selfieImage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final allDocumentsUploaded = _allDocumentsUploaded();

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
                    const SizedBox(height: 16),

                    // KYC Verification title
                    const Text(
                      'KYC Verification',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Step indicator and Skip all
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Step 3 of 3',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1C120D),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Progress bar
                            Container(
                              width: 262,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0D0D0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width:
                                      262, // Full width since it's step 3 of 3
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5B00),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Skip all button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/home_without_login',
                            );
                          },
                          child: const Text(
                            'Skip all',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8C1F28),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Upload cards
                    _buildUploadCard(
                      title: 'NIC Front',
                      subtitle:
                          'Upload a clear image of the front of your National Identity Card (NIC).',
                      iconColor: const Color(0xFFFEB600),
                      isUploaded: nicFrontImage != null,
                      onTap: () => _handleUpload('nic_front'),
                    ),

                    const SizedBox(height: 16),

                    _buildUploadCard(
                      title: 'NIC Back',
                      subtitle:
                          'Upload a clear image of the back of your National Identity Card (NIC).',
                      iconColor: const Color(0xFFFF5B00),
                      isUploaded: nicBackImage != null,
                      onTap: () => _handleUpload('nic_back'),
                    ),

                    const SizedBox(height: 16),

                    _buildUploadCard(
                      title: 'Selfie',
                      subtitle: 'Take a selfie for facial verification.',
                      iconColor: const Color(0xFF8C1F28),
                      isUploaded: selfieImage != null,
                      onTap: () => _handleUpload('selfie'),
                    ),

                    const SizedBox(height: 40),

                    // Footer text
                    const Text(
                      'Your documents will be reviewed within 48 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF525252),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit button (only show when all documents uploaded)
                    if (allDocumentsUploaded)
                      Container(
                        width: double.infinity,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        child: ElevatedButton(
                          onPressed: _submitKYC,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5B00),
                            foregroundColor: const Color(0xFFFCFAF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit for Verification',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.credit_card, color: Colors.white, size: 24),
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C120D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF707070),
                      height: 1.75,
                    ),
                  ),
                ],
              ),
            ),

            // Check mark (when uploaded)
            if (isUploaded)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1AD598),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleUpload(String documentType) {
    switch (documentType) {
      case 'nic_front':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => NICFrontUploadScreen(
                  onUploadComplete: (imagePath) {
                    setState(() {
                      nicFrontImage = imagePath;
                    });
                  },
                ),
          ),
        );
        break;
      case 'nic_back':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => NicBackUploadScreen(
                  onUploadComplete: (imagePath) {
                    setState(() {
                      nicBackImage = imagePath;
                    });
                  },
                ),
          ),
        );
        break;
      case 'selfie':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SelfieInstructionsScreen(
                  onUploadComplete: (imagePath) {
                    setState(() {
                      selfieImage = imagePath;
                    });
                  },
                ),
          ),
        );
        break;
    }
  }

  bool _allDocumentsUploaded() {
    return nicFrontImage != null && nicBackImage != null && selfieImage != null;
  }

  void _submitKYC() {
    // Navigate to login page instead of showing dialog
    Navigator.pushNamed(context, '/login');
  }
}
