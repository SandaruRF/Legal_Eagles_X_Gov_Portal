import 'package:flutter/material.dart';

class MedicalAppointmentDocumentsScreen extends StatefulWidget {
  const MedicalAppointmentDocumentsScreen({super.key});

  @override
  State<MedicalAppointmentDocumentsScreen> createState() =>
      _MedicalAppointmentDocumentsScreenState();
}

class _MedicalAppointmentDocumentsScreenState
    extends State<MedicalAppointmentDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 33),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Title
                    const Text(
                      'Driving License Medical Appointment',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF171717),
                        height: 1.21,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Please keep the following documents ready before\n filling out the booking form',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFADAEBC),
                        height: 1.71,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Documents List
                    _buildDocumentsList(),

                    const SizedBox(height: 383),

                    // Continue Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/medical_appointment_booking',
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5B00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Proxima Nova',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 2.23,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 102),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 103,
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
                width: 33.5,
                height: 36,
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

            // Empty space to balance the back button
            const SizedBox(width: 33.5),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Padding(
      padding: const EdgeInsets.only(left: 39),
      child: Column(
        children: [
          _buildDocumentItem('NIC front view photo'),
          const SizedBox(height: 13),
          _buildDocumentItem('NIC back view photo'),
          const SizedBox(height: 13),
          _buildDocumentItem('35mm x 45mm face photo'),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bullet point
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5), // Placeholder for bullet image
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        const SizedBox(width: 3),
        // Text
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF000000),
              height: text == 'NIC front view photo' ? 3.06 : 1.38,
            ),
          ),
        ),
      ],
    );
  }
}
