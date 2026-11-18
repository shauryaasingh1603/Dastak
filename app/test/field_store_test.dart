import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/local_db.dart';
import 'package:dastak/src/data/models.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_snapshot.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late LocalDb db;
  late FieldStore store;

  setUp(() async {
    db = LocalDb(NativeDatabase.memory());
    store = FieldStore(db);
    await store.applySnapshot(sampleSnapshot(), userId: 'me');
  });

  tearDown(() => db.close());

  test('a snapshot fills the local copy', () {
    final data = store.data;
    expect(data.booths.map((b) => b.partNo), [22, 39]);
    expect(data.booths.first.stationHi, 'प्राथमिक विद्यालय जफ़राबाद');
    expect(data.familiesInBooth(22).length, 3);
    expect(data.peopleInBooth(22).map((v) => v.id), [
      'v1',
      'v2',
      'v6',
      'v3',
      'v4',
    ]);
    expect(data.sameHouseCandidates('v1').map((v) => v.id), ['v2', 'v6', 'v3']);
    expect(data.votersOf('f1').length, 3);
    expect(data.statusOf('f1'), FamilyStatus.pending);
    expect(data.settings.visitsOpenFrom, '2026-11-17');
    expect(data.lastSyncAt, isNotNull);
  });

  test(
    'nobody home: one visit, waiting to be sent, family needs a revisit',
    () async {
      final revisit = Ist.addDays(Ist.today(), 2);
      final forms = await store.saveVisit(
        VisitDraft(
          familyId: 'f2',
          nobodyHome: true,
          revisitOn: revisit,
          gpsFlag: 'GPS_OFF',
        ),
      );
      final data = store.data;
      expect(forms, isEmpty);
      expect(data.visitsOf('f2').single.outcome, Outcome.notMet);
      expect(data.visitsOf('f2').single.pending, isTrue);
      expect(data.statusOf('f2'), FamilyStatus.revisit);
      final item = data.outbox.single;
      expect(item.entity, 'visit');
      expect(item.payload['outcome'], 'NOT_MET');
      expect(item.payload['revisit_on'], revisit);
      expect(item.payload['flags'], ['GPS_OFF']);
      expect(item.payload['voters'], isEmpty);
    },
  );

  test(
    'an eligible member starts a form; a second visit does not duplicate it',
    () async {
      final forms = await store.saveVisit(
        const VisitDraft(
          familyId: 'f1',
          nobodyHome: false,
          members: [
            MemberEntry(
              voterId: 'v1',
              outcome: Outcome.eligible,
              formType: '6',
              docs: ['AADHAAR'],
              mobile: '9876543210',
              mobileConsent: true,
            ),
            MemberEntry(voterId: 'v2', outcome: Outcome.shifted),
            MemberEntry(voterId: 'v3', outcome: Outcome.notMet),
          ],
        ),
      );
      var data = store.data;
      expect(forms.length, 1);
      expect(data.visitsOf('f1').single.outcome, Outcome.eligible);
      expect(data.statusOf('f1'), FamilyStatus.done);
      expect(data.formsOf('v1').single.status, FormStatus.filled);
      expect(data.eventsOf(forms.single).single.status, FormStatus.filled);
      expect(data.outbox.map((e) => e.entity), ['visit', 'form', 'form_event']);
      final members = data.outbox.first.payload['voters'] as List;
      expect(members.first, containsPair('mobile', '9876543210'));

      final again = await store.saveVisit(
        const VisitDraft(
          familyId: 'f1',
          nobodyHome: false,
          members: [
            MemberEntry(
              voterId: 'v1',
              outcome: Outcome.eligible,
              formType: '6',
            ),
          ],
        ),
      );
      data = store.data;
      expect(again, isEmpty);
      expect(data.formsOf('v1').length, 1);
    },
  );

  test('form edits are queued in order, latest last', () async {
    final formId = (await store.saveVisit(
      const VisitDraft(
        familyId: 'f1',
        nobodyHome: false,
        members: [
          MemberEntry(voterId: 'v1', outcome: Outcome.eligible, formType: '6'),
        ],
      ),
    )).single;
    await store.updateForm(
      formId,
      route: SubmitRoute.self,
      referenceNo: 'A1',
      filedOn: '2026-11-21',
    );
    await store.updateForm(
      formId,
      route: SubmitRoute.online,
      referenceNo: ' B2 ',
      filedOn: '2026-11-22',
    );
    await store.markSubmitted(formId);

    final data = store.data;
    expect(data.outbox.map((e) => e.entity), [
      'visit',
      'form',
      'form_event',
      'form',
      'form',
      'form_event',
    ]);
    expect(data.outbox[4].payload['route'], 'ONLINE');
    expect(data.outbox[4].payload['reference_no'], 'B2');
    expect(data.form(formId)!.status, FormStatus.submitted);
    expect(data.eventsOf(formId).map((e) => e.status), ['FILLED', 'SUBMITTED']);
  });

  test('an edit made while a send is in flight is not lost', () async {
    final formId = (await store.saveVisit(
      const VisitDraft(
        familyId: 'f1',
        nobodyHome: false,
        members: [
          MemberEntry(voterId: 'v1', outcome: Outcome.eligible, formType: '6'),
        ],
      ),
    )).single;
    final inFlight = await store
        .pendingBatch(); // visit, form (no route), FILLED
    await store.updateForm(
      formId,
      route: SubmitRoute.self,
      referenceNo: 'R9',
      filedOn: '2026-11-21',
    );
    await store.applyPushResults(inFlight, [
      for (final _ in inFlight) (ok: true, code: null, messageHi: null),
    ]);
    final left = store.data.outbox.single;
    expect(left.entity, 'form');
    expect(left.payload['route'], 'SELF');
    expect(
      store.data.form(formId)!.pending,
      isTrue,
      reason: 'still has a change to send',
    );
  });

  test(
    'accepted items leave the outbox; rejected ones stay with a reason',
    () async {
      final formId = (await store.saveVisit(
        const VisitDraft(
          familyId: 'f1',
          nobodyHome: false,
          members: [
            MemberEntry(
              voterId: 'v1',
              outcome: Outcome.eligible,
              formType: '8',
            ),
          ],
        ),
      )).single;
      final batch = await store.pendingBatch();
      await store.applyPushResults(batch, [
        (ok: true, code: null, messageHi: null),
        (ok: true, code: null, messageHi: null),
        (ok: false, code: 'INVALID', messageHi: 'जानकारी अधूरी या गलत है'),
      ]);
      final data = store.data;
      expect(data.visitsOf('f1').single.pending, isFalse);
      expect(data.form(formId)!.pending, isFalse);
      expect(data.pendingCount, 0);
      expect(data.rejectedCount, 1);
      expect(data.outbox.single.errorHi, 'जानकारी अधूरी या गलत है');

      await store.retryRejected(data.outbox.single.seq);
      expect(store.data.pendingCount, 1);
    },
  );

  test(
    'a new sync keeps unsent rows and adopts the server copy of sent ones',
    () async {
      await store.saveVisit(
        VisitDraft(familyId: 'f2', nobodyHome: true, revisitOn: Ist.today()),
      );
      final unsentId = store.data.visitsOf('f2').single.id;
      await store.addVoter(
        const NewVoterDraft(
          familyId: 'f1',
          nameHi: 'नेहा यादव',
          relationType: 'F',
          relativeNameHi: 'रामलाल यादव',
          age: 19,
          gender: 'F',
          formType: '6',
        ),
      );
      final newVoter = store.data.votersOf('f1').firstWhere((v) => v.isNew);

      // The server already has a visit to f3 by someone else, and nothing else.
      await store.applySnapshot(
        sampleSnapshot(
          visits: [
            {
              'id': 'x1',
              'family_id': 'f3',
              'by_me': false,
              'visited_at': '2026-11-18T05:00:00Z',
              'outcome': 'SHIFTED',
              'revisit_on': null,
              'remarks': null,
            },
          ],
        ),
        userId: 'me',
      );
      final data = store.data;
      expect(
        data.visitsOf('f2').single.id,
        unsentId,
        reason: 'unsent visit kept',
      );
      expect(
        data.votersOf('f1').any((v) => v.id == newVoter.id),
        isTrue,
        reason: 'unsent voter kept',
      );
      expect(data.formsOf(newVoter.id).length, 1);
      expect(data.visitsOf('f3').single.byMe, isFalse);
      expect(data.statusOf('f3'), FamilyStatus.done);
    },
  );

  test(
    'BLA-2 count adds submissions not yet sent to the server count',
    () async {
      await store.applySnapshot(
        sampleSnapshot(quota: {'today': 3, 'total': 12}),
        userId: 'me',
      );
      expect(store.bla2Count(), (today: 3, total: 12));
      final formId = (await store.saveVisit(
        const VisitDraft(
          familyId: 'f1',
          nobodyHome: false,
          members: [
            MemberEntry(
              voterId: 'v1',
              outcome: Outcome.eligible,
              formType: '6',
            ),
          ],
        ),
      )).single;
      await store.updateForm(
        formId,
        route: SubmitRoute.bla2,
        referenceNo: 'R-1',
        filedOn: Ist.today(),
      );
      await store.markSubmitted(formId);
      expect(store.bla2Count(), (today: 4, total: 13));
    },
  );

  test(
    'a different user on the same phone starts from an empty copy',
    () async {
      await store.saveVisit(
        VisitDraft(familyId: 'f2', nobodyHome: true, revisitOn: Ist.today()),
      );
      await store.claimFor('me');
      expect(store.data.families, isNotEmpty);
      await store.claimFor('someone-else');
      expect(store.data.families, isEmpty);
      expect(store.data.outbox, isEmpty);
    },
  );
}
