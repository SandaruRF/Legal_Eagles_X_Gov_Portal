import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/onboarding_screen_2.dart';
import 'screens/onboarding/onboarding_screen_3.dart';
import 'screens/onboarding/onboarding_screen_4.dart';
import 'screens/onboarding/onboarding_screen_5.dart';
import 'screens/onboarding/onboarding_screen_6.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_page_without_login.dart';
import 'screens/kyc/kyc_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/email_confirmation_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/password_update_screen.dart';
import 'screens/home/home_page_signed_in.dart';
import 'screens/home/government_sectors_screen.dart';
import 'screens/ministry/ministry_public_security_screen.dart';
import 'screens/ministry/ministry_transport_screen.dart';
import 'screens/transport/national_transport_medical_institute_screen.dart';
import 'screens/transport/driving_license_medical_appointment_screen.dart';
import 'screens/transport/medical_appointment_documents_screen.dart';
import 'screens/transport/medical_appointment_booking_screen.dart';
import 'screens/department/immigration_emigration_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/vault/digital_vault_screen.dart';
import 'screens/vault/add_driving_license_screen.dart';
import 'screens/chat/chat_interface_screen.dart';
import 'screens/chat/government_assistant_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/my_bookings_screen.dart';
import 'screens/profile/past_bookings_screen.dart';
import 'screens/profile/photo/profile_photo_upload_screen.dart';
import 'screens/profile/photo/profile_photo_camera_screen.dart';
import 'screens/profile/photo/profile_photo_completion_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/language_settings_screen.dart';
import 'screens/settings/deactivate_account_screen.dart';
import 'screens/search/search_screen.dart';
import 'dart:io';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triathalon Gov Portal',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/home_signed_in',
      routes: {
        '/onboarding1': (context) => const OnboardingScreen(),
        '/onboarding2': (context) => const OnboardingScreen2(),
        '/onboarding3': (context) => const OnboardingScreen3(),
        '/onboarding4': (context) => const OnboardingScreen4(),
        '/onboarding5': (context) => const OnboardingScreen5(),
        '/onboarding6': (context) => const OnboardingScreen6(),
        '/signup': (context) => const SignupScreen(),
        '/home_without_login': (context) => const HomePageWithoutLogin(),
        '/kyc_verification': (context) => const KYCVerificationScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/email_confirmation': (context) => const EmailConfirmationScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/password_update': (context) => const PasswordUpdateScreen(),
        '/home_signed_in': (context) => const HomePageSignedIn(),
        '/government_sectors': (context) => const GovernmentSectorsScreen(),
        '/ministry_public_security':
            (context) => const MinistryPublicSecurityScreen(),
        '/ministry_transport': (context) => const MinistryTransportScreen(),
        '/national_transport_medical_institute':
            (context) => const NationalTransportMedicalInstituteScreen(),
        '/driving_license_medical_appointment':
            (context) => const DrivingLicenseMedicalAppointmentScreen(),
        '/medical_appointment_documents':
            (context) => const MedicalAppointmentDocumentsScreen(),
        '/medical_appointment_booking':
            (context) => const MedicalAppointmentBookingScreen(),
        '/immigration_emigration':
            (context) => const ImmigrationEmigrationScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/digital_vault': (context) => const DigitalVaultScreen(),
        '/add_driving_license': (context) => const AddDrivingLicenseScreen(),
        '/profile_photo_upload': (context) => const ProfilePhotoUploadScreen(),
        '/my_bookings': (context) => const MyBookingsScreen(),
        '/past_bookings': (context) => const PastBookingsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/language_settings': (context) => const LanguageSettingsScreen(),
        '/deactivate_account': (context) => const DeactivateAccountScreen(),
        '/search': (context) => const SearchScreen(),
        '/government_assistant': (context) => const GovernmentAssistantScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/chat_interface':
            final String? initialMessage = settings.arguments as String?;
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      ChatInterfaceScreen(initialMessage: initialMessage),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/profile':
            final File? profileImage = settings.arguments as File?;
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      ProfileScreen(profileImage: profileImage),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/profile_photo_camera':
            final File? imageFile = settings.arguments as File?;
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      ProfilePhotoCameraScreen(initialImage: imageFile),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/profile_photo_completion':
            final File? selectedImage = settings.arguments as File?;
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      ProfilePhotoCompletionScreen(
                        selectedImage: selectedImage,
                      ),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/profile_photo_upload':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const ProfilePhotoUploadScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/onboarding1':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const OnboardingScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/onboarding2':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const OnboardingScreen2(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/onboarding3':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const OnboardingScreen3(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/onboarding4':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const OnboardingScreen4(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/onboarding5':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const OnboardingScreen5(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/onboarding6':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const OnboardingScreen6(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/signup':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const SignupScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/home_without_login':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const HomePageWithoutLogin(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/kyc_verification':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const KYCVerificationScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/login':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/forgot_password':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const ForgotPasswordScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/verify_email':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const VerifyEmailScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/email_confirmation':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const EmailConfirmationScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/reset_password':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const ResetPasswordScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/password_update':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const PasswordUpdateScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case '/home_signed_in':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const HomePageSignedIn(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
