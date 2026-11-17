import 'package:dastak/src/text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeForSearch', () {
    test('treats nukta and plain letters as the same', () {
      expect(normalizeForSearch('ज़फ़राबाद'), normalizeForSearch('जफराबाद'));
      // Precomposed nukta letter (U+095B) and base + combining nukta.
      expect(normalizeForSearch('ज़'), normalizeForSearch('ज़'));
      expect(normalizeForSearch('सिद्दीक़ी'), 'सिद्दीकी');
    });

    test('treats chandrabindu and anusvara as the same', () {
      expect(normalizeForSearch('माँ'), normalizeForSearch('मां'));
    });

    test('lower-cases Latin text and tidies spaces', () {
      expect(normalizeForSearch('  AGS 1234 '), 'ags 1234');
    });
  });

  group('compareHouseNo', () {
    List<String?> sorted(List<String?> values) =>
        [...values]..sort(compareHouseNo);

    test('orders numbers numerically, suffixes after the plain number', () {
      expect(sorted(['10', '2', '13क', '13', '1']), [
        '1',
        '2',
        '10',
        '13',
        '13क',
      ]);
    });

    test('puts missing house numbers last', () {
      expect(sorted([null, '5', '', '3']), ['3', '5', null, '']);
    });
  });
}
