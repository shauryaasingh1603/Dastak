import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/local_db.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/data/sync_service.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_snapshot.dart';

class FakeApi implements SyncApi {
  final pushed = <List<Map<String, dynamic>>>[];
  int pulls = 0;
  Object? failWith;
  String? rejectEntity;

  @override
  Future<List<({bool ok, String? code, String? messageHi})>> push(
    List<Map<String, dynamic>> items,
    DateTime deviceNow,
  ) async {
    if (failWith != null) throw failWith!;
    pushed.add(items);
    return [
      for (final item in items)
        item['entity'] == rejectEntity
            ? (
                ok: false,
                code: 'RECEIPT_REQUIRED',
                messageHi: 'रसीद / संदर्भ संख्या ज़रूरी है',
              )
            : (ok: true, code: null, messageHi: null),
    ];
  }

  @override
  Future<Map<String, dynamic>> pull() async {
    if (failWith != null) throw failWith!;
    pulls++;
    return sampleSnapshot();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late LocalDb db;
  late FieldStore store;
  late FakeApi api;
  late SyncService sync;
  var accessLost = 0;

  setUp(() {
    db = LocalDb(NativeDatabase.memory());
    store = FieldStore(db);
    api = FakeApi();
    accessLost = 0;
    sync = SyncService(
      api: api,
      store: store,
      onAccessLost: () async => accessLost++,
      interval: const Duration(hours: 1),
    );
  });

  tearDown(() async {
    sync.dispose();
    await db.close();
  });

  Future<void> settle() async {
    for (var i = 0; i < 50 && sync.running; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('starting downloads the booths', () async {
    sync.start('me');
    await settle();
    expect(api.pulls, 1);
    expect(store.data.families.length, 3);
    expect(sync.problem, SyncProblem.none);
  });

  test('a local change is sent at once, then the copy is refreshed', () async {
    sync.start('me');
    await settle();
    await store.saveVisit(
      VisitDraft(familyId: 'f2', nobodyHome: true, revisitOn: Ist.today()),
    );
    await settle();
    expect(api.pushed.single.single['entity'], 'visit');
    expect(store.data.outbox, isEmpty);
    expect(api.pulls, 2);
  });

  test('a rejected item stays in the outbox with its Hindi reason', () async {
    api.rejectEntity = 'form_event';
    sync.start('me');
    await settle();
    await store.saveVisit(
      const VisitDraft(
        familyId: 'f1',
        nobodyHome: false,
        members: [
          MemberEntry(voterId: 'v1', outcome: Outcome.eligible, formType: '6'),
        ],
      ),
    );
    await settle();
    expect(store.data.rejectedCount, 1);
    expect(store.data.outbox.single.errorHi, 'रसीद / संदर्भ संख्या ज़रूरी है');
    expect(store.data.outbox.single.entity, 'form_event');
    expect(api.pushed.single.map((i) => i['entity']), [
      'visit',
      'form',
      'form_event',
    ]);
  });

  test(
    'no network: work stays on the phone and the problem is reported',
    () async {
      api.failWith = const SyncNetworkException();
      sync.start('me');
      await settle();
      await store.saveVisit(
        VisitDraft(familyId: 'f2', nobodyHome: true, revisitOn: Ist.today()),
      );
      await settle();
      expect(sync.problem, SyncProblem.offline);
      expect(store.data.pendingCount, 1);
    },
  );

  test('the server refusing the phone hands over to sign-out', () async {
    api.failWith = const SyncAccessException();
    sync.start('me');
    await settle();
    expect(accessLost, 1);
  });
}
