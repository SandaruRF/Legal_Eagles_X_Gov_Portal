import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started →'**
  String get getStarted;

  /// No description provided for @govPortal.
  ///
  /// In en, this message translates to:
  /// **'Gov Portal'**
  String get govPortal;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccount;

  /// No description provided for @governmentAssistant.
  ///
  /// In en, this message translates to:
  /// **'Government Assistant'**
  String get governmentAssistant;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about government services'**
  String get askMeAnything;

  /// No description provided for @helloGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I help you with government services today?'**
  String get helloGreeting;

  /// No description provided for @typeYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Type your question...'**
  String get typeYourQuestion;

  /// No description provided for @digitalVault.
  ///
  /// In en, this message translates to:
  /// **'Digital Vault'**
  String get digitalVault;

  /// No description provided for @digitalIdentityCard.
  ///
  /// In en, this message translates to:
  /// **'Digital Identity Card'**
  String get digitalIdentityCard;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @nicNumber.
  ///
  /// In en, this message translates to:
  /// **'NIC Number'**
  String get nicNumber;

  /// No description provided for @governmentSectors.
  ///
  /// In en, this message translates to:
  /// **'Government Sectors'**
  String get governmentSectors;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @publicAdministration.
  ///
  /// In en, this message translates to:
  /// **'Public Administration'**
  String get publicAdministration;

  /// No description provided for @publicAdministrationDesc.
  ///
  /// In en, this message translates to:
  /// **'NIC, Passport, Birth & Death Certificates, Land Records'**
  String get publicAdministrationDesc;

  /// No description provided for @publicSecurity.
  ///
  /// In en, this message translates to:
  /// **'Public Security'**
  String get publicSecurity;

  /// No description provided for @publicSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Police Services, Crime Reports, Emergency Services'**
  String get publicSecurityDesc;

  /// No description provided for @financeAndPlanning.
  ///
  /// In en, this message translates to:
  /// **'Finance & Planning'**
  String get financeAndPlanning;

  /// No description provided for @financeAndPlanningDesc.
  ///
  /// In en, this message translates to:
  /// **'Business Registration, Job Portal, EPF/ETF Services'**
  String get financeAndPlanningDesc;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @healthDesc.
  ///
  /// In en, this message translates to:
  /// **'Medical Records, Hospital Appointments, Public Health Announcements'**
  String get healthDesc;

  /// No description provided for @recentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Recently Asked Questions'**
  String get recentlyAskedQuestions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
