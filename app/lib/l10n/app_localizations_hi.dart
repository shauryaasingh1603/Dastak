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
  String get homeRemaining => 'बाकी लोग';

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
  String get syncAllSent => 'सारा डेटा सर्वर पर पहुँच गया';

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
  String get locDeniedWeb =>
      'स्थान की अनुमति नहीं मिली। “अनुमति दें” दबाएँ और ब्राउज़र के सवाल पर “Allow” (अनुमति दें) चुनें।';

  @override
  String get locBlockedWeb =>
      'इस वेबसाइट के लिए स्थान बंद (Block) है। ऊपर जहाँ वेबसाइट का पता लिखा है, उसके बाईं ओर के निशान को दबाएँ, फिर “Permissions” या “Site settings” में “Location” को “Allow” करें। उसके बाद “दोबारा जाँचें” दबाएँ।';

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
    return 'भेंट सेव हुई · स्थान दर्ज (लगभग $meters मीटर तक सटीक)';
  }

  @override
  String visitSavedRoughGps(int meters) {
    return 'भेंट सेव हुई · स्थान दर्ज, पर सटीक नहीं (लगभग $meters मीटर)';
  }

  @override
  String get visitSavedNoGps =>
      'भेंट सेव हुई · स्थान नहीं मिल पाया (रिकॉर्ड में दर्ज)';

  @override
  String homePeopleCount(int count) {
    return '$count लोग';
  }

  @override
  String boothPeopleProgress(int done, int total) {
    return '$done/$total लोग पूरे';
  }

  @override
  String listShowingPeople(int shown, int total) {
    return '$shown / $total लोग';
  }

  @override
  String get listEmptyPeople => 'इस बूथ में कोई व्यक्ति नहीं है';

  @override
  String get listNoMatchPeople => 'खोज से कोई व्यक्ति नहीं मिला';

  @override
  String get personTitle => 'व्यक्ति विवरण';

  @override
  String get personSameRecord => 'इसी घर में दर्ज लोग';

  @override
  String get visitSameHouse => 'इसी घर के और लोग?';

  @override
  String get visitSameHouseHint =>
      'सूची में पास-पास दर्ज, इसी मकान नंबर वाले लोग। घर वालों से पूछकर जो यहीं के हैं, उन्हें चुनें।';

  @override
  String get visitNoSuggestions =>
      'इसी मकान नंबर वाला और कोई सूची में पास में नहीं है';

  @override
  String get contactTitle => 'घर पर कौन मिला';

  @override
  String get contactName => 'नाम';

  @override
  String get contactRelation => 'सूची वाले व्यक्ति से संबंध';

  @override
  String get contactMobile => 'मोबाइल नंबर';

  @override
  String get contactRefused => 'नंबर देने से मना किया';

  @override
  String get errContactName => 'घर पर मिले व्यक्ति का नाम डालें';

  @override
  String get errContactRequired =>
      'घर पर मिले व्यक्ति का मोबाइल नंबर डालें या “नंबर देने से मना किया” चुनें';

  @override
  String get memberMobile => 'इस व्यक्ति का अपना मोबाइल नंबर (अगर दें)';

  @override
  String get relFather => 'पिता';

  @override
  String get relMother => 'माता';

  @override
  String get relHusband => 'पति';

  @override
  String get relWife => 'पत्नी';

  @override
  String get relSon => 'बेटा';

  @override
  String get relDaughter => 'बेटी';

  @override
  String get relSibling => 'भाई/बहन';

  @override
  String get relSelf => 'स्वयं';

  @override
  String get relOther => 'अन्य';

  @override
  String houseAndBooth(String house, int partNo) {
    return 'मकान नं. $house · बूथ $partNo';
  }

  @override
  String get homeAllSent => 'सब भेजा गया';

  @override
  String get catUntraceable => 'अनुपस्थित बताया गया';

  @override
  String get catShifted => 'स्थानांतरित बताया गया';

  @override
  String get catDeceased => 'मृत बताया गया';

  @override
  String get catDuplicate => 'दोहरा नाम';

  @override
  String get catAlreadyBack => 'सूची में वापस';

  @override
  String get catPossHigh => 'हटाया गया (पक्का)';

  @override
  String get catPossMedium => 'हटाया गया (शायद)';

  @override
  String get catPossLow => 'शायद सूची में है';

  @override
  String get catAdded => 'नया जोड़ा';

  @override
  String get catHintUntraceable =>
      'अनुपस्थित या पता न चलने के कारण नाम हटा। मिलें तो फ़ॉर्म 6 भरवाएँ।';

  @override
  String get catHintShifted =>
      'स्थायी रूप से स्थानांतरित बताकर नाम हटा। देखें कि अब भी यहीं रहते हैं या नहीं।';

  @override
  String get catHintDeceased =>
      'मृत बताकर नाम हटा। परिवार से पुष्टि करें; जीवित हों तो फ़ॉर्म 6 भरवाएँ।';

  @override
  String get catHintDuplicate =>
      'दोहरी प्रविष्टि बताकर नाम हटा। पता करें कि कहीं और नाम दर्ज है या नहीं।';

  @override
  String get catHintAlreadyBack =>
      'अप्रैल 2026 की सूची में नाम वापस आ गया है। भेंट ज़रूरी नहीं।';

  @override
  String get catHintPossHigh =>
      'ड्राफ्ट सूची (17 नवंबर) में कोई मिलता-जुलता नाम नहीं मिला। नाम हटने की सबसे ज़्यादा संभावना।';

  @override
  String get catHintPossMedium =>
      'ड्राफ्ट सूची में सिर्फ़ कमज़ोर मिलान मिला। नाम हटा हो सकता है।';

  @override
  String get catHintPossLow =>
      'ड्राफ्ट सूची में मिलता-जुलता नाम है, शायद नाम अभी भी दर्ज है। भेंट से पहले नीचे की प्रविष्टि जाँचें।';

  @override
  String get catHintAdded => 'मैदान में जोड़ा गया नया मतदाता।';

  @override
  String get catFilterAll => 'सभी श्रेणियाँ';

  @override
  String get categoryTitle => 'श्रेणी';

  @override
  String closestEntry(String entry) {
    return 'सूची में मिलती-जुलती प्रविष्टि (पहले जाँचें): $entry';
  }

  @override
  String get searchTitle => 'लोग खोजें';

  @override
  String get searchHint => 'नाम, पिता/पति का नाम, EPIC या मकान नंबर';

  @override
  String get searchStart =>
      'नाम हिंदी या अंग्रेज़ी में लिखें, जैसे “ramesh” या “रमेश”। आपके सभी बूथों में खोजा जाएगा।';

  @override
  String get searchNoResult =>
      'कोई नहीं मिला। नाम का कुछ हिस्सा या पिता/पति का नाम लिखकर देखें।';

  @override
  String searchResults(int count) {
    return '$count लोग मिले';
  }

  @override
  String searchMore(int shown) {
    return 'पहले $shown दिखाए गए। और लिखें ताकि खोज छोटी हो।';
  }

  @override
  String get searchOpen => 'लोग खोजें: नाम, EPIC या मकान नंबर';

  @override
  String get visitAddBySearch => 'परिवार के और सदस्य खोजकर जोड़ें';

  @override
  String get visitAddBySearchHint =>
      'दरवाज़े पर पूछें कि घर में और कौन-कौन है, फिर उनके नाम खोजकर जोड़ें। सब एक ही परिवार में गिने जाएँगे।';

  @override
  String get visitPickTitle => 'इस घर का सदस्य चुनें';

  @override
  String get visitAlreadyAdded => 'पहले से जोड़ा गया';

  @override
  String get personHousehold => 'भेंट में इसी घर के बताए गए लोग';

  @override
  String get photoTitle => 'चेहरे की फ़ोटो';

  @override
  String get photoHint =>
      'फ़ॉर्म के लिए। व्यक्ति से पूछकर लें: चेहरा सामने से, अच्छी रोशनी में, सादी दीवार के आगे।';

  @override
  String get photoTake => 'फ़ोटो लें';

  @override
  String get photoRetake => 'दोबारा लें';

  @override
  String get photoRemove => 'हटाएँ';

  @override
  String get photoOnServer => 'फ़ोटो भेजी जा चुकी है';

  @override
  String get photoWaiting => 'फ़ोटो फ़ोन पर है, नेटवर्क मिलते ही भेजी जाएगी';

  @override
  String get photoMissing => 'फ़ोटो नहीं ली गई';

  @override
  String get photoFailed => 'कैमरा नहीं खुला। दोबारा कोशिश करें।';

  @override
  String get photoSaved => 'फ़ोटो सेव हुई';

  @override
  String get newVoterReason => 'क्यों जोड़ रहे हैं?';

  @override
  String get newReasonTurned18 => 'इस साल 18 के हुए';

  @override
  String get newReasonOther => 'अन्य';

  @override
  String get newReasonNote =>
      'कारण लिखें (जैसे: कभी नाम नहीं जुड़ा, बाहर से आकर बसे)';

  @override
  String get errNewReason => 'बताएँ कि क्यों जोड़ रहे हैं';

  @override
  String get errTurned18Age => 'इस साल 18 के हुए: उम्र 17 या 18 होनी चाहिए';

  @override
  String get newVoterBooth => 'बूथ';

  @override
  String get newVoterHouse => 'मकान नंबर';

  @override
  String get newVoterHouseHint =>
      'इस घर में सूची का कोई व्यक्ति नहीं है, इसलिए नया घर दर्ज होगा।';

  @override
  String get errNewVoterHouse => 'मकान नंबर लिखें';

  @override
  String get newVoterOpen => 'नया मतदाता जोड़ें';

  @override
  String get newVoterOpenHint =>
      'जिनका नाम सूची में नहीं है, जैसे जो इस साल 18 के हुए';

  @override
  String get catOnDraftRoll => 'ड्राफ्ट सूची में नाम है';

  @override
  String get catHintOnDraftRoll =>
      '17 नवंबर की ड्राफ्ट सूची में नाम मिल गया है, भेंट ज़रूरी नहीं। नीचे लिखी प्रविष्टि से मिलान कर लें।';

  @override
  String draftPartLine(int part) {
    return '2027 ड्राफ्ट सूची: भाग $part';
  }

  @override
  String draftPartSectionLine(int part, String section) {
    return '2027 ड्राफ्ट सूची: भाग $part, सेक्शन $section';
  }
}
