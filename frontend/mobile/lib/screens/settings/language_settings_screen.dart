import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Sinhala', 'code': 'si'},
    {'name': 'Tamil', 'code': 'ta'},
  ];

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
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
                    const SizedBox(height: 58),

                    // Title
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'Select Language',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1F2937),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Language Options
                    ..._languages.map(
                      (language) => Column(
                        children: [
                          _buildLanguageOption(
                            language['name']!,
                            _selectedLanguage == language['name'],
                          ),
                          const SizedBox(height: 12),
                        ],
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

  Widget _buildLanguageOption(String languageName, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectLanguage(languageName),
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
            // Language name
            Expanded(
              child: Text(
                languageName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
            ),

            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFFFF5B00)
                          : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF5B00),
                          ),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
