import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/search.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('soundKey', () {
    test('Hindi and English spellings share an outline', () {
      expect(soundKey('रमेश'), soundKey('ramesh'));
      expect(soundKey('श्याम'), soundKey('Shyam'));
      expect(soundKey('संजय'), soundKey('sanjay'));
      expect(soundKey('सीता'), soundKey('sita'));
      expect(soundKey('अब्बास'), soundKey('abbas'));
      expect(soundKey('ज़फ़राबाद'), soundKey('zafrabad'));
      expect(soundKey('ज़फ़राबाद'), soundKey('jafrabad'));
    });

    test('vowel spelling differences do not matter', () {
      expect(soundKey('सिता'), soundKey('सीता'));
      expect(soundKey('मोहन'), soundKey('mohan'));
    });
  });

  group('PersonQuery', () {
    late Harness h;
    late FieldData data;
    setUpAll(() async {
      h = await Harness.create();
      data = h.store.data;
    });
    tearDownAll(() => h.dispose());

    List<String> find(String q) => [
      for (final v in data.voters)
        if (PersonQuery(q).matches(data, v)) v.id,
    ];

    test('English letters find Hindi names', () {
      expect(find('ramlal'), containsAll(['v1', 'v2', 'v3']));
      expect(find('sita'), ['v2']);
      expect(find('salim'), ['v4']);
    });

    test('Hindi, EPIC and house number still work', () {
      expect(find('सीता'), ['v2']);
      expect(find('mock0000004'), ['v4']);
      expect(find('7'), ['v5']);
    });

    test('one letter is too little to search by', () {
      expect(find('r'), isEmpty);
    });
  });
}
