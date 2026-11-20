import 'package:dastak/src/auth/models.dart';
import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/ui/booth_list_screen.dart';
import 'package:dastak/src/ui/form_detail_screen.dart';
import 'package:dastak/src/location.dart';
import 'package:dastak/src/ui/home_screen.dart';
import 'package:dastak/src/ui/location_gate.dart';
import 'package:dastak/src/ui/main_shell.dart';
import 'package:dastak/src/ui/new_voter_screen.dart';
import 'package:dastak/src/ui/person_screen.dart';
import 'package:dastak/src/ui/sync_screen.dart';
import 'package:dastak/src/ui/visit_form_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

void main() {
  late Harness h;

  Future<void> setUpHarness(
    WidgetTester tester, {
    String role = 'volunteer',
  }) async {
    await tester.runAsync(() async => h = await Harness.create(role: role));
    tester.view.physicalSize = const Size(1080, 9000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settle(tester);
  }

  Future<void> save(WidgetTester tester) =>
      tapAndSettle(tester, find.text('सेव करें'));

  /// Fills the household contact with a refusal to give a number.
  Future<void> contactRefused(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'नाम'), 'कमला देवी');
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'माता'));
    await tapAndSettle(
      tester,
      find.widgetWithText(CheckboxListTile, 'नंबर देने से मना किया'),
    );
  }

  tearDown(() => h.dispose());

  testWidgets('home counts people, booth by booth', (tester) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(HomeScreen(onOpenList: () {})));
    await tester.pumpAndSettle();
    expect(find.text('बूथ 22'), findsOneWidget);
    expect(find.text('बूथ 39'), findsOneWidget);
    expect(find.text('0/5 लोग पूरे'), findsOneWidget);
    expect(find.text('45 लोग'), findsOneWidget);
  });

  testWidgets('a booth tab lists its people in roll order, with filters', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const BoothListScreen(initialIndex: 1)));
    await tester.pumpAndSettle();
    expect(find.text('मोहन पाल'), findsOneWidget);
    expect(find.text('रामलाल यादव'), findsNothing);

    await tapAndSettle(tester, find.text('बूथ 22'));
    expect(find.text('5 / 5 लोग'), findsOneWidget);
    final order = [
      for (final name in ['रामलाल यादव', 'सीता यादव', 'पूजा यादव', 'अजय यादव'])
        tester.getTopLeft(find.text(name)).dy,
    ];
    expect(order, [...order]..sort(), reason: 'roll order');

    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'पूरा'));
    expect(find.text('0 / 5 लोग'), findsOneWidget);
  });

  testWidgets('person card shows details and others on the same record', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const PersonScreen(voterId: 'v1')));
    await tester.pumpAndSettle();
    expect(find.text('रामलाल यादव'), findsOneWidget);
    expect(find.text('मकान नं. 12 · बूथ 22'), findsOneWidget);
    expect(find.text('सीता यादव'), findsOneWidget);
    expect(find.text('भेंट दर्ज करें'), findsOneWidget);
    expect(find.text('अभी कोई भेंट नहीं'), findsOneWidget);
  });

  testWidgets(
    'nobody home: revisit date needed (R3); covers the people ticked',
    (tester) async {
      await setUpHarness(tester);
      await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byType(Switch));
      await save(tester);
      expect(find.text('दोबारा जाने की तारीख़ चुनें'), findsOneWidget);
      expect(h.store.data.outbox, isEmpty);
    },
  );

  testWidgets(
    'someone met: contact needed, then an outcome per person, then the form',
    (tester) async {
      await setUpHarness(tester);
      await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v1')));
      await tester.pumpAndSettle();

      // Suggestions: same record and same house nearby on the roll.
      for (final name in ['सीता यादव', 'पूजा यादव', 'अजय यादव']) {
        expect(find.widgetWithText(CheckboxListTile, name), findsOneWidget);
      }

      await save(tester);
      expect(find.text('घर पर मिले व्यक्ति का नाम डालें'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'नाम'),
        'कमला देवी',
      );
      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'माता'));
      await save(tester);
      expect(
        find.text(
          'घर पर मिले व्यक्ति का मोबाइल नंबर डालें या “नंबर देने से मना किया” चुनें',
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'मोबाइल नंबर'),
        '9876543210',
      );
      await tester.pump();
      await save(tester);
      expect(find.text('मोबाइल नंबर के लिए सहमति ज़रूरी है'), findsOneWidget);
      await tapAndSettle(
        tester,
        find.widgetWithText(
          CheckboxListTile,
          'मतदाता को पढ़कर सुनाया और सहमति ली',
        ),
      );

      await save(tester);
      expect(find.text('हर सदस्य का परिणाम चुनें'), findsOneWidget);

      // The family confirms Pooja lives here too.
      await tapAndSettle(
        tester,
        find.widgetWithText(CheckboxListTile, 'पूजा यादव'),
      );
      final eligible = find.widgetWithText(
        ChoiceChip,
        'पात्र – फॉर्म भराना है',
      );
      final shifted = find.widgetWithText(ChoiceChip, 'स्थानांतरित');
      await tapAndSettle(tester, eligible.at(0));
      await tapAndSettle(tester, shifted.at(1));
      await save(tester);
      expect(find.text('कौन सा फॉर्म भरना है, चुनें'), findsOneWidget);

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'फॉर्म 6'));
      await save(tester);
      await settle(tester);

      final data = h.store.data;
      expect(data.outbox.map((e) => e.entity), ['visit', 'form', 'form_event']);
      final visit = data.outbox.first.payload;
      expect(visit['family_id'], 'f1');
      expect((visit['voters'] as List).map((m) => (m as Map)['voter_id']), [
        'v1',
        'v6',
      ]);
      expect(visit['contact_name'], 'कमला देवी');
      expect(visit['contact_relation'], 'MOTHER');
      expect(visit['contact_mobile'], '9876543210');
      expect(visit['contact_consent'], isTrue);
      expect(
        data.personStatus('v6'),
        FamilyStatus.done,
        reason: 'covered by the visit',
      );
      expect(
        data.personStatus('v2'),
        FamilyStatus.pending,
        reason: 'not ticked',
      );
      expect(
        find.text('फॉर्म विवरण'),
        findsOneWidget,
        reason: 'goes on to the form',
      );
    },
  );

  testWidgets('everyone listed not met: a revisit date is needed', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();
    await contactRefused(tester);
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'नहीं मिले'));
    await save(tester);
    expect(find.text('दोबारा जाने की तारीख़ चुनें'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);
  });

  testWidgets(
    'the location reading is taken when save is pressed, not before',
    (tester) async {
      await setUpHarness(tester);
      await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
      await tester.pumpAndSettle();
      expect(
        Harness.gps.fixRequests,
        isEmpty,
        reason: 'opening the form takes no reading',
      );

      await contactRefused(tester);
      await tapAndSettle(
        tester,
        find.widgetWithText(ChoiceChip, 'स्थानांतरित'),
      );
      await save(tester);
      await settle(tester);

      expect(Harness.gps.fixRequests, hasLength(1));
      final visit = h.store.data.outbox.single.payload;
      expect(visit['gps_lat'], 25.7612);
      expect(visit['gps_accuracy_m'], 8);
      expect(visit['flags'], isEmpty);
      expect(visit['contact_refused'], isTrue);
      expect(visit['contact_mobile'], isNull);
    },
  );

  testWidgets('saving with location refused asks again and does not save', (
    tester,
  ) async {
    await setUpHarness(tester);
    Harness.gps
      ..permission = LocationPermission.denied
      ..answer = LocationPermission.denied;
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();
    await contactRefused(tester);
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'स्थानांतरित'));
    await save(tester);

    expect(Harness.gps.prompts, 1);
    expect(find.textContaining('स्थान की अनुमति नहीं मिली'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);

    Harness.gps.answer = LocationPermission.whileInUse;
    await tapAndSettle(tester, find.text('अनुमति दें'));
    await settle(tester);
    expect(h.store.data.outbox.single.payload['gps_lat'], 25.7612);
  });

  testWidgets('no fix in time: the visit still saves, flagged', (tester) async {
    await setUpHarness(tester);
    Harness.gps.timesOut = true;
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();
    await contactRefused(tester);
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'स्थानांतरित'));
    await save(tester);
    await settle(tester);
    final visit = h.store.data.outbox.single.payload;
    expect(visit['gps_lat'], isNull);
    expect(visit['flags'], ['GPS_TIMEOUT']);
  });

  testWidgets(
    'form detail: receipt required (R1); BLA-2 route is for BLA-2s only',
    (tester) async {
      await setUpHarness(tester);
      late String formId;
      await tester.runAsync(() async {
        formId = (await h.store.saveVisit(
          const VisitDraft(
            familyId: 'f1',
            nobodyHome: false,
            contactName: 'कमला देवी',
            contactRefused: true,
            members: [
              MemberEntry(
                voterId: 'v1',
                outcome: Outcome.eligible,
                formType: '6',
              ),
            ],
          ),
        )).single;
      });
      await tester.pumpWidget(h.wrap(FormDetailScreen(formId: formId)));
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'स्वयं जमा'));
      await tapAndSettle(tester, find.text('जमा हुआ दर्ज करें'));
      expect(find.text('रसीद / संदर्भ संख्या ज़रूरी है'), findsWidgets);

      await tester.enterText(find.byType(TextField), 'REF-001');
      await tapAndSettle(
        tester,
        find.widgetWithText(ChoiceChip, 'बीएलए-2 के माध्यम से'),
      );
      await tapAndSettle(tester, find.text('जमा हुआ दर्ज करें'));
      expect(
        find.text('बीएलए-2 के माध्यम वाला फॉर्म बीएलए-2 ही जमा दर्ज करेंगे'),
        findsOneWidget,
      );

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'ऑनलाइन'));
      await tapAndSettle(tester, find.text('जमा हुआ दर्ज करें'));
      await settle(tester);
      final form = h.store.data.form(formId)!;
      expect(form.status, FormStatus.submitted);
      expect(form.referenceNo, 'REF-001');
      expect(form.route, SubmitRoute.online);
    },
  );

  testWidgets('sync screen shows a refused change with its Hindi reason', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.runAsync(() async {
      await h.store.saveVisit(
        VisitDraft(
          familyId: 'f2',
          nobodyHome: true,
          revisitOn: Ist.today(),
          members: const [MemberEntry(voterId: 'v4', outcome: Outcome.notMet)],
        ),
      );
      final batch = await h.store.pendingBatch();
      await h.store.applyPushResults(batch, [
        (
          ok: false,
          code: 'VISIT_TOO_EARLY',
          messageHi: 'भेंट की तारीख़ अभियान शुरू होने से पहले की है',
        ),
      ]);
    });
    await tester.pumpWidget(h.wrap(const SyncScreen()));
    await tester.pumpAndSettle();
    expect(
      find.text('भेंट की तारीख़ अभियान शुरू होने से पहले की है'),
      findsOneWidget,
    );
    expect(find.text('दोबारा भेजें'), findsOneWidget);
    expect(find.textContaining('सलीम सिद्दीक़ी'), findsOneWidget);
  });

  testWidgets('new voter: mobile number is checked and needs consent', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const NewVoterScreen(familyId: 'f1')));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'नेहा यादव');
    await tester.enterText(fields.at(1), 'रामलाल यादव');
    await tester.enterText(fields.at(2), '19');
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'महिला'));

    await tester.enterText(fields.at(4), '12345');
    await tester.pump();
    await save(tester);
    expect(find.text('सही मोबाइल नंबर डालें'), findsOneWidget);

    await tester.enterText(fields.at(4), '9876543210');
    await tester.pump();
    await save(tester);
    expect(find.text('मोबाइल नंबर के लिए सहमति ज़रूरी है'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);

    await tapAndSettle(tester, find.byType(Checkbox));
    await save(tester);
    await settle(tester);

    final voterItem = h.store.data.outbox.firstWhere(
      (e) => e.entity == 'voter',
    );
    expect(voterItem.payload['mobile'], '9876543210');
    expect(voterItem.payload['mobile_consent'], isTrue);
  });

  testWidgets('after sign-in, the app asks for location before field work', (
    tester,
  ) async {
    await setUpHarness(tester);
    Harness.gps
      ..permission = LocationPermission.denied
      ..answer = LocationPermission.whileInUse;
    const profile = Profile(
      id: 'me',
      name: 'सुनीता देवी',
      role: 'volunteer',
      mobile: '9000000001',
    );
    await tester.pumpWidget(h.wrap(const MainShell(profile: profile)));
    await settle(tester);

    expect(find.text('स्थान की अनुमति ज़रूरी है'), findsOneWidget);
    expect(find.text('आपके बूथ'), findsNothing);

    await tapAndSettle(tester, find.text('अनुमति दें'));
    await settle(tester);
    expect(find.text('आपके बूथ'), findsOneWidget);
  });

  testWidgets('in a browser, blocked location explains the site settings', (
    tester,
  ) async {
    await setUpHarness(tester);
    var rechecked = 0;
    Widget problem({required bool web}) => h.wrap(
      Scaffold(
        body: LocationProblem(
          access: LocationAccess.blocked,
          onAsk: () {},
          onRecheck: () => rechecked++,
          web: web,
        ),
      ),
    );

    await tester.pumpWidget(problem(web: true));
    await settle(tester);
    expect(find.textContaining('Site settings'), findsOneWidget);
    // A website cannot open the phone's settings, so no such button.
    expect(find.text('सेटिंग खोलें'), findsNothing);
    await tapAndSettle(tester, find.text('दोबारा जाँचें'));
    expect(rechecked, 1);

    await tester.pumpWidget(problem(web: false));
    await settle(tester);
    expect(find.text('सेटिंग खोलें'), findsOneWidget);
  });
}
