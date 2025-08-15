import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Try to restore authentication from saved token
      final isAuthenticated =
          await ref.read(authProvider.notifier).restoreAuthentication();

      if (isAuthenticated) {
        // Navigate to signed in home
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_signed_in',
            (route) => false,
          );
        }
      } else {
        // No valid token found, go to onboarding
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/onboarding1',
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('Error during app initialization: $e');
      // On error, go to onboarding
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding1',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gov Portal logo
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/gov_portal_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gov Portal',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Initializing...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF737373),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
