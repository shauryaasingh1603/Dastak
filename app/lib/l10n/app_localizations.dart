import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_hi.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('hi')];

  /// No description provided for @appTitle.
  ///
  /// In hi, this message translates to:
  /// **'दस्तक'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In hi, this message translates to:
  /// **'लॉगिन'**
  String get loginTitle;

  /// No description provided for @loginMobileLabel.
  ///
  /// In hi, this message translates to:
  /// **'मोबाइल नंबर डालें'**
  String get loginMobileLabel;

  /// No description provided for @loginMobileHint.
  ///
  /// In hi, this message translates to:
  /// **'10 अंकों का नंबर'**
  String get loginMobileHint;

  /// No description provided for @loginSubmit.
  ///
  /// In hi, this message translates to:
  /// **'आगे बढ़ें'**
  String get loginSubmit;

  /// No description provided for @loginHelp.
  ///
  /// In hi, this message translates to:
  /// **'आपका नंबर कार्यालय में दर्ज होना चाहिए। लॉगिन के लिए एडमिन की मंज़ूरी ज़रूरी है।'**
  String get loginHelp;

  /// No description provided for @waitingTitle.
  ///
  /// In hi, this message translates to:
  /// **'मंज़ूरी का इंतज़ार'**
  String get waitingTitle;

  /// No description provided for @waitingCodeLabel.
  ///
  /// In hi, this message translates to:
  /// **'आपका कोड'**
  String get waitingCodeLabel;

  /// No description provided for @waitingInstruction.
  ///
  /// In hi, this message translates to:
  /// **'यह कोड एडमिन को बताएँ। मंज़ूरी मिलते ही ऐप अपने आप खुल जाएगा।'**
  String get waitingInstruction;

  /// No description provided for @waitingChecking.
  ///
  /// In hi, this message translates to:
  /// **'मंज़ूरी की जाँच हो रही है…'**
  String get waitingChecking;

  /// No description provided for @waitingOffline.
  ///
  /// In hi, this message translates to:
  /// **'नेट नहीं है – नेट आते ही जाँच होगी'**
  String get waitingOffline;

  /// No description provided for @waitingCancel.
  ///
  /// In hi, this message translates to:
  /// **'नंबर बदलें'**
  String get waitingCancel;

  /// No description provided for @errMobileInvalid.
  ///
  /// In hi, this message translates to:
  /// **'सही मोबाइल नंबर डालें'**
  String get errMobileInvalid;

  /// No description provided for @errNotRegistered.
  ///
  /// In hi, this message translates to:
  /// **'यह नंबर दर्ज नहीं है। कार्यालय से संपर्क करें।'**
  String get errNotRegistered;

  /// No description provided for @errTooMany.
  ///
  /// In hi, this message translates to:
  /// **'बहुत बार कोशिश हुई। थोड़ी देर बाद फिर कोशिश करें।'**
  String get errTooMany;

  /// No description provided for @errNetwork.
  ///
  /// In hi, this message translates to:
  /// **'नेट नहीं है – दोबारा कोशिश करें'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In hi, this message translates to:
  /// **'कुछ गड़बड़ हुई। दोबारा कोशिश करें।'**
  String get errGeneric;

  /// No description provided for @loginRejected.
  ///
  /// In hi, this message translates to:
  /// **'एडमिन ने मंज़ूरी नहीं दी। कार्यालय से संपर्क करें।'**
  String get loginRejected;

  /// No description provided for @loginExpired.
  ///
  /// In hi, this message translates to:
  /// **'अनुरोध का समय समाप्त हो गया। दोबारा कोशिश करें।'**
  String get loginExpired;

  /// No description provided for @accessRevoked.
  ///
  /// In hi, this message translates to:
  /// **'इस फ़ोन से लॉगिन हटा दिया गया है। दोबारा लॉगिन करें।'**
  String get accessRevoked;

  /// No description provided for @homeTitle.
  ///
  /// In hi, this message translates to:
  /// **'आज का सारांश'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In hi, this message translates to:
  /// **'नमस्ते, {name}'**
  String homeGreeting(String name);

  /// No description provided for @roleVolunteer.
  ///
  /// In hi, this message translates to:
  /// **'स्वयंसेवक'**
  String get roleVolunteer;

  /// No description provided for @roleBla2.
  ///
  /// In hi, this message translates to:
  /// **'बीएलए-2'**
  String get roleBla2;

  /// No description provided for @homeBooths.
  ///
  /// In hi, this message translates to:
  /// **'आपके बूथ'**
  String get homeBooths;

  /// No description provided for @homeBoothLine.
  ///
  /// In hi, this message translates to:
  /// **'बूथ {partNo} · {name}'**
  String homeBoothLine(int partNo, String name);

  /// No description provided for @homeNoBooths.
  ///
  /// In hi, this message translates to:
  /// **'अभी कोई बूथ नहीं सौंपा गया है। कार्यालय से संपर्क करें।'**
  String get homeNoBooths;

  /// No description provided for @homeFamilyCount.
  ///
  /// In hi, this message translates to:
  /// **'{count} परिवार'**
  String homeFamilyCount(int count);

  /// No description provided for @homeOffline.
  ///
  /// In hi, this message translates to:
  /// **'नेट नहीं है – पिछली जानकारी दिख रही है'**
  String get homeOffline;

  /// No description provided for @listTitle.
  ///
  /// In hi, this message translates to:
  /// **'मेरी सूची'**
  String get listTitle;

  /// No description provided for @listEmpty.
  ///
  /// In hi, this message translates to:
  /// **'इस सूची में कोई परिवार नहीं है'**
  String get listEmpty;

  /// No description provided for @houseNo.
  ///
  /// In hi, this message translates to:
  /// **'मकान नं. {no}'**
  String houseNo(String no);

  /// No description provided for @priorityHigh.
  ///
  /// In hi, this message translates to:
  /// **'उच्च प्राथमिकता'**
  String get priorityHigh;

  /// No description provided for @logout.
  ///
  /// In hi, this message translates to:
  /// **'लॉगआउट'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In hi, this message translates to:
  /// **'क्या आप लॉगआउट करना चाहते हैं? दोबारा लॉगिन के लिए एडमिन की मंज़ूरी लगेगी।'**
  String get logoutConfirm;

  /// No description provided for @yes.
  ///
  /// In hi, this message translates to:
  /// **'हाँ'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In hi, this message translates to:
  /// **'नहीं'**
  String get no;

  /// No description provided for @retry.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा कोशिश करें'**
  String get retry;
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
      <String>['hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
