import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_db.g.dart';

// The phone's copy of the user's booths, plus an outbox of changes waiting to
// be sent. Rows created on the phone carry `pending = true` until the server
// has accepted them; a pull never overwrites a pending row.

@DataClassName('BoothRow')
class Booths extends Table {
  IntColumn get partNo => integer()();
  TextColumn get stationHi => text().nullable()();

  @override
  Set<Column> get primaryKey => {partNo};
}

@DataClassName('FamilyRow')
class Families extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  IntColumn get partNo => integer()();
  IntColumn get sectionNo => integer().nullable()();
  TextColumn get houseNo => text().nullable()();
  TextColumn get headNameHi => text().nullable()();
  IntColumn get priority => integer()();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();
  // A household added on this phone that has not reached the server yet.
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VoterRow')
class Voters extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text()();
  TextColumn get epic => text().nullable()();
  TextColumn get nameHi => text()();
  TextColumn get relationType => text().nullable()();
  TextColumn get relativeNameHi => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get sourceList => text()();
  TextColumn get asddReason => text().nullable()();
  TextColumn get matchConfidence => text().nullable()();
  // Position on the 2025 roll: people listed close together usually live
  // together, so the app suggests them as possibly the same house.
  IntColumn get oldPartNo => integer().nullable()();
  IntColumn get oldSerial => integer().nullable()();
  BoolColumn get alreadyOnRoll =>
      boolean().withDefault(const Constant(false))();
  // The workbook's category (VoterCategory) and, for possibly deleted
  // people, the closest April-2026 roll entry to check before visiting.
  TextColumn get category => text().nullable()();
  TextColumn get closest2026 => text().nullable()();
  // Voters added in the field: TURNED_18_THIS_YEAR or OTHER, with a note.
  TextColumn get newReason => text().nullable()();
  TextColumn get newReasonNote => text().nullable()();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VisitRow')
class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text()();
  BoolColumn get byMe => boolean()();
  DateTimeColumn get visitedAt => dateTime()();
  TextColumn get outcome => text()();
  TextColumn get revisitOn => text().nullable()(); // YYYY-MM-DD
  TextColumn get remarks => text().nullable()();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VisitVoterRow')
class VisitVoters extends Table {
  TextColumn get visitId => text()();
  TextColumn get voterId => text()();
  TextColumn get voterOutcome => text()();
  TextColumn get docsSeen =>
      text().withDefault(const Constant(''))(); // comma-separated codes

  @override
  Set<Column> get primaryKey => {visitId, voterId};
}

@DataClassName('FormRow')
class Forms extends Table {
  TextColumn get id => text()();
  TextColumn get voterId => text()();
  TextColumn get formType => text()();
  TextColumn get route => text().nullable()();
  TextColumn get referenceNo => text().nullable()();
  TextColumn get filedOn => text().nullable()(); // YYYY-MM-DD
  BoolColumn get byMe => boolean()();
  TextColumn get currentStatus => text()();
  DateTimeColumn get updatedAt => dateTime()();
  // The server has the applicant's face photo for this form.
  BoolColumn get hasPhoto => boolean().withDefault(const Constant(false))();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Face photos taken on this phone, kept until the server has them.
@DataClassName('FormPhotoRow')
class FormPhotos extends Table {
  TextColumn get formId => text()();
  BlobColumn get bytes => blob()(); // JPEG
  DateTimeColumn get takenAt => dateTime()();
  // Uploaded to storage; waiting for the form to record it.
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {formId};
}

@DataClassName('FormEventRow')
class FormEvents extends Table {
  TextColumn get id => text()();
  TextColumn get formId => text()();
  TextColumn get status => text()();
  DateTimeColumn get changedAt => dateTime()();
  BoolColumn get byMe => boolean().withDefault(const Constant(false))();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Changes waiting for the server, sent oldest first.
@DataClassName('OutboxRow')
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get entity =>
      text()(); // family | voter | visit | form | form_event | form_photo
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get state =>
      text().withDefault(const Constant('pending'))(); // pending | rejected
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorHi => text().nullable()();
}

@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Booths,
    Families,
    Voters,
    Visits,
    VisitVoters,
    Forms,
    FormEvents,
    FormPhotos,
    Outbox,
    Meta,
  ],
)
class LocalDb extends _$LocalDb {
  LocalDb(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(voters, voters.oldPartNo);
        await m.addColumn(voters, voters.oldSerial);
      }
      if (from < 3) {
        await m.addColumn(voters, voters.category);
        await m.addColumn(voters, voters.closest2026);
      }
      if (from < 4) {
        await m.addColumn(families, families.pending);
        await m.addColumn(voters, voters.newReason);
        await m.addColumn(voters, voters.newReasonNote);
        await m.addColumn(forms, forms.hasPhoto);
        await m.createTable(formPhotos);
      }
    },
  );

  /// Removes every row. Used on sign-out and when this phone loses access.
  Future<void> wipe() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}

/// Opens the on-phone database. On Android it is encrypted with [key]
/// (SQLite3MultipleCiphers); the web preview stores it unencrypted.
QueryExecutor openLocalDb({required String key}) {
  assert(RegExp(r'^[0-9a-f]{32,}$').hasMatch(key));
  return driftDatabase(
    name: 'dastak',
    native: DriftNativeOptions(
      setup: (db) {
        db.execute("PRAGMA key = '$key';");
        // Fails here, not later, if the key does not open the file.
        db.select('SELECT count(*) FROM sqlite_master;');
      },
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
