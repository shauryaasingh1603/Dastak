// Runs the app's own store and sync code against the real backend: records
// visits and forms offline, syncs, and checks what the server accepted and
// refused. Not part of the normal test run. Needs a signed-in test
// volunteer's access token:
//
//   DASTAK_FIELD_TOKEN=<jwt> flutter test test_live/sync_live_test.dart
//
// It writes real rows for that volunteer, so use a test account and mock data.
import 'dart:io';

import 'package:dastak/config.dart';
import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/local_db.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/data/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';

class _EnvProxy extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..findProxy = HttpClient.findProxyFromEnvironment;
}

void main() {
  final token = Platform.environment['DASTAK_FIELD_TOKEN'];

  test(
    'offline work reaches the server; the server enforces the rules',
    () async {
      HttpOverrides.global = _EnvProxy();
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        accessToken: () async => token,
      );
      final db = LocalDb(NativeDatabase.memory());
      addTearDown(db.close);
      final store = FieldStore(db);
      var lost = false;
      final sync = SyncService(
        api: SupabaseSyncApi(client),
        store: store,
        onAccessLost: () async => lost = true,
        interval: const Duration(hours: 1),
      );
      addTearDown(sync.dispose);
      var started = false;
      Future<void> syncNow() async {
        if (!started) {
          started = true;
          sync.start('test');
        } else {
          await sync.syncNow();
        }
        while (sync.running) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }

      // 1. First sync downloads the booths.
      await syncNow();
      expect(lost, isFalse);
      expect(sync.problem, SyncProblem.none);
      var data = store.data;
      stdout.writeln(
        'pulled: booths ${data.booths.map((b) => b.partNo).toList()}, '
        'families ${data.families.length}, voters ${data.voters.length}',
      );
      expect(data.booths, isNotEmpty);

      // Families nobody has visited yet, with at least two members.
      final fresh = [
        for (final f in data.families)
          if (data.visitsOf(f.id).isEmpty && data.votersOf(f.id).length >= 2) f,
      ];
      final a = fresh[0];
      final b = fresh[1];
      final aVoters = data.votersOf(a.id);
      final stamp = DateTime.now().millisecondsSinceEpoch;

      // 2. A visit with an eligible member: Form 6, submitted by self (R1 met).
      final formA = (await store.saveVisit(
        VisitDraft(
          familyId: a.id,
          nobodyHome: false,
          metPerson: aVoters.first.nameHi,
          members: [
            MemberEntry(
              voterId: aVoters[0].id,
              outcome: Outcome.eligible,
              formType: '6',
              docs: const ['AADHAAR', 'RATION'],
              mobile: '9876500000',
              mobileConsent: true,
            ),
            for (final v in aVoters.skip(1))
              MemberEntry(voterId: v.id, outcome: Outcome.notMet),
          ],
          remarks: 'live sync test',
          gpsLat: 25.76,
          gpsLng: 82.84,
          gpsAccuracy: 12,
        ),
      )).single;
      await store.updateForm(
        formA,
        route: SubmitRoute.self,
        referenceNo: 'TEST-$stamp',
        filedOn: Ist.today(),
      );
      await store.markSubmitted(formA);

      // 3. Nobody home at the second family.
      await store.saveVisit(
        VisitDraft(
          familyId: b.id,
          nobodyHome: true,
          revisitOn: Ist.addDays(Ist.today(), 1),
          gpsFlag: 'GPS_OFF',
        ),
      );

      // 4. A new voter with Form 6, sent through the BLA-2 route by a
      //    volunteer: the server must refuse the submission (BLA2_ONLY).
      final formNew = await store.addVoter(
        NewVoterDraft(
          familyId: b.id,
          nameHi: 'परीक्षण नया मतदाता',
          relationType: 'F',
          relativeNameHi: 'परीक्षण पिता',
          age: 19,
          gender: 'F',
          formType: '6',
          mobile: '9876511111',
          mobileConsent: true,
        ),
      );
      await store.updateForm(
        formNew!,
        route: SubmitRoute.bla2,
        referenceNo: 'TEST-B-$stamp',
        filedOn: Ist.today(),
      );
      await store.markSubmitted(formNew);

      expect(store.data.outbox.length, greaterThan(5));
      await syncNow();

      data = store.data;
      stdout.writeln('after sync, still in outbox:');
      for (final e in data.outbox) {
        stdout.writeln('  ${e.entity}: ${e.errorCode} – ${e.errorHi}');
      }
      expect(
        {for (final e in data.outbox) e.entity: e.errorCode},
        {'form_event': 'BLA2_ONLY'},
      );

      // What came back from the server.
      expect(data.visitsOf(a.id).single.byMe, isTrue);
      expect(data.visitsOf(a.id).single.pending, isFalse);
      expect(data.form(formA)!.status, FormStatus.submitted);
      expect(data.form(formA)!.pending, isFalse);
      expect(data.form(formA)!.referenceNo, 'TEST-$stamp');
      expect(data.visitsOf(b.id).single.outcome, Outcome.notMet);
      expect(
        data.votersOf(b.id).where((v) => v.isNew && !v.pending),
        hasLength(1),
      );

      // 5. The same receipt number on another form is refused (R6).
      final formDup = (await store.saveVisit(
        VisitDraft(
          familyId: a.id,
          nobodyHome: false,
          members: [
            MemberEntry(
              voterId: aVoters[1].id,
              outcome: Outcome.movedIn,
              formType: '8',
            ),
          ],
        ),
      )).single;
      await store.updateForm(
        formDup,
        route: SubmitRoute.online,
        referenceNo: 'TEST-$stamp',
        filedOn: Ist.today(),
      );
      await syncNow();
      final dup = store.data.outbox.where((e) => e.uuid == formDup).single;
      stdout.writeln('duplicate receipt: ${dup.errorCode} – ${dup.errorHi}');
      expect(dup.errorCode, 'DUPLICATE_REFERENCE');

      stdout.writeln('family A ${a.code}, family B ${b.code}, stamp $stamp');
    },
    skip: token == null ? 'set DASTAK_FIELD_TOKEN' : null,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
