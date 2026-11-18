// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'दस्तक';

  @override
  String get loginTitle => 'लॉगिन';

  @override
  String get loginMobileLabel => 'मोबाइल नंबर डालें';

  @override
  String get loginMobileHint => '10 अंकों का नंबर';

  @override
  String get loginSubmit => 'आगे बढ़ें';

  @override
  String get loginHelp =>
      'आपका नंबर कार्यालय में दर्ज होना चाहिए। लॉगिन के लिए एडमिन की मंज़ूरी ज़रूरी है।';

  @override
  String get waitingTitle => 'मंज़ूरी का इंतज़ार';

  @override
  String get waitingCodeLabel => 'आपका कोड';

  @override
  String get waitingInstruction =>
      'यह कोड एडमिन को बताएँ। मंज़ूरी मिलते ही ऐप अपने आप खुल जाएगा।';

  @override
  String get waitingChecking => 'मंज़ूरी की जाँच हो रही है…';

  @override
  String get waitingOffline => 'नेट नहीं है – नेट आते ही जाँच होगी';

  @override
  String get waitingCancel => 'नंबर बदलें';

  @override
  String get errMobileInvalid => 'सही मोबाइल नंबर डालें';

  @override
  String get errNotRegistered =>
      'यह नंबर दर्ज नहीं है। कार्यालय से संपर्क करें।';

  @override
  String get errTooMany => 'बहुत बार कोशिश हुई। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errNetwork => 'नेट नहीं है – दोबारा कोशिश करें';

  @override
  String get errGeneric => 'कुछ गड़बड़ हुई। दोबारा कोशिश करें।';

  @override
  String get loginRejected =>
      'एडमिन ने मंज़ूरी नहीं दी। कार्यालय से संपर्क करें।';

  @override
  String get loginExpired => 'अनुरोध का समय समाप्त हो गया। दोबारा कोशिश करें।';

  @override
  String get accessRevoked =>
      'इस फ़ोन से लॉगिन हटा दिया गया है। दोबारा लॉगिन करें।';

  @override
  String get homeTitle => 'आज का सारांश';

  @override
  String homeGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get roleVolunteer => 'स्वयंसेवक';

  @override
  String get roleBla2 => 'बीएलए-2';

  @override
  String get homeBooths => 'आपके बूथ';

  @override
  String get homeNoBooths =>
      'अभी कोई बूथ नहीं सौंपा गया है। कार्यालय से संपर्क करें।';

  @override
  String homeFamilyCount(int count) {
    return '$count परिवार';
  }

  @override
  String get homeBoothsHint => 'बूथ पर टैप करें – उस बूथ के परिवार खुलेंगे';

  @override
  String boothNumber(int partNo) {
    return 'बूथ $partNo';
  }

  @override
  String sectionHeader(int sectionNo) {
    return 'अनुभाग $sectionNo';
  }

  @override
  String get sectionUnknown => 'अनुभाग दर्ज नहीं';

  @override
  String get listSearchHint => 'नाम, EPIC या मकान नं. खोजें';

  @override
  String get listEmpty => 'इस बूथ में कोई परिवार नहीं है';

  @override
  String get listNoMatch => 'खोज से कोई परिवार नहीं मिला';

  @override
  String listShowing(int shown, int total) {
    return '$shown / $total परिवार';
  }

  @override
  String get homeOffline => 'नेट नहीं है – पिछली जानकारी दिख रही है';

  @override
  String get listTitle => 'मेरी सूची';

  @override
  String houseNo(String no) {
    return 'मकान नं. $no';
  }

  @override
  String get priorityHigh => 'उच्च प्राथमिकता';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirm =>
      'क्या आप लॉगआउट करना चाहते हैं? दोबारा लॉगिन के लिए एडमिन की मंज़ूरी लगेगी।';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get retry => 'दोबारा कोशिश करें';

  @override
  String get navHome => 'सारांश';

  @override
  String get navList => 'मेरी सूची';

  @override
  String get navForms => 'फॉर्म';

  @override
  String get navSync => 'सिंक';

  @override
  String get homeTarget => 'आज का लक्ष्य';

  @override
  String get homeDoneToday => 'आज पूरे';

  @override
  String get homeRemaining => 'बाकी परिवार';

  @override
  String get homeRevisitToday => 'आज दोबारा जाना है';

  @override
  String get homeFormsFilled => 'भरे गए फॉर्म';

  @override
  String get homeSyncState => 'सिंक स्थिति';

  @override
  String homeDeadline(int days) {
    return 'अंतिम तिथि: 16 दिसंबर – $days दिन बाकी';
  }

  @override
  String get homeDeadlineToday => 'अंतिम तिथि: आज (16 दिसंबर)';

  @override
  String get claimsClosed => 'दावा अवधि समाप्त (16 दिसंबर)';

  @override
  String get outboxStale => 'डेटा अभी सर्वर पर नहीं गया – नेट से जुड़ें';

  @override
  String quotaLine(int today, int dailyLimit, int total, int totalLimit) {
    return 'आज जमा: $today/$dailyLimit · कुल: $total/$totalLimit';
  }

  @override
  String get firstSyncLoading => 'आपकी सूची डाउनलोड हो रही है…';

  @override
  String get firstSyncFailed =>
      'सूची डाउनलोड नहीं हुई – नेट से जुड़कर दोबारा कोशिश करें';

  @override
  String get logoutBlocked => 'पहले सारा डेटा सिंक करें, फिर लॉगआउट करें।';

  @override
  String boothProgress(int done, int total) {
    return '$done/$total परिवार पूरे';
  }

  @override
  String get filterAll => 'सभी';

  @override
  String get filterPending => 'बाकी';

  @override
  String get filterDone => 'पूरा';

  @override
  String get filterRevisit => 'दोबारा';

  @override
  String get statusPending => 'बाकी';

  @override
  String get statusDone => 'पूरा';

  @override
  String get statusRevisit => 'दोबारा';

  @override
  String get needsReview => 'कार्यालय समीक्षा';

  @override
  String get newVoterTag => 'नया';

  @override
  String get onRollTag => 'सूची में नाम है';

  @override
  String get notSynced => 'सिंक बाकी';

  @override
  String get outcomeEligible => 'पात्र – फॉर्म भराना है';

  @override
  String get outcomeCorrection => 'सुधार चाहिए';

  @override
  String get outcomeMovedIn => 'यहाँ आए हैं';

  @override
  String get outcomeShifted => 'स्थानांतरित';

  @override
  String get outcomeDead => 'मृत्यु';

  @override
  String get outcomeNotMet => 'नहीं मिले';

  @override
  String get outcomeOnRoll => 'सूची में नाम है';

  @override
  String get formStatusFilled => 'भरा गया';

  @override
  String get formStatusSubmitted => 'जमा';

  @override
  String get formStatusInEro => 'ईआरओ सूची में';

  @override
  String get formStatusAccepted => 'स्वीकृत';

  @override
  String get formStatusRejected => 'अस्वीकृत';

  @override
  String get formStatusHearing => 'सुनवाई';

  @override
  String get routeBla2 => 'बीएलए-2 के माध्यम से';

  @override
  String get routeSelf => 'स्वयं जमा';

  @override
  String get routeOnline => 'ऑनलाइन';

  @override
  String get docAadhaar => 'आधार';

  @override
  String get docBirthCert => 'जन्म प्रमाणपत्र';

  @override
  String get docHighschool => 'हाईस्कूल मार्कशीट';

  @override
  String get docRation => 'राशन कार्ड';

  @override
  String get docElectricity => 'बिजली बिल';

  @override
  String get docOther => 'अन्य';

  @override
  String formType(String type) {
    return 'फॉर्म $type';
  }

  @override
  String get formNone => 'कोई नहीं';

  @override
  String get reasonShifted => 'कारण: स्थानांतरित';

  @override
  String get reasonUntraceable => 'कारण: पता नहीं चला';

  @override
  String get reasonPossDel => 'कारण: संभवतः हटाया गया';

  @override
  String get relationF => 'पिता';

  @override
  String get relationH => 'पति';

  @override
  String get relationM => 'माता';

  @override
  String get relationO => 'अन्य';

  @override
  String get genderM => 'पुरुष';

  @override
  String get genderF => 'महिला';

  @override
  String get genderO => 'अन्य';

  @override
  String ageYears(int age) {
    return '$age वर्ष';
  }

  @override
  String epicLine(String epic) {
    return 'EPIC: $epic';
  }

  @override
  String get epicMissing => 'EPIC नहीं';

  @override
  String get familyTitle => 'परिवार कार्ड';

  @override
  String familyHead(String name) {
    return 'मुखिया: $name';
  }

  @override
  String get familyMembers => 'सदस्य';

  @override
  String get familyPrevVisits => 'पिछली भेंट';

  @override
  String get familyNoVisits => 'अभी कोई भेंट नहीं';

  @override
  String get voterAdd => 'नया सदस्य जोड़ें';

  @override
  String get visitByMe => 'आप';

  @override
  String get visitByOther => 'अन्य स्वयंसेवक';

  @override
  String revisitOn(String date) {
    return 'दोबारा: $date';
  }

  @override
  String get visitTitle => 'भेंट फॉर्म';

  @override
  String get visitNobodyHome => 'कोई नहीं मिला';

  @override
  String get visitNobodyHomeHint =>
      'घर पर कोई नहीं था – दोबारा आने की तारीख़ चुनें';

  @override
  String get visitWhoMetOther => 'अन्य व्यक्ति';

  @override
  String get visitMembers => 'हर सदस्य का परिणाम';

  @override
  String get visitWhichForm => 'कौन सा फॉर्म?';

  @override
  String get visitDocs => 'देखे गए दस्तावेज़';

  @override
  String get visitMobile => 'मोबाइल नंबर (अगर दें)';

  @override
  String get visitConsent =>
      'आपका नंबर सिर्फ़ मतदाता सूची के काम के लिए लिया जा रहा है';

  @override
  String get visitConsentLabel => 'मतदाता को पढ़कर सुनाया और सहमति ली';

  @override
  String get visitRemarks => 'टिप्पणी';

  @override
  String get visitPickDate => 'तारीख़ चुनें';

  @override
  String get errOutcomeRequired => 'हर सदस्य का परिणाम चुनें';

  @override
  String get errFormRequired => 'कौन सा फॉर्म भरना है, चुनें';

  @override
  String get errConsentRequired => 'मोबाइल नंबर के लिए सहमति ज़रूरी है';

  @override
  String get errRevisitRequired => 'दोबारा जाने की तारीख़ चुनें';

  @override
  String formAlreadyOpen(String type) {
    return 'फॉर्म $type पहले से दर्ज है';
  }

  @override
  String get visitSaved => 'भेंट सेव हुई';

  @override
  String get save => 'सेव करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get formTitle => 'फॉर्म विवरण';

  @override
  String formOf(String name, String type) {
    return '$name – फॉर्म $type';
  }

  @override
  String get formRoute => 'कैसे जमा हुआ';

  @override
  String get formReference => 'रसीद / संदर्भ संख्या';

  @override
  String get formFiledOn => 'जमा की तारीख़';

  @override
  String get formPhotoLater => 'रसीद की फोटो – अगले संस्करण में';

  @override
  String get formTimeline => 'स्थिति';

  @override
  String get formSaveDetails => 'विवरण सेव करें';

  @override
  String get formMarkSubmitted => 'जमा हुआ दर्ज करें';

  @override
  String get errReceiptRequired => 'रसीद / संदर्भ संख्या ज़रूरी है';

  @override
  String get errRouteRequired => 'फॉर्म कैसे जमा हुआ, यह चुनें';

  @override
  String get formBla2Only =>
      'बीएलए-2 के माध्यम वाला फॉर्म बीएलए-2 ही जमा दर्ज करेंगे';

  @override
  String formQuotaWarn(int today, int dailyLimit, int total, int totalLimit) {
    return 'ध्यान दें: आज $today/$dailyLimit और कुल $total/$totalLimit जमा हो चुके';
  }

  @override
  String get formQuotaDailyFull =>
      'आज की सीमा (10) पूरी – फॉर्म स्वयं या ऑनलाइन जमा करें';

  @override
  String get formQuotaTotalFull =>
      'कुल सीमा (30) पूरी – फॉर्म स्वयं या ऑनलाइन जमा करें';

  @override
  String get formLocked =>
      'यह फॉर्म जमा हो चुका है – आगे की स्थिति कार्यालय दर्ज करेगा';

  @override
  String get formSaved => 'फॉर्म सेव हुआ';

  @override
  String get formSubmittedSaved => 'फॉर्म जमा दर्ज हुआ';

  @override
  String get formsTitle => 'फॉर्म स्थिति';

  @override
  String get formsEmpty => 'इस स्थिति में कोई फॉर्म नहीं';

  @override
  String get syncTitle => 'सिंक स्थिति';

  @override
  String syncPendingCount(int count) {
    return 'भेजना बाकी: $count';
  }

  @override
  String get syncAllSent => 'सारा डेटा सर्वर पर है ✓';

  @override
  String syncLast(String time) {
    return 'आखिरी सिंक: $time';
  }

  @override
  String get syncNever => 'अभी तक सिंक नहीं हुआ';

  @override
  String get syncRunning => 'सिंक हो रहा है…';

  @override
  String get syncOffline => 'नेट नहीं है – डेटा फ़ोन में सुरक्षित है';

  @override
  String get syncServerError =>
      'सर्वर से जवाब नहीं मिला – थोड़ी देर बाद फिर कोशिश होगी';

  @override
  String get syncErrors => 'त्रुटि';

  @override
  String get syncRetry => 'दोबारा भेजें';

  @override
  String get syncDiscard => 'हटाएँ';

  @override
  String get syncDiscardConfirm =>
      'यह बदलाव फ़ोन से हट जाएगा और सर्वर पर नहीं जाएगा। हटाएँ?';

  @override
  String appVersion(String version) {
    return 'ऐप संस्करण $version';
  }

  @override
  String get entityVisit => 'भेंट';

  @override
  String get entityForm => 'फॉर्म';

  @override
  String get entityFormEvent => 'फॉर्म की स्थिति';

  @override
  String get entityVoter => 'नया मतदाता';

  @override
  String get newVoterTitle => 'नया मतदाता जोड़ें';

  @override
  String get fieldName => 'नाम';

  @override
  String get fieldRelation => 'संबंध';

  @override
  String get fieldRelativeName => 'संबंधी का नाम';

  @override
  String get fieldAge => 'आयु';

  @override
  String get fieldGender => 'लिंग';

  @override
  String get fieldEpic => 'EPIC (अगर है)';

  @override
  String get errRequired => 'ज़रूरी है';

  @override
  String get errAge => 'सही आयु डालें';

  @override
  String get ageUnder18 => 'आयु 1 जनवरी 2027 को 18 से कम';

  @override
  String get newVoterSaved => 'नया मतदाता जोड़ा गया';

  @override
  String get visitAdd => 'भेंट दर्ज करें';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get visitWhoMet => 'कौन मिला?';

  @override
  String get visitRevisit => 'दोबारा कब जाना है';

  @override
  String get locTitle => 'स्थान की अनुमति ज़रूरी है';

  @override
  String get locExplain =>
      'हर भेंट सेव करते समय उसी जगह का सटीक स्थान (GPS) दर्ज होता है। ऐप पीछे से (बैकग्राउंड में) आपका स्थान नहीं लेता – सिर्फ़ सेव दबाने पर।';

  @override
  String get locAllow => 'अनुमति दें';

  @override
  String get locOpenSettings => 'सेटिंग खोलें';

  @override
  String get locTurnOn => 'लोकेशन चालू करें';

  @override
  String get locCheckAgain => 'दोबारा जाँचें';

  @override
  String get locDenied =>
      'स्थान की अनुमति नहीं मिली। “अनुमति दें” दबाएँ और “ऐप इस्तेमाल करते समय” व “सटीक” चुनें।';

  @override
  String get locBlocked =>
      'स्थान की अनुमति बंद है। सेटिंग खोलें, “स्थान” चुनें, फिर “ऐप इस्तेमाल करते समय” और “सटीक स्थान” चालू करें।';

  @override
  String get locApproximate =>
      'अभी सिर्फ़ अनुमानित स्थान की अनुमति है। सटीक स्थान चालू करें।';

  @override
  String get locServiceOff => 'फ़ोन की लोकेशन बंद है। लोकेशन चालू करें।';

  @override
  String get visitLocationNote =>
      'सेव दबाने पर इसी जगह का सटीक स्थान दर्ज होगा';

  @override
  String get visitLocating => 'सटीक स्थान दर्ज हो रहा है…';

  @override
  String visitSavedWithGps(int meters) {
    return 'भेंट सेव हुई · स्थान दर्ज (±$meters मीटर)';
  }

  @override
  String visitSavedRoughGps(int meters) {
    return 'भेंट सेव हुई · स्थान दर्ज, पर सटीक नहीं (±$meters मीटर)';
  }

  @override
  String get visitSavedNoGps =>
      'भेंट सेव हुई · स्थान नहीं मिल पाया (रिकॉर्ड में दर्ज)';
}
