/// Finding people by what a volunteer types: a name or a relative's name in
/// Hindi or in English letters ("ramesh" finds "रमेश"), an EPIC number, or a
/// house number.
library;

import 'data/models.dart';
import 'text.dart';

const _consonants = {
  'क': 'k', 'ख': 'k', 'ग': 'g', 'घ': 'g', 'ङ': 'n', //
  'च': 'c', 'छ': 'c', 'ज': 'j', 'झ': 'j', 'ञ': 'n', //
  'ट': 't', 'ठ': 't', 'ड': 'd', 'ढ': 'd', 'ण': 'n', //
  'त': 't', 'थ': 't', 'द': 'd', 'ध': 'd', 'न': 'n', //
  'प': 'p', 'फ': 'p', 'ब': 'b', 'भ': 'b', 'म': 'm', //
  'य': 'y', 'र': 'r', 'ल': 'l', 'व': 'v', 'श': 's', //
  'ष': 's', 'स': 's', 'ह': 'h', //
  'ं': 'n', // anusvara: संजय → snjy, like "sanjay"
  'ँ': 'n',
  // Letters with a nukta, when stored as one character.
  '\u0958': 'k', '\u0959': 'k', '\u095A': 'g', '\u095B': 'j', //
  '\u095C': 'r', '\u095D': 'r', '\u095E': 'p', '\u095F': 'y',
};

// Letters after a nukta that sound different: ड़ and ढ़ are usually typed "r".
const _nuktaSounds = {'ड': 'r', 'ढ': 'r'};

const _latinPairs = {
  'chh': 'c', 'kh': 'k', 'gh': 'g', 'ch': 'c', 'jh': 'j', 'th': 't', //
  'dh': 'd', 'ph': 'p', 'bh': 'b', 'sh': 's',
};

const _latinSingles = {
  'b': 'b', 'c': 'c', 'd': 'd', 'f': 'p', 'g': 'g', 'h': 'h', 'j': 'j', //
  'k': 'k', 'l': 'l', 'm': 'm', 'n': 'n', 'p': 'p', 'q': 'k', 'r': 'r', //
  's': 's', 't': 't', 'v': 'v', 'w': 'v', 'x': 'ks', 'y': 'y', 'z': 'j',
};

/// The consonant outline of a word in either script, vowels dropped and
/// doubled letters folded: "Shyam" and "श्याम" both become "sym".
String soundKey(String word) {
  final out = StringBuffer();
  final lower = word.toLowerCase();
  var i = 0;
  while (i < lower.length) {
    final char = lower[i];
    final next = i + 1 < lower.length ? lower[i + 1] : '';
    String? sound;
    var step = 1;
    if (_consonants.containsKey(char)) {
      sound = next == '़'
          ? (_nuktaSounds[char] ?? _consonants[char])
          : _consonants[char];
    } else {
      for (final pair in _latinPairs.entries) {
        if (lower.startsWith(pair.key, i)) {
          sound = pair.value;
          step = pair.key.length;
          break;
        }
      }
      sound ??= _latinSingles[char];
    }
    if (sound != null) {
      final current = out.toString();
      if (!current.endsWith(sound)) out.write(sound);
    }
    i += step;
  }
  return out.toString();
}

final _latin = RegExp(r'[a-z]', caseSensitive: false);
final _digit = RegExp(r'\d');

/// One search, prepared once and tested against many people.
class PersonQuery {
  PersonQuery(String raw)
    : _text = normalizeForSearch(raw),
      _compact = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ''),
      _words = [
        for (final w in raw.trim().split(RegExp(r'\s+')))
          if (w.isNotEmpty) w,
      ];

  final String _text;
  final String _compact;
  final List<String> _words;

  bool get isEmpty => _text.isEmpty;

  bool matches(FieldData data, Voter voter) {
    if (isEmpty) return true;
    final house = (data.family(voter.familyId)?.houseNo ?? '').toLowerCase();
    if (house.isNotEmpty && house == _text) return true;
    final epic = (voter.epic ?? '').toLowerCase().replaceAll(' ', '');
    if (_digit.hasMatch(_compact) &&
        epic.isNotEmpty &&
        epic.contains(_compact)) {
      return true;
    }
    final name = normalizeForSearch(voter.nameHi);
    final relative = normalizeForSearch(voter.relativeNameHi ?? '');
    if (name.contains(_text) || relative.contains(_text)) return true;
    return _soundsLike('${voter.nameHi} ${voter.relativeNameHi ?? ''}');
  }

  /// Every typed word sounds like part of the name or the relative's name.
  bool _soundsLike(String names) {
    final keys = [
      for (final w in names.split(RegExp(r'\s+')))
        if (w.isNotEmpty) soundKey(w),
    ];
    var matched = 0;
    for (final word in _words) {
      if (_digit.hasMatch(word)) return false;
      final key = soundKey(word);
      // One-letter outlines ("a", "ram" typed as "r") match too much.
      if (key.length < 2 && _latin.hasMatch(word)) return false;
      if (key.isEmpty) continue;
      if (!keys.any(
        (k) => k.startsWith(key) || (key.length >= 3 && k.contains(key)),
      )) {
        return false;
      }
      matched++;
    }
    return matched > 0;
  }
}
