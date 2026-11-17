/// Text helpers for Hindi search and house-number ordering.
library;

const _nuktaLetters = {
  'क़': 'क', // क़ → क
  'ख़': 'ख', // ख़ → ख
  'ग़': 'ग', // ग़ → ग
  'ज़': 'ज', // ज़ → ज
  'ड़': 'ड', // ड़ → ड
  'ढ़': 'ढ', // ढ़ → ढ
  'फ़': 'फ', // फ़ → फ
  'य़': 'य', // य़ → य
};

/// Folds the spelling variants people type differently, so a search for
/// "जफराबाद" finds "ज़फ़राबाद": nukta forms become the plain letter and
/// chandrabindu becomes anusvara. Latin text (EPIC numbers) is lower-cased.
String normalizeForSearch(String input) {
  final out = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    if (char == '़') continue; // combining nukta
    if (char == 'ँ') {
      out.write('ं'); // chandrabindu → anusvara
      continue;
    }
    out.write(_nuktaLetters[char] ?? char);
  }
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Orders house numbers the way a volunteer walks a lane: 2 before 10, and
/// 13 before 13क. Missing numbers go last.
int compareHouseNo(String? a, String? b) {
  if (a == null || a.isEmpty) return (b == null || b.isEmpty) ? 0 : 1;
  if (b == null || b.isEmpty) return -1;
  final na = _leadingNumber(a);
  final nb = _leadingNumber(b);
  if (na != null && nb != null && na != nb) return na.compareTo(nb);
  if (na != null && nb == null) return -1;
  if (na == null && nb != null) return 1;
  return a.compareTo(b);
}

int? _leadingNumber(String value) {
  final match = RegExp(r'^\s*(\d+)').firstMatch(value);
  return match == null ? null : int.parse(match.group(1)!);
}
