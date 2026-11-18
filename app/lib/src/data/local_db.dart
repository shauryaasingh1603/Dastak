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
  BoolColumn get alreadyOnRoll =>
      boolean().withDefault(const Constant(false))();
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
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
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
  TextColumn get entity => text()(); // voter | visit | form | form_event
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
    Outbox,
    Meta,
  ],
)
class LocalDb extends _$LocalDb {
  LocalDb(super.executor);

  @override
  int get schemaVersion => 1;

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
