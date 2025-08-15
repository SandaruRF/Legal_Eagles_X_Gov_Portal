import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/http_client_service.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/startup/startup_screen.dart';
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
import 'screens/vault/document_upload_screen.dart';
import 'screens/chat/chat_interface_screen.dart';
import 'screens/chat/government_assistant_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/my_bookings_screen.dart';
import 'screens/profile/past_bookings_screen.dart';
import 'screens/profile/photo/profile_photo_upload_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/language_settings_screen.dart';
import 'screens/settings/deactivate_account_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/navigation/navigation_search_screen.dart';

void main() {
  // Initialize HTTP client
  HttpClientService().initialize();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Triathalon Gov Portal',
      theme: ThemeData(primarySwatch: Colors.orange),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('si'), // Sinhala
        Locale('ta'), // Tamil
      ],
      initialRoute: '/startup',
      routes: {
        '/startup': (context) => const StartupScreen(),
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
        '/document_upload': (context) => const DocumentUploadScreen(),
        '/add_driving_license': (context) => const AddDrivingLicenseScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profile_photo_upload': (context) => const ProfilePhotoUploadScreen(),
        '/my_bookings': (context) => const MyBookingsScreen(),
        '/past_bookings': (context) => const PastBookingsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/language_settings': (context) => const LanguageSettingsScreen(),
        '/deactivate_account': (context) => const DeactivateAccountScreen(),
        '/search': (context) => const SearchScreen(),
        '/navigation_search': (context) => const NavigationSearchScreen(),
        '/government_assistant': (context) => const GovernmentAssistantScreen(),
        '/chat_interface':
            (context) => ChatInterfaceScreen(
              initialMessage:
                  ModalRoute.of(context)?.settings.arguments as String?,
            ),
      },
      onGenerateRoute: (settings) {
        // ...existing code...
        // (keep your custom route logic unchanged)
        // ...existing code...
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
