import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/local_db.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/data/sync_service.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_snapshot.dart';

class FakeApi implements SyncApi {
  final pushed = <List<Map<String, dynamic>>>[];
  int pulls = 0;
  Object? failWith;
  String? rejectEntity;
  final uploads = <String, Uint8List>{};

  /// What the next pull returns; the sample data by default.
  Map<String, dynamic> Function() snapshot = sampleSnapshot;

  @override
  Future<bool> uploadPhoto(String formId, Uint8List jpeg) async {
    if (failWith != null) throw failWith!;
    uploads[formId] = jpeg;
    return true;
  }

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
    return snapshot();
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
    expect(store.data.families.length, 4);
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

  test('a face photo goes up after its form, then leaves the phone', () async {
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);
    // Once uploaded and recorded, the server lists the form with its photo.
    api.snapshot = () => sampleSnapshot(
      forms: [
        for (final id in api.uploads.keys)
          {
            'id': id,
            'voter_id': 'v1',
            'form_type': '6',
            'route': null,
            'reference_no': null,
            'filed_on': null,
            'by_me': true,
            'current_status': 'FILLED',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'has_photo': true,
          },
      ],
    );
    sync.start('me');
    await settle();

    final formId = (await store.saveVisit(
      VisitDraft(
        familyId: 'f1',
        nobodyHome: false,
        members: [
          MemberEntry(
            voterId: 'v1',
            outcome: Outcome.eligible,
            formType: '6',
            photo: jpeg,
          ),
        ],
      ),
    )).single;
    expect(store.data.localPhotos, {formId});
    await settle();

    expect(api.uploads[formId], jpeg);
    final photoItem = api.pushed
        .expand((batch) => batch)
        .singleWhere((i) => i['entity'] == 'form_photo');
    expect(photoItem['data'], {'form_id': formId});
    expect(photoItem['uuid'], isNot(formId));
    expect(store.data.form(formId)!.hasPhoto, isTrue);
    expect(store.data.localPhotos, isEmpty, reason: 'the server has it now');
    expect(store.data.outbox, isEmpty);
  });

  test('offline, the photo stays on the phone', () async {
    sync.start('me');
    await settle();
    api.failWith = const SyncNetworkException();
    final formId = (await store.saveVisit(
      VisitDraft(
        familyId: 'f1',
        nobodyHome: false,
        members: [
          MemberEntry(
            voterId: 'v1',
            outcome: Outcome.eligible,
            formType: '6',
            photo: Uint8List.fromList([1, 2, 3]),
          ),
        ],
      ),
    )).single;
    await settle();
    expect(sync.problem, SyncProblem.offline);
    expect(api.uploads, isEmpty);
    expect(await store.photoOf(formId), [1, 2, 3]);
  });
}
