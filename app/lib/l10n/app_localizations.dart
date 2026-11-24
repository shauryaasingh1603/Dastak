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

  /// No description provided for @homeBoothsHint.
  ///
  /// In hi, this message translates to:
  /// **'बूथ पर टैप करें – उस बूथ के परिवार खुलेंगे'**
  String get homeBoothsHint;

  /// No description provided for @boothNumber.
  ///
  /// In hi, this message translates to:
  /// **'बूथ {partNo}'**
  String boothNumber(int partNo);

  /// No description provided for @sectionHeader.
  ///
  /// In hi, this message translates to:
  /// **'अनुभाग {sectionNo}'**
  String sectionHeader(int sectionNo);

  /// No description provided for @sectionUnknown.
  ///
  /// In hi, this message translates to:
  /// **'अनुभाग दर्ज नहीं'**
  String get sectionUnknown;

  /// No description provided for @listSearchHint.
  ///
  /// In hi, this message translates to:
  /// **'नाम, EPIC या मकान नं. खोजें'**
  String get listSearchHint;

  /// No description provided for @listEmpty.
  ///
  /// In hi, this message translates to:
  /// **'इस बूथ में कोई परिवार नहीं है'**
  String get listEmpty;

  /// No description provided for @listNoMatch.
  ///
  /// In hi, this message translates to:
  /// **'खोज से कोई परिवार नहीं मिला'**
  String get listNoMatch;

  /// No description provided for @listShowing.
  ///
  /// In hi, this message translates to:
  /// **'{shown} / {total} परिवार'**
  String listShowing(int shown, int total);

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

  /// No description provided for @navHome.
  ///
  /// In hi, this message translates to:
  /// **'सारांश'**
  String get navHome;

  /// No description provided for @navList.
  ///
  /// In hi, this message translates to:
  /// **'मेरी सूची'**
  String get navList;

  /// No description provided for @navForms.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म'**
  String get navForms;

  /// No description provided for @navSync.
  ///
  /// In hi, this message translates to:
  /// **'सिंक'**
  String get navSync;

  /// No description provided for @homeTarget.
  ///
  /// In hi, this message translates to:
  /// **'आज का लक्ष्य'**
  String get homeTarget;

  /// No description provided for @homeDoneToday.
  ///
  /// In hi, this message translates to:
  /// **'आज पूरे'**
  String get homeDoneToday;

  /// No description provided for @homeRemaining.
  ///
  /// In hi, this message translates to:
  /// **'बाकी लोग'**
  String get homeRemaining;

  /// No description provided for @homeRevisitToday.
  ///
  /// In hi, this message translates to:
  /// **'आज दोबारा जाना है'**
  String get homeRevisitToday;

  /// No description provided for @homeFormsFilled.
  ///
  /// In hi, this message translates to:
  /// **'भरे गए फॉर्म'**
  String get homeFormsFilled;

  /// No description provided for @homeSyncState.
  ///
  /// In hi, this message translates to:
  /// **'सिंक स्थिति'**
  String get homeSyncState;

  /// No description provided for @homeDeadline.
  ///
  /// In hi, this message translates to:
  /// **'अंतिम तिथि: 16 दिसंबर – {days} दिन बाकी'**
  String homeDeadline(int days);

  /// No description provided for @homeDeadlineToday.
  ///
  /// In hi, this message translates to:
  /// **'अंतिम तिथि: आज (16 दिसंबर)'**
  String get homeDeadlineToday;

  /// No description provided for @claimsClosed.
  ///
  /// In hi, this message translates to:
  /// **'दावा अवधि समाप्त (16 दिसंबर)'**
  String get claimsClosed;

  /// No description provided for @outboxStale.
  ///
  /// In hi, this message translates to:
  /// **'डेटा अभी सर्वर पर नहीं गया – नेट से जुड़ें'**
  String get outboxStale;

  /// No description provided for @quotaLine.
  ///
  /// In hi, this message translates to:
  /// **'आज जमा: {today}/{dailyLimit} · कुल: {total}/{totalLimit}'**
  String quotaLine(int today, int dailyLimit, int total, int totalLimit);

  /// No description provided for @firstSyncLoading.
  ///
  /// In hi, this message translates to:
  /// **'आपकी सूची डाउनलोड हो रही है…'**
  String get firstSyncLoading;

  /// No description provided for @firstSyncFailed.
  ///
  /// In hi, this message translates to:
  /// **'सूची डाउनलोड नहीं हुई – नेट से जुड़कर दोबारा कोशिश करें'**
  String get firstSyncFailed;

  /// No description provided for @logoutBlocked.
  ///
  /// In hi, this message translates to:
  /// **'पहले सारा डेटा सिंक करें, फिर लॉगआउट करें।'**
  String get logoutBlocked;

  /// No description provided for @boothProgress.
  ///
  /// In hi, this message translates to:
  /// **'{done}/{total} परिवार पूरे'**
  String boothProgress(int done, int total);

  /// No description provided for @filterAll.
  ///
  /// In hi, this message translates to:
  /// **'सभी'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In hi, this message translates to:
  /// **'बाकी'**
  String get filterPending;

  /// No description provided for @filterDone.
  ///
  /// In hi, this message translates to:
  /// **'पूरा'**
  String get filterDone;

  /// No description provided for @filterRevisit.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा'**
  String get filterRevisit;

  /// No description provided for @statusPending.
  ///
  /// In hi, this message translates to:
  /// **'बाकी'**
  String get statusPending;

  /// No description provided for @statusDone.
  ///
  /// In hi, this message translates to:
  /// **'पूरा'**
  String get statusDone;

  /// No description provided for @statusRevisit.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा'**
  String get statusRevisit;

  /// No description provided for @needsReview.
  ///
  /// In hi, this message translates to:
  /// **'कार्यालय समीक्षा'**
  String get needsReview;

  /// No description provided for @newVoterTag.
  ///
  /// In hi, this message translates to:
  /// **'नया'**
  String get newVoterTag;

  /// No description provided for @onRollTag.
  ///
  /// In hi, this message translates to:
  /// **'सूची में नाम है'**
  String get onRollTag;

  /// No description provided for @notSynced.
  ///
  /// In hi, this message translates to:
  /// **'सिंक बाकी'**
  String get notSynced;

  /// No description provided for @outcomeEligible.
  ///
  /// In hi, this message translates to:
  /// **'पात्र – फॉर्म भराना है'**
  String get outcomeEligible;

  /// No description provided for @outcomeCorrection.
  ///
  /// In hi, this message translates to:
  /// **'सुधार चाहिए'**
  String get outcomeCorrection;

  /// No description provided for @outcomeMovedIn.
  ///
  /// In hi, this message translates to:
  /// **'यहाँ आए हैं'**
  String get outcomeMovedIn;

  /// No description provided for @outcomeShifted.
  ///
  /// In hi, this message translates to:
  /// **'स्थानांतरित'**
  String get outcomeShifted;

  /// No description provided for @outcomeDead.
  ///
  /// In hi, this message translates to:
  /// **'मृत्यु'**
  String get outcomeDead;

  /// No description provided for @outcomeNotMet.
  ///
  /// In hi, this message translates to:
  /// **'नहीं मिले'**
  String get outcomeNotMet;

  /// No description provided for @outcomeOnRoll.
  ///
  /// In hi, this message translates to:
  /// **'सूची में नाम है'**
  String get outcomeOnRoll;

  /// No description provided for @formStatusFilled.
  ///
  /// In hi, this message translates to:
  /// **'भरा गया'**
  String get formStatusFilled;

  /// No description provided for @formStatusSubmitted.
  ///
  /// In hi, this message translates to:
  /// **'जमा'**
  String get formStatusSubmitted;

  /// No description provided for @formStatusInEro.
  ///
  /// In hi, this message translates to:
  /// **'ईआरओ सूची में'**
  String get formStatusInEro;

  /// No description provided for @formStatusAccepted.
  ///
  /// In hi, this message translates to:
  /// **'स्वीकृत'**
  String get formStatusAccepted;

  /// No description provided for @formStatusRejected.
  ///
  /// In hi, this message translates to:
  /// **'अस्वीकृत'**
  String get formStatusRejected;

  /// No description provided for @formStatusHearing.
  ///
  /// In hi, this message translates to:
  /// **'सुनवाई'**
  String get formStatusHearing;

  /// No description provided for @routeBla2.
  ///
  /// In hi, this message translates to:
  /// **'बीएलए-2 के माध्यम से'**
  String get routeBla2;

  /// No description provided for @routeSelf.
  ///
  /// In hi, this message translates to:
  /// **'स्वयं जमा'**
  String get routeSelf;

  /// No description provided for @routeOnline.
  ///
  /// In hi, this message translates to:
  /// **'ऑनलाइन'**
  String get routeOnline;

  /// No description provided for @docAadhaar.
  ///
  /// In hi, this message translates to:
  /// **'आधार'**
  String get docAadhaar;

  /// No description provided for @docBirthCert.
  ///
  /// In hi, this message translates to:
  /// **'जन्म प्रमाणपत्र'**
  String get docBirthCert;

  /// No description provided for @docHighschool.
  ///
  /// In hi, this message translates to:
  /// **'हाईस्कूल मार्कशीट'**
  String get docHighschool;

  /// No description provided for @docRation.
  ///
  /// In hi, this message translates to:
  /// **'राशन कार्ड'**
  String get docRation;

  /// No description provided for @docElectricity.
  ///
  /// In hi, this message translates to:
  /// **'बिजली बिल'**
  String get docElectricity;

  /// No description provided for @docOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य'**
  String get docOther;

  /// No description provided for @formType.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म {type}'**
  String formType(String type);

  /// No description provided for @formNone.
  ///
  /// In hi, this message translates to:
  /// **'कोई नहीं'**
  String get formNone;

  /// No description provided for @reasonShifted.
  ///
  /// In hi, this message translates to:
  /// **'कारण: स्थानांतरित'**
  String get reasonShifted;

  /// No description provided for @reasonUntraceable.
  ///
  /// In hi, this message translates to:
  /// **'कारण: पता नहीं चला'**
  String get reasonUntraceable;

  /// No description provided for @reasonPossDel.
  ///
  /// In hi, this message translates to:
  /// **'कारण: संभवतः हटाया गया'**
  String get reasonPossDel;

  /// No description provided for @relationF.
  ///
  /// In hi, this message translates to:
  /// **'पिता'**
  String get relationF;

  /// No description provided for @relationH.
  ///
  /// In hi, this message translates to:
  /// **'पति'**
  String get relationH;

  /// No description provided for @relationM.
  ///
  /// In hi, this message translates to:
  /// **'माता'**
  String get relationM;

  /// No description provided for @relationO.
  ///
  /// In hi, this message translates to:
  /// **'अन्य'**
  String get relationO;

  /// No description provided for @genderM.
  ///
  /// In hi, this message translates to:
  /// **'पुरुष'**
  String get genderM;

  /// No description provided for @genderF.
  ///
  /// In hi, this message translates to:
  /// **'महिला'**
  String get genderF;

  /// No description provided for @genderO.
  ///
  /// In hi, this message translates to:
  /// **'अन्य'**
  String get genderO;

  /// No description provided for @ageYears.
  ///
  /// In hi, this message translates to:
  /// **'{age} वर्ष'**
  String ageYears(int age);

  /// No description provided for @epicLine.
  ///
  /// In hi, this message translates to:
  /// **'EPIC: {epic}'**
  String epicLine(String epic);

  /// No description provided for @epicMissing.
  ///
  /// In hi, this message translates to:
  /// **'EPIC नहीं'**
  String get epicMissing;

  /// No description provided for @familyTitle.
  ///
  /// In hi, this message translates to:
  /// **'परिवार कार्ड'**
  String get familyTitle;

  /// No description provided for @familyHead.
  ///
  /// In hi, this message translates to:
  /// **'मुखिया: {name}'**
  String familyHead(String name);

  /// No description provided for @familyMembers.
  ///
  /// In hi, this message translates to:
  /// **'सदस्य'**
  String get familyMembers;

  /// No description provided for @familyPrevVisits.
  ///
  /// In hi, this message translates to:
  /// **'पिछली भेंट'**
  String get familyPrevVisits;

  /// No description provided for @familyNoVisits.
  ///
  /// In hi, this message translates to:
  /// **'अभी कोई भेंट नहीं'**
  String get familyNoVisits;

  /// No description provided for @voterAdd.
  ///
  /// In hi, this message translates to:
  /// **'नया सदस्य जोड़ें'**
  String get voterAdd;

  /// No description provided for @visitByMe.
  ///
  /// In hi, this message translates to:
  /// **'आप'**
  String get visitByMe;

  /// No description provided for @visitByOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य स्वयंसेवक'**
  String get visitByOther;

  /// No description provided for @revisitOn.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा: {date}'**
  String revisitOn(String date);

  /// No description provided for @visitTitle.
  ///
  /// In hi, this message translates to:
  /// **'भेंट फॉर्म'**
  String get visitTitle;

  /// No description provided for @visitNobodyHome.
  ///
  /// In hi, this message translates to:
  /// **'कोई नहीं मिला'**
  String get visitNobodyHome;

  /// No description provided for @visitNobodyHomeHint.
  ///
  /// In hi, this message translates to:
  /// **'घर पर कोई नहीं था – दोबारा आने की तारीख़ चुनें'**
  String get visitNobodyHomeHint;

  /// No description provided for @visitWhoMetOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य व्यक्ति'**
  String get visitWhoMetOther;

  /// No description provided for @visitMembers.
  ///
  /// In hi, this message translates to:
  /// **'हर सदस्य का परिणाम'**
  String get visitMembers;

  /// No description provided for @visitWhichForm.
  ///
  /// In hi, this message translates to:
  /// **'कौन सा फॉर्म?'**
  String get visitWhichForm;

  /// No description provided for @visitDocs.
  ///
  /// In hi, this message translates to:
  /// **'देखे गए दस्तावेज़'**
  String get visitDocs;

  /// No description provided for @visitMobile.
  ///
  /// In hi, this message translates to:
  /// **'मोबाइल नंबर (अगर दें)'**
  String get visitMobile;

  /// No description provided for @visitConsent.
  ///
  /// In hi, this message translates to:
  /// **'आपका नंबर सिर्फ़ मतदाता सूची के काम के लिए लिया जा रहा है'**
  String get visitConsent;

  /// No description provided for @visitConsentLabel.
  ///
  /// In hi, this message translates to:
  /// **'मतदाता को पढ़कर सुनाया और सहमति ली'**
  String get visitConsentLabel;

  /// No description provided for @visitRemarks.
  ///
  /// In hi, this message translates to:
  /// **'टिप्पणी'**
  String get visitRemarks;

  /// No description provided for @visitPickDate.
  ///
  /// In hi, this message translates to:
  /// **'तारीख़ चुनें'**
  String get visitPickDate;

  /// No description provided for @errOutcomeRequired.
  ///
  /// In hi, this message translates to:
  /// **'हर सदस्य का परिणाम चुनें'**
  String get errOutcomeRequired;

  /// No description provided for @errFormRequired.
  ///
  /// In hi, this message translates to:
  /// **'कौन सा फॉर्म भरना है, चुनें'**
  String get errFormRequired;

  /// No description provided for @errConsentRequired.
  ///
  /// In hi, this message translates to:
  /// **'मोबाइल नंबर के लिए सहमति ज़रूरी है'**
  String get errConsentRequired;

  /// No description provided for @errRevisitRequired.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा जाने की तारीख़ चुनें'**
  String get errRevisitRequired;

  /// No description provided for @formAlreadyOpen.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म {type} पहले से दर्ज है'**
  String formAlreadyOpen(String type);

  /// No description provided for @visitSaved.
  ///
  /// In hi, this message translates to:
  /// **'भेंट सेव हुई'**
  String get visitSaved;

  /// No description provided for @save.
  ///
  /// In hi, this message translates to:
  /// **'सेव करें'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In hi, this message translates to:
  /// **'रद्द करें'**
  String get cancel;

  /// No description provided for @formTitle.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म विवरण'**
  String get formTitle;

  /// No description provided for @formOf.
  ///
  /// In hi, this message translates to:
  /// **'{name} – फॉर्म {type}'**
  String formOf(String name, String type);

  /// No description provided for @formRoute.
  ///
  /// In hi, this message translates to:
  /// **'कैसे जमा हुआ'**
  String get formRoute;

  /// No description provided for @formReference.
  ///
  /// In hi, this message translates to:
  /// **'रसीद / संदर्भ संख्या'**
  String get formReference;

  /// No description provided for @formFiledOn.
  ///
  /// In hi, this message translates to:
  /// **'जमा की तारीख़'**
  String get formFiledOn;

  /// No description provided for @formPhotoLater.
  ///
  /// In hi, this message translates to:
  /// **'रसीद की फोटो – अगले संस्करण में'**
  String get formPhotoLater;

  /// No description provided for @formTimeline.
  ///
  /// In hi, this message translates to:
  /// **'स्थिति'**
  String get formTimeline;

  /// No description provided for @formSaveDetails.
  ///
  /// In hi, this message translates to:
  /// **'विवरण सेव करें'**
  String get formSaveDetails;

  /// No description provided for @formMarkSubmitted.
  ///
  /// In hi, this message translates to:
  /// **'जमा हुआ दर्ज करें'**
  String get formMarkSubmitted;

  /// No description provided for @errReceiptRequired.
  ///
  /// In hi, this message translates to:
  /// **'रसीद / संदर्भ संख्या ज़रूरी है'**
  String get errReceiptRequired;

  /// No description provided for @errRouteRequired.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म कैसे जमा हुआ, यह चुनें'**
  String get errRouteRequired;

  /// No description provided for @formBla2Only.
  ///
  /// In hi, this message translates to:
  /// **'बीएलए-2 के माध्यम वाला फॉर्म बीएलए-2 ही जमा दर्ज करेंगे'**
  String get formBla2Only;

  /// No description provided for @formQuotaWarn.
  ///
  /// In hi, this message translates to:
  /// **'ध्यान दें: आज {today}/{dailyLimit} और कुल {total}/{totalLimit} जमा हो चुके'**
  String formQuotaWarn(int today, int dailyLimit, int total, int totalLimit);

  /// No description provided for @formQuotaDailyFull.
  ///
  /// In hi, this message translates to:
  /// **'आज की सीमा (10) पूरी – फॉर्म स्वयं या ऑनलाइन जमा करें'**
  String get formQuotaDailyFull;

  /// No description provided for @formQuotaTotalFull.
  ///
  /// In hi, this message translates to:
  /// **'कुल सीमा (30) पूरी – फॉर्म स्वयं या ऑनलाइन जमा करें'**
  String get formQuotaTotalFull;

  /// No description provided for @formLocked.
  ///
  /// In hi, this message translates to:
  /// **'यह फॉर्म जमा हो चुका है – आगे की स्थिति कार्यालय दर्ज करेगा'**
  String get formLocked;

  /// No description provided for @formSaved.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म सेव हुआ'**
  String get formSaved;

  /// No description provided for @formSubmittedSaved.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म जमा दर्ज हुआ'**
  String get formSubmittedSaved;

  /// No description provided for @formsTitle.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म स्थिति'**
  String get formsTitle;

  /// No description provided for @formsEmpty.
  ///
  /// In hi, this message translates to:
  /// **'इस स्थिति में कोई फॉर्म नहीं'**
  String get formsEmpty;

  /// No description provided for @syncTitle.
  ///
  /// In hi, this message translates to:
  /// **'सिंक स्थिति'**
  String get syncTitle;

  /// No description provided for @syncPendingCount.
  ///
  /// In hi, this message translates to:
  /// **'भेजना बाकी: {count}'**
  String syncPendingCount(int count);

  /// No description provided for @syncAllSent.
  ///
  /// In hi, this message translates to:
  /// **'सारा डेटा सर्वर पर पहुँच गया'**
  String get syncAllSent;

  /// No description provided for @syncLast.
  ///
  /// In hi, this message translates to:
  /// **'आखिरी सिंक: {time}'**
  String syncLast(String time);

  /// No description provided for @syncNever.
  ///
  /// In hi, this message translates to:
  /// **'अभी तक सिंक नहीं हुआ'**
  String get syncNever;

  /// No description provided for @syncRunning.
  ///
  /// In hi, this message translates to:
  /// **'सिंक हो रहा है…'**
  String get syncRunning;

  /// No description provided for @syncOffline.
  ///
  /// In hi, this message translates to:
  /// **'नेट नहीं है – डेटा फ़ोन में सुरक्षित है'**
  String get syncOffline;

  /// No description provided for @syncServerError.
  ///
  /// In hi, this message translates to:
  /// **'सर्वर से जवाब नहीं मिला – थोड़ी देर बाद फिर कोशिश होगी'**
  String get syncServerError;

  /// No description provided for @syncErrors.
  ///
  /// In hi, this message translates to:
  /// **'त्रुटि'**
  String get syncErrors;

  /// No description provided for @syncRetry.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा भेजें'**
  String get syncRetry;

  /// No description provided for @syncDiscard.
  ///
  /// In hi, this message translates to:
  /// **'हटाएँ'**
  String get syncDiscard;

  /// No description provided for @syncDiscardConfirm.
  ///
  /// In hi, this message translates to:
  /// **'यह बदलाव फ़ोन से हट जाएगा और सर्वर पर नहीं जाएगा। हटाएँ?'**
  String get syncDiscardConfirm;

  /// No description provided for @appVersion.
  ///
  /// In hi, this message translates to:
  /// **'ऐप संस्करण {version}'**
  String appVersion(String version);

  /// No description provided for @entityVisit.
  ///
  /// In hi, this message translates to:
  /// **'भेंट'**
  String get entityVisit;

  /// No description provided for @entityForm.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म'**
  String get entityForm;

  /// No description provided for @entityFormEvent.
  ///
  /// In hi, this message translates to:
  /// **'फॉर्म की स्थिति'**
  String get entityFormEvent;

  /// No description provided for @entityVoter.
  ///
  /// In hi, this message translates to:
  /// **'नया मतदाता'**
  String get entityVoter;

  /// No description provided for @newVoterTitle.
  ///
  /// In hi, this message translates to:
  /// **'नया मतदाता जोड़ें'**
  String get newVoterTitle;

  /// No description provided for @fieldName.
  ///
  /// In hi, this message translates to:
  /// **'नाम'**
  String get fieldName;

  /// No description provided for @fieldRelation.
  ///
  /// In hi, this message translates to:
  /// **'संबंध'**
  String get fieldRelation;

  /// No description provided for @fieldRelativeName.
  ///
  /// In hi, this message translates to:
  /// **'संबंधी का नाम'**
  String get fieldRelativeName;

  /// No description provided for @fieldAge.
  ///
  /// In hi, this message translates to:
  /// **'आयु'**
  String get fieldAge;

  /// No description provided for @fieldGender.
  ///
  /// In hi, this message translates to:
  /// **'लिंग'**
  String get fieldGender;

  /// No description provided for @fieldEpic.
  ///
  /// In hi, this message translates to:
  /// **'EPIC (अगर है)'**
  String get fieldEpic;

  /// No description provided for @errRequired.
  ///
  /// In hi, this message translates to:
  /// **'ज़रूरी है'**
  String get errRequired;

  /// No description provided for @errAge.
  ///
  /// In hi, this message translates to:
  /// **'सही आयु डालें'**
  String get errAge;

  /// No description provided for @ageUnder18.
  ///
  /// In hi, this message translates to:
  /// **'आयु 1 जनवरी 2027 को 18 से कम'**
  String get ageUnder18;

  /// No description provided for @newVoterSaved.
  ///
  /// In hi, this message translates to:
  /// **'नया मतदाता जोड़ा गया'**
  String get newVoterSaved;

  /// No description provided for @visitAdd.
  ///
  /// In hi, this message translates to:
  /// **'भेंट दर्ज करें'**
  String get visitAdd;

  /// No description provided for @syncNow.
  ///
  /// In hi, this message translates to:
  /// **'अभी सिंक करें'**
  String get syncNow;

  /// No description provided for @visitWhoMet.
  ///
  /// In hi, this message translates to:
  /// **'कौन मिला?'**
  String get visitWhoMet;

  /// No description provided for @visitRevisit.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा कब जाना है'**
  String get visitRevisit;

  /// No description provided for @locTitle.
  ///
  /// In hi, this message translates to:
  /// **'स्थान की अनुमति ज़रूरी है'**
  String get locTitle;

  /// No description provided for @locExplain.
  ///
  /// In hi, this message translates to:
  /// **'हर भेंट सेव करते समय उसी जगह का सटीक स्थान (GPS) दर्ज होता है। ऐप पीछे से (बैकग्राउंड में) आपका स्थान नहीं लेता – सिर्फ़ सेव दबाने पर।'**
  String get locExplain;

  /// No description provided for @locAllow.
  ///
  /// In hi, this message translates to:
  /// **'अनुमति दें'**
  String get locAllow;

  /// No description provided for @locOpenSettings.
  ///
  /// In hi, this message translates to:
  /// **'सेटिंग खोलें'**
  String get locOpenSettings;

  /// No description provided for @locTurnOn.
  ///
  /// In hi, this message translates to:
  /// **'लोकेशन चालू करें'**
  String get locTurnOn;

  /// No description provided for @locCheckAgain.
  ///
  /// In hi, this message translates to:
  /// **'दोबारा जाँचें'**
  String get locCheckAgain;

  /// No description provided for @locDenied.
  ///
  /// In hi, this message translates to:
  /// **'स्थान की अनुमति नहीं मिली। “अनुमति दें” दबाएँ और “ऐप इस्तेमाल करते समय” व “सटीक” चुनें।'**
  String get locDenied;

  /// No description provided for @locBlocked.
  ///
  /// In hi, this message translates to:
  /// **'स्थान की अनुमति बंद है। सेटिंग खोलें, “स्थान” चुनें, फिर “ऐप इस्तेमाल करते समय” और “सटीक स्थान” चालू करें।'**
  String get locBlocked;

  /// No description provided for @locDeniedWeb.
  ///
  /// In hi, this message translates to:
  /// **'स्थान की अनुमति नहीं मिली। “अनुमति दें” दबाएँ और ब्राउज़र के सवाल पर “Allow” (अनुमति दें) चुनें।'**
  String get locDeniedWeb;

  /// No description provided for @locBlockedWeb.
  ///
  /// In hi, this message translates to:
  /// **'इस वेबसाइट के लिए स्थान बंद (Block) है। ऊपर जहाँ वेबसाइट का पता लिखा है, उसके बाईं ओर के निशान को दबाएँ, फिर “Permissions” या “Site settings” में “Location” को “Allow” करें। उसके बाद “दोबारा जाँचें” दबाएँ।'**
  String get locBlockedWeb;

  /// No description provided for @locApproximate.
  ///
  /// In hi, this message translates to:
  /// **'अभी सिर्फ़ अनुमानित स्थान की अनुमति है। सटीक स्थान चालू करें।'**
  String get locApproximate;

  /// No description provided for @locServiceOff.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोन की लोकेशन बंद है। लोकेशन चालू करें।'**
  String get locServiceOff;

  /// No description provided for @visitLocationNote.
  ///
  /// In hi, this message translates to:
  /// **'सेव दबाने पर इसी जगह का सटीक स्थान दर्ज होगा'**
  String get visitLocationNote;

  /// No description provided for @visitLocating.
  ///
  /// In hi, this message translates to:
  /// **'सटीक स्थान दर्ज हो रहा है…'**
  String get visitLocating;

  /// No description provided for @visitSavedWithGps.
  ///
  /// In hi, this message translates to:
  /// **'भेंट सेव हुई · स्थान दर्ज (लगभग {meters} मीटर तक सटीक)'**
  String visitSavedWithGps(int meters);

  /// No description provided for @visitSavedRoughGps.
  ///
  /// In hi, this message translates to:
  /// **'भेंट सेव हुई · स्थान दर्ज, पर सटीक नहीं (लगभग {meters} मीटर)'**
  String visitSavedRoughGps(int meters);

  /// No description provided for @visitSavedNoGps.
  ///
  /// In hi, this message translates to:
  /// **'भेंट सेव हुई · स्थान नहीं मिल पाया (रिकॉर्ड में दर्ज)'**
  String get visitSavedNoGps;

  /// No description provided for @homePeopleCount.
  ///
  /// In hi, this message translates to:
  /// **'{count} लोग'**
  String homePeopleCount(int count);

  /// No description provided for @boothPeopleProgress.
  ///
  /// In hi, this message translates to:
  /// **'{done}/{total} लोग पूरे'**
  String boothPeopleProgress(int done, int total);

  /// No description provided for @listShowingPeople.
  ///
  /// In hi, this message translates to:
  /// **'{shown} / {total} लोग'**
  String listShowingPeople(int shown, int total);

  /// No description provided for @listEmptyPeople.
  ///
  /// In hi, this message translates to:
  /// **'इस बूथ में कोई व्यक्ति नहीं है'**
  String get listEmptyPeople;

  /// No description provided for @listNoMatchPeople.
  ///
  /// In hi, this message translates to:
  /// **'खोज से कोई व्यक्ति नहीं मिला'**
  String get listNoMatchPeople;

  /// No description provided for @personTitle.
  ///
  /// In hi, this message translates to:
  /// **'व्यक्ति विवरण'**
  String get personTitle;

  /// No description provided for @personSameRecord.
  ///
  /// In hi, this message translates to:
  /// **'इसी घर में दर्ज लोग'**
  String get personSameRecord;

  /// No description provided for @visitSameHouse.
  ///
  /// In hi, this message translates to:
  /// **'इसी घर के और लोग?'**
  String get visitSameHouse;

  /// No description provided for @visitSameHouseHint.
  ///
  /// In hi, this message translates to:
  /// **'सूची में पास-पास दर्ज, इसी मकान नंबर वाले लोग। घर वालों से पूछकर जो यहीं के हैं, उन्हें चुनें।'**
  String get visitSameHouseHint;

  /// No description provided for @visitNoSuggestions.
  ///
  /// In hi, this message translates to:
  /// **'इसी मकान नंबर वाला और कोई सूची में पास में नहीं है'**
  String get visitNoSuggestions;

  /// No description provided for @contactTitle.
  ///
  /// In hi, this message translates to:
  /// **'घर पर कौन मिला'**
  String get contactTitle;

  /// No description provided for @contactName.
  ///
  /// In hi, this message translates to:
  /// **'नाम'**
  String get contactName;

  /// No description provided for @contactRelation.
  ///
  /// In hi, this message translates to:
  /// **'सूची वाले व्यक्ति से संबंध'**
  String get contactRelation;

  /// No description provided for @contactMobile.
  ///
  /// In hi, this message translates to:
  /// **'मोबाइल नंबर'**
  String get contactMobile;

  /// No description provided for @contactRefused.
  ///
  /// In hi, this message translates to:
  /// **'नंबर देने से मना किया'**
  String get contactRefused;

  /// No description provided for @errContactName.
  ///
  /// In hi, this message translates to:
  /// **'घर पर मिले व्यक्ति का नाम डालें'**
  String get errContactName;

  /// No description provided for @errContactRequired.
  ///
  /// In hi, this message translates to:
  /// **'घर पर मिले व्यक्ति का मोबाइल नंबर डालें या “नंबर देने से मना किया” चुनें'**
  String get errContactRequired;

  /// No description provided for @memberMobile.
  ///
  /// In hi, this message translates to:
  /// **'इस व्यक्ति का अपना मोबाइल नंबर (अगर दें)'**
  String get memberMobile;

  /// No description provided for @relFather.
  ///
  /// In hi, this message translates to:
  /// **'पिता'**
  String get relFather;

  /// No description provided for @relMother.
  ///
  /// In hi, this message translates to:
  /// **'माता'**
  String get relMother;

  /// No description provided for @relHusband.
  ///
  /// In hi, this message translates to:
  /// **'पति'**
  String get relHusband;

  /// No description provided for @relWife.
  ///
  /// In hi, this message translates to:
  /// **'पत्नी'**
  String get relWife;

  /// No description provided for @relSon.
  ///
  /// In hi, this message translates to:
  /// **'बेटा'**
  String get relSon;

  /// No description provided for @relDaughter.
  ///
  /// In hi, this message translates to:
  /// **'बेटी'**
  String get relDaughter;

  /// No description provided for @relSibling.
  ///
  /// In hi, this message translates to:
  /// **'भाई/बहन'**
  String get relSibling;

  /// No description provided for @relSelf.
  ///
  /// In hi, this message translates to:
  /// **'स्वयं'**
  String get relSelf;

  /// No description provided for @relOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य'**
  String get relOther;

  /// No description provided for @houseAndBooth.
  ///
  /// In hi, this message translates to:
  /// **'मकान नं. {house} · बूथ {partNo}'**
  String houseAndBooth(String house, int partNo);

  /// No description provided for @homeAllSent.
  ///
  /// In hi, this message translates to:
  /// **'सब भेजा गया'**
  String get homeAllSent;

  /// No description provided for @catUntraceable.
  ///
  /// In hi, this message translates to:
  /// **'अनुपस्थित बताया गया'**
  String get catUntraceable;

  /// No description provided for @catShifted.
  ///
  /// In hi, this message translates to:
  /// **'स्थानांतरित बताया गया'**
  String get catShifted;

  /// No description provided for @catDeceased.
  ///
  /// In hi, this message translates to:
  /// **'मृत बताया गया'**
  String get catDeceased;

  /// No description provided for @catDuplicate.
  ///
  /// In hi, this message translates to:
  /// **'दोहरा नाम'**
  String get catDuplicate;

  /// No description provided for @catAlreadyBack.
  ///
  /// In hi, this message translates to:
  /// **'सूची में वापस'**
  String get catAlreadyBack;

  /// No description provided for @catPossHigh.
  ///
  /// In hi, this message translates to:
  /// **'हटाया गया (पक्का)'**
  String get catPossHigh;

  /// No description provided for @catPossMedium.
  ///
  /// In hi, this message translates to:
  /// **'हटाया गया (शायद)'**
  String get catPossMedium;

  /// No description provided for @catPossLow.
  ///
  /// In hi, this message translates to:
  /// **'शायद सूची में है'**
  String get catPossLow;

  /// No description provided for @catAdded.
  ///
  /// In hi, this message translates to:
  /// **'नया जोड़ा'**
  String get catAdded;

  /// No description provided for @catHintUntraceable.
  ///
  /// In hi, this message translates to:
  /// **'अनुपस्थित या पता न चलने के कारण नाम हटा। मिलें तो फ़ॉर्म 6 भरवाएँ।'**
  String get catHintUntraceable;

  /// No description provided for @catHintShifted.
  ///
  /// In hi, this message translates to:
  /// **'स्थायी रूप से स्थानांतरित बताकर नाम हटा। देखें कि अब भी यहीं रहते हैं या नहीं।'**
  String get catHintShifted;

  /// No description provided for @catHintDeceased.
  ///
  /// In hi, this message translates to:
  /// **'मृत बताकर नाम हटा। परिवार से पुष्टि करें; जीवित हों तो फ़ॉर्म 6 भरवाएँ।'**
  String get catHintDeceased;

  /// No description provided for @catHintDuplicate.
  ///
  /// In hi, this message translates to:
  /// **'दोहरी प्रविष्टि बताकर नाम हटा। पता करें कि कहीं और नाम दर्ज है या नहीं।'**
  String get catHintDuplicate;

  /// No description provided for @catHintAlreadyBack.
  ///
  /// In hi, this message translates to:
  /// **'अप्रैल 2026 की सूची में नाम वापस आ गया है। भेंट ज़रूरी नहीं।'**
  String get catHintAlreadyBack;

  /// No description provided for @catHintPossHigh.
  ///
  /// In hi, this message translates to:
  /// **'ड्राफ्ट सूची (17 नवंबर) में कोई मिलता-जुलता नाम नहीं मिला। नाम हटने की सबसे ज़्यादा संभावना।'**
  String get catHintPossHigh;

  /// No description provided for @catHintPossMedium.
  ///
  /// In hi, this message translates to:
  /// **'ड्राफ्ट सूची में सिर्फ़ कमज़ोर मिलान मिला। नाम हटा हो सकता है।'**
  String get catHintPossMedium;

  /// No description provided for @catHintPossLow.
  ///
  /// In hi, this message translates to:
  /// **'ड्राफ्ट सूची में मिलता-जुलता नाम है, शायद नाम अभी भी दर्ज है। भेंट से पहले नीचे की प्रविष्टि जाँचें।'**
  String get catHintPossLow;

  /// No description provided for @catHintAdded.
  ///
  /// In hi, this message translates to:
  /// **'मैदान में जोड़ा गया नया मतदाता।'**
  String get catHintAdded;

  /// No description provided for @catFilterAll.
  ///
  /// In hi, this message translates to:
  /// **'सभी श्रेणियाँ'**
  String get catFilterAll;

  /// No description provided for @categoryTitle.
  ///
  /// In hi, this message translates to:
  /// **'श्रेणी'**
  String get categoryTitle;

  /// No description provided for @closestEntry.
  ///
  /// In hi, this message translates to:
  /// **'सूची में मिलती-जुलती प्रविष्टि (पहले जाँचें): {entry}'**
  String closestEntry(String entry);

  /// No description provided for @searchTitle.
  ///
  /// In hi, this message translates to:
  /// **'लोग खोजें'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In hi, this message translates to:
  /// **'नाम, पिता/पति का नाम, EPIC या मकान नंबर'**
  String get searchHint;

  /// No description provided for @searchStart.
  ///
  /// In hi, this message translates to:
  /// **'नाम हिंदी या अंग्रेज़ी में लिखें, जैसे “ramesh” या “रमेश”। आपके सभी बूथों में खोजा जाएगा।'**
  String get searchStart;

  /// No description provided for @searchNoResult.
  ///
  /// In hi, this message translates to:
  /// **'कोई नहीं मिला। नाम का कुछ हिस्सा या पिता/पति का नाम लिखकर देखें।'**
  String get searchNoResult;

  /// No description provided for @searchResults.
  ///
  /// In hi, this message translates to:
  /// **'{count} लोग मिले'**
  String searchResults(int count);

  /// No description provided for @searchMore.
  ///
  /// In hi, this message translates to:
  /// **'पहले {shown} दिखाए गए। और लिखें ताकि खोज छोटी हो।'**
  String searchMore(int shown);

  /// No description provided for @searchOpen.
  ///
  /// In hi, this message translates to:
  /// **'लोग खोजें: नाम, EPIC या मकान नंबर'**
  String get searchOpen;

  /// No description provided for @visitAddBySearch.
  ///
  /// In hi, this message translates to:
  /// **'परिवार के और सदस्य खोजकर जोड़ें'**
  String get visitAddBySearch;

  /// No description provided for @visitAddBySearchHint.
  ///
  /// In hi, this message translates to:
  /// **'दरवाज़े पर पूछें कि घर में और कौन-कौन है, फिर उनके नाम खोजकर जोड़ें। सब एक ही परिवार में गिने जाएँगे।'**
  String get visitAddBySearchHint;

  /// No description provided for @visitPickTitle.
  ///
  /// In hi, this message translates to:
  /// **'इस घर का सदस्य चुनें'**
  String get visitPickTitle;

  /// No description provided for @visitAlreadyAdded.
  ///
  /// In hi, this message translates to:
  /// **'पहले से जोड़ा गया'**
  String get visitAlreadyAdded;

  /// No description provided for @personHousehold.
  ///
  /// In hi, this message translates to:
  /// **'भेंट में इसी घर के बताए गए लोग'**
  String get personHousehold;

  /// No description provided for @photoTitle.
  ///
  /// In hi, this message translates to:
  /// **'चेहरे की फ़ोटो'**
  String get photoTitle;

  /// No description provided for @photoHint.
  ///
  /// In hi, this message translates to:
  /// **'व्यक्ति से पूछकर सामने से, अच्छी रोशनी में फ़ोटो लें।'**
  String get photoHint;

  /// No description provided for @photoTake.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोटो लें'**
  String get photoTake;

  /// No description provided for @photoRetake.
  ///
  /// In hi, this message translates to:
  /// **'बदलें'**
  String get photoRetake;

  /// No description provided for @photoRemove.
  ///
  /// In hi, this message translates to:
  /// **'हटाएँ'**
  String get photoRemove;

  /// No description provided for @photoOnServer.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोटो भेजी जा चुकी है'**
  String get photoOnServer;

  /// No description provided for @photoWaiting.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोटो फ़ोन पर है, नेटवर्क मिलते ही भेजी जाएगी'**
  String get photoWaiting;

  /// No description provided for @photoMissing.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोटो नहीं ली गई'**
  String get photoMissing;

  /// No description provided for @photoFailed.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोटो नहीं खुली। दोबारा कोशिश करें।'**
  String get photoFailed;

  /// No description provided for @photoSaved.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोटो सेव हुई'**
  String get photoSaved;

  /// No description provided for @newVoterReason.
  ///
  /// In hi, this message translates to:
  /// **'क्यों जोड़ रहे हैं?'**
  String get newVoterReason;

  /// No description provided for @newReasonTurned18.
  ///
  /// In hi, this message translates to:
  /// **'इस साल 18 के हुए'**
  String get newReasonTurned18;

  /// No description provided for @newReasonOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य'**
  String get newReasonOther;

  /// No description provided for @newReasonNote.
  ///
  /// In hi, this message translates to:
  /// **'कारण लिखें (जैसे: कभी नाम नहीं जुड़ा, बाहर से आकर बसे)'**
  String get newReasonNote;

  /// No description provided for @errNewReason.
  ///
  /// In hi, this message translates to:
  /// **'बताएँ कि क्यों जोड़ रहे हैं'**
  String get errNewReason;

  /// No description provided for @errTurned18Age.
  ///
  /// In hi, this message translates to:
  /// **'इस साल 18 के हुए: उम्र 17 या 18 होनी चाहिए'**
  String get errTurned18Age;

  /// No description provided for @newVoterBooth.
  ///
  /// In hi, this message translates to:
  /// **'बूथ'**
  String get newVoterBooth;

  /// No description provided for @newVoterHouse.
  ///
  /// In hi, this message translates to:
  /// **'मकान नंबर'**
  String get newVoterHouse;

  /// No description provided for @newVoterHouseHint.
  ///
  /// In hi, this message translates to:
  /// **'इस घर में सूची का कोई व्यक्ति नहीं है, इसलिए नया घर दर्ज होगा।'**
  String get newVoterHouseHint;

  /// No description provided for @errNewVoterHouse.
  ///
  /// In hi, this message translates to:
  /// **'मकान नंबर लिखें'**
  String get errNewVoterHouse;

  /// No description provided for @newVoterOpen.
  ///
  /// In hi, this message translates to:
  /// **'नया मतदाता जोड़ें'**
  String get newVoterOpen;

  /// No description provided for @newVoterOpenHint.
  ///
  /// In hi, this message translates to:
  /// **'जिनका नाम सूची में नहीं है, जैसे जो इस साल 18 के हुए'**
  String get newVoterOpenHint;

  /// No description provided for @catOnDraftRoll.
  ///
  /// In hi, this message translates to:
  /// **'ड्राफ्ट सूची में नाम है'**
  String get catOnDraftRoll;

  /// No description provided for @catHintOnDraftRoll.
  ///
  /// In hi, this message translates to:
  /// **'17 नवंबर की ड्राफ्ट सूची में नाम मिल गया है, भेंट ज़रूरी नहीं। नीचे लिखी प्रविष्टि से मिलान कर लें।'**
  String get catHintOnDraftRoll;

  /// No description provided for @draftPartLine.
  ///
  /// In hi, this message translates to:
  /// **'2027 ड्राफ्ट सूची: भाग {part}'**
  String draftPartLine(int part);

  /// No description provided for @draftPartSectionLine.
  ///
  /// In hi, this message translates to:
  /// **'2027 ड्राफ्ट सूची: भाग {part}, सेक्शन {section}'**
  String draftPartSectionLine(int part, String section);

  /// No description provided for @outcomeOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य कारण'**
  String get outcomeOther;

  /// No description provided for @visitChoose.
  ///
  /// In hi, this message translates to:
  /// **'क्या हुआ?'**
  String get visitChoose;

  /// No description provided for @visitOptNotMetHint.
  ///
  /// In hi, this message translates to:
  /// **'घर पर कोई नहीं था, या यह व्यक्ति नहीं मिला'**
  String get visitOptNotMetHint;

  /// No description provided for @visitOptForm6.
  ///
  /// In hi, this message translates to:
  /// **'नाम कट गया है, फ़ॉर्म 6 भरना है'**
  String get visitOptForm6;

  /// No description provided for @visitOptForm6Hint.
  ///
  /// In hi, this message translates to:
  /// **'ECI ऐप में फ़ॉर्म 6 भरें, फिर उसका स्क्रीनशॉट यहाँ लगाएँ'**
  String get visitOptForm6Hint;

  /// No description provided for @visitOptOther.
  ///
  /// In hi, this message translates to:
  /// **'अन्य कारण'**
  String get visitOptOther;

  /// No description provided for @visitOptOtherHint.
  ///
  /// In hi, this message translates to:
  /// **'कोई और बात, जैसे नाम सूची में है या मृत्यु हो गई'**
  String get visitOptOtherHint;

  /// No description provided for @revisitTomorrow.
  ///
  /// In hi, this message translates to:
  /// **'कल'**
  String get revisitTomorrow;

  /// No description provided for @revisitDayAfter.
  ///
  /// In hi, this message translates to:
  /// **'परसों'**
  String get revisitDayAfter;

  /// No description provided for @revisitIn3Days.
  ///
  /// In hi, this message translates to:
  /// **'3 दिन बाद'**
  String get revisitIn3Days;

  /// No description provided for @eciReminderTitle.
  ///
  /// In hi, this message translates to:
  /// **'पहले ECI ऐप में फ़ॉर्म 6 भरें'**
  String get eciReminderTitle;

  /// No description provided for @eciReminderBody.
  ///
  /// In hi, this message translates to:
  /// **'1. ECI ऐप (Voter Helpline) में इस व्यक्ति का फ़ॉर्म 6 भरकर जमा करें।\n2. फिर ऐप में “Track application status” खोलें और उस पेज का स्क्रीनशॉट लें। ऐप की भाषा अंग्रेज़ी (English) रखें।\n3. वह स्क्रीनशॉट यहाँ लगाएँ। उसके बिना भेंट सेव नहीं होगी।'**
  String get eciReminderBody;

  /// No description provided for @eciReminderOk.
  ///
  /// In hi, this message translates to:
  /// **'ठीक है'**
  String get eciReminderOk;

  /// No description provided for @eciExample.
  ///
  /// In hi, this message translates to:
  /// **'उदाहरण देखें'**
  String get eciExample;

  /// No description provided for @eciExampleTitle.
  ///
  /// In hi, this message translates to:
  /// **'ऐसा स्क्रीनशॉट लगाएँ'**
  String get eciExampleTitle;

  /// No description provided for @eciExampleNote.
  ///
  /// In hi, this message translates to:
  /// **'Reference Number, नाम (First Name) और Form Type साफ़ दिखने चाहिए। इस उदाहरण में वे छिपाए गए हैं।'**
  String get eciExampleNote;

  /// No description provided for @eciTitle.
  ///
  /// In hi, this message translates to:
  /// **'ECI स्क्रीनशॉट (ज़रूरी)'**
  String get eciTitle;

  /// No description provided for @eciHint.
  ///
  /// In hi, this message translates to:
  /// **'ECI ऐप के “Track application status” पेज का स्क्रीनशॉट, अंग्रेज़ी में'**
  String get eciHint;

  /// No description provided for @eciAdd.
  ///
  /// In hi, this message translates to:
  /// **'स्क्रीनशॉट लगाएँ'**
  String get eciAdd;

  /// No description provided for @eciOnServer.
  ///
  /// In hi, this message translates to:
  /// **'स्क्रीनशॉट भेजा जा चुका है'**
  String get eciOnServer;

  /// No description provided for @eciWaiting.
  ///
  /// In hi, this message translates to:
  /// **'स्क्रीनशॉट फ़ोन पर है, नेटवर्क मिलते ही भेजा जाएगा'**
  String get eciWaiting;

  /// No description provided for @eciMissing.
  ///
  /// In hi, this message translates to:
  /// **'ECI स्क्रीनशॉट नहीं लगा है। इसे लगाएँ।'**
  String get eciMissing;

  /// No description provided for @eciReadPending.
  ///
  /// In hi, this message translates to:
  /// **'स्क्रीनशॉट पढ़ा जा रहा है…'**
  String get eciReadPending;

  /// No description provided for @eciReadOk.
  ///
  /// In hi, this message translates to:
  /// **'ECI से पढ़ा गया: {reference}'**
  String eciReadOk(String reference);

  /// No description provided for @eciReadFailed.
  ///
  /// In hi, this message translates to:
  /// **'स्क्रीनशॉट पढ़ा नहीं जा सका। साफ़ स्क्रीनशॉट दोबारा लगाएँ।'**
  String get eciReadFailed;

  /// No description provided for @eciNotEci.
  ///
  /// In hi, this message translates to:
  /// **'यह ECI का स्क्रीनशॉट नहीं लगता। सही स्क्रीनशॉट लगाएँ।'**
  String get eciNotEci;

  /// No description provided for @errEciRequired.
  ///
  /// In hi, this message translates to:
  /// **'ECI ऐप का स्क्रीनशॉट लगाएँ'**
  String get errEciRequired;

  /// No description provided for @errChooseOption.
  ///
  /// In hi, this message translates to:
  /// **'ऊपर तीन में से एक चुनें'**
  String get errChooseOption;

  /// No description provided for @otherWhat.
  ///
  /// In hi, this message translates to:
  /// **'क्या कारण है?'**
  String get otherWhat;

  /// No description provided for @otherOnRoll.
  ///
  /// In hi, this message translates to:
  /// **'नाम सूची में है'**
  String get otherOnRoll;

  /// No description provided for @otherDead.
  ///
  /// In hi, this message translates to:
  /// **'मृत्यु हो गई'**
  String get otherDead;

  /// No description provided for @otherShifted.
  ///
  /// In hi, this message translates to:
  /// **'हमेशा के लिए कहीं और चले गए'**
  String get otherShifted;

  /// No description provided for @otherSomething.
  ///
  /// In hi, this message translates to:
  /// **'कुछ और'**
  String get otherSomething;

  /// No description provided for @otherReason.
  ///
  /// In hi, this message translates to:
  /// **'कारण लिखें'**
  String get otherReason;

  /// No description provided for @otherReasonOptional.
  ///
  /// In hi, this message translates to:
  /// **'कुछ और बताना हो तो लिखें'**
  String get otherReasonOptional;

  /// No description provided for @errOtherReason.
  ///
  /// In hi, this message translates to:
  /// **'कारण लिखें'**
  String get errOtherReason;

  /// No description provided for @form6AlreadyOpen.
  ///
  /// In hi, this message translates to:
  /// **'इस व्यक्ति का फ़ॉर्म 6 पहले से खुला है। स्क्रीनशॉट उसी में जुड़ेगा।'**
  String get form6AlreadyOpen;
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
