import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  static const String _languageKey = 'selected_language';

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    // Only update state if a language was previously saved
    // Otherwise, keep the default English ('en')
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  void changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    state = Locale(languageCode);
  }

  String getLanguageDisplayName() {
    switch (state.languageCode) {
      case 'si':
        return 'Sinhala';
      case 'ta':
        return 'Tamil';
      case 'en':
      default:
        return 'English';
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});
