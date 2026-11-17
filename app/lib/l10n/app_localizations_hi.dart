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
  String get listSearchHint => 'नाम या मकान नं. खोजें';

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
}
