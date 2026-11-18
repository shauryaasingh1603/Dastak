import '../data/models.dart';

const _months = [
  'जनवरी',
  'फ़रवरी',
  'मार्च',
  'अप्रैल',
  'मई',
  'जून',
  'जुलाई',
  'अगस्त',
  'सितंबर',
  'अक्तूबर',
  'नवंबर',
  'दिसंबर',
];

/// "17 नवंबर 2026" from YYYY-MM-DD. Western digits, as the spec asks.
String formatDay(String day) {
  final d = DateTime.parse(day);
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// "17 नवंबर, 10:42" in IST.
String formatMoment(DateTime at) {
  final ist = at.toUtc().add(const Duration(hours: 5, minutes: 30));
  final hh = ist.hour.toString().padLeft(2, '0');
  final mm = ist.minute.toString().padLeft(2, '0');
  return '${ist.day} ${_months[ist.month - 1]}, $hh:$mm';
}

/// Whole days from today (IST) until [at]'s IST date; negative once past.
int daysUntil(DateTime at) {
  final today = DateTime.parse(Ist.today());
  final target = DateTime.parse(Ist.day(at));
  return target.difference(today).inDays;
}

/// Converts a picked calendar date to YYYY-MM-DD.
String dayOf(DateTime picked) =>
    '${picked.year.toString().padLeft(4, '0')}-'
    '${picked.month.toString().padLeft(2, '0')}-'
    '${picked.day.toString().padLeft(2, '0')}';
