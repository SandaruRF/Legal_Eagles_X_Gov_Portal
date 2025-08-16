import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Sinhala', 'code': 'si'},
    {'name': 'Tamil', 'code': 'ta'},
  ];

  void _selectLanguage(String languageCode) {
    ref.read(languageProvider.notifier).changeLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with Gov Portal logo and back button
            _buildGovPortalHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        AppLocalizations.of(context)!.language,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF171717),
                          height: 1.36,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Language Options
                      ..._languages.map(
                        (language) => Column(
                          children: [
                            _buildLanguageOption(
                              language['name']!,
                              currentLanguage.languageCode == language['code'],
                              language['code']!,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildLanguageOption(
    String languageName,
    bool isSelected,
    String languageCode,
  ) {
    return GestureDetector(
      onTap: () => _selectLanguage(languageCode),
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
