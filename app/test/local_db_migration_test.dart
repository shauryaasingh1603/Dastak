import 'dart:io';

import 'package:dastak/src/data/local_db.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'version 5 phones keep their face photos and gain ECI screenshots',
    () async {
      final dir = await Directory.systemTemp.createTemp('dastak_db');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/dastak.sqlite');

      // A phone on version 5: face photos keyed by form only, no ECI columns.
      var db = LocalDb(NativeDatabase(file));
      await db.customSelect('SELECT 1').get(); // creates the current schema
      await db.customStatement('DROP TABLE form_photos');
      await db.customStatement(
        'CREATE TABLE form_photos (form_id TEXT NOT NULL, bytes BLOB NOT NULL, '
        'taken_at INTEGER NOT NULL, uploaded INTEGER NOT NULL DEFAULT 0 '
        'CHECK (uploaded IN (0, 1)), PRIMARY KEY (form_id))',
      );
      for (final column in ['has_eci', 'eci_status', 'eci_reference_no']) {
        await db.customStatement('ALTER TABLE forms DROP COLUMN $column');
      }
      await db.customStatement(
        "INSERT INTO form_photos VALUES ('f1', x'FFD8FFD9', 1700000000, 1)",
      );
      await db.customStatement('PRAGMA user_version = 5');
      await db.close();

      db = LocalDb(NativeDatabase(file));
      addTearDown(db.close);
      final photos = await db.select(db.formPhotos).get();
      expect(photos.single.formId, 'f1');
      expect(photos.single.kind, 'face');
      expect(photos.single.uploaded, isTrue);
      expect(photos.single.bytes, [0xFF, 0xD8, 0xFF, 0xD9]);

      // Both kinds can now be kept for one form.
      await db
          .into(db.formPhotos)
          .insert(
            FormPhotosCompanion.insert(
              formId: 'f1',
              kind: const Value('eci'),
              bytes: Uint8List.fromList([1]),
              takenAt: DateTime.now(),
            ),
          );
      expect(await db.select(db.formPhotos).get(), hasLength(2));
      await db
          .customSelect(
            'SELECT has_eci, eci_status, eci_reference_no FROM forms',
          )
          .get();
    },
  );
}
