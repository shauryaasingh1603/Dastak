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
  /// **'सारा डेटा सर्वर पर है ✓'**
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
  /// **'भेंट सेव हुई · स्थान दर्ज (±{meters} मीटर)'**
  String visitSavedWithGps(int meters);

  /// No description provided for @visitSavedRoughGps.
  ///
  /// In hi, this message translates to:
  /// **'भेंट सेव हुई · स्थान दर्ज, पर सटीक नहीं (±{meters} मीटर)'**
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
