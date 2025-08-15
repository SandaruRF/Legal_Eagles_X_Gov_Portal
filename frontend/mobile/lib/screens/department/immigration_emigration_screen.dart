import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/chatbot_overlay.dart';

class ImmigrationEmigrationScreen extends StatefulWidget {
  const ImmigrationEmigrationScreen({super.key});

  @override
  State<ImmigrationEmigrationScreen> createState() =>
      _ImmigrationEmigrationScreenState();
}

class _ImmigrationEmigrationScreenState
    extends State<ImmigrationEmigrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildDepartmentTitle(),
                        const SizedBox(height: 12),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        _buildMainServiceCard(),
                        const SizedBox(height: 16),
                        _buildETACard(),
                        const SizedBox(height: 16),
                        _buildVisaAuthenticationCard(),
                        const SizedBox(height: 16),
                        _buildApplyPassportCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildFloatingChatbotButton(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentPage: 'home'),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 33.5,
              height: 33.5,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF525252),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Gov Portal logo and text (centered)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 45.5), // Balance the back button width
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 41,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Search here ',
                style: TextStyle(
                  color: Color(0xFFADAEBC),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.search, color: Color(0xFFFF5B00), size: 20),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[100],
            ),
            child: const Icon(Icons.filter_alt, color: Colors.grey, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTitle() {
    return const Center(
      child: Text(
        'Department of Immigration and Emigration',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMainServiceCard() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: _iconContainer(
              size: 48,
              imagePath: 'assets/images/passport_application_icon.png',
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Reserve a date to submit a passport application',
                style: TextStyle(fontSize: 14, color: Color(0xFF171717)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _arrowChip(),
          ),
        ],
      ),
    );
  }

  Widget _buildETACard() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: _iconContainer(
              size: 45,
              imagePath: 'assets/images/eta_icon.png',
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Electronic Travel Authorization (ETA)',
                style: TextStyle(fontSize: 14, color: Color(0xFF171717)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _arrowChip(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaAuthenticationCard() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: _iconContainer(
              size: 45,
              imagePath: 'assets/images/visa_authentication_icon.png',
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Online Sri Lankan Visa Authentication',
                style: TextStyle(fontSize: 14, color: Color(0xFF171717)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _arrowChip(),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyPassportCard() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: _iconContainer(
              size: 45,
              imagePath: 'assets/images/apply_passport_icon.png',
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Apply Passport online',
                style: TextStyle(fontSize: 14, color: Color(0xFF171717)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _arrowChip(),
          ),
        ],
      ),
    );
  }

  // Icon container with gradient border and centered image
  Widget _iconContainer({required double size, required String imagePath}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: size * 0.6,
              height: size * 0.6,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  // Small arrow chip to match Figma's tiny chevron with subtle shadow
  Widget _arrowChip() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF809FB8),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.43),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.keyboard_arrow_right,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFloatingChatbotButton() {
    return Positioned(
      bottom: 40, // Lowered from 95 to 80
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
                  return const ChatbotOverlay(
                    currentPage: 'Immigration & Emigration',
                  );
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
}
