import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/ui/booth_list_screen.dart';
import 'package:dastak/src/ui/family_screen.dart';
import 'package:dastak/src/ui/form_detail_screen.dart';
import 'package:dastak/src/ui/home_screen.dart';
import 'package:dastak/src/ui/main_shell.dart';
import 'package:dastak/src/auth/models.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:dastak/src/ui/new_voter_screen.dart';
import 'package:dastak/src/ui/sync_screen.dart';
import 'package:dastak/src/ui/visit_form_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

void main() {
  late Harness h;

  Future<void> setUpHarness(
    WidgetTester tester, {
    String role = 'volunteer',
  }) async {
    await tester.runAsync(() async => h = await Harness.create(role: role));
    tester.view.physicalSize = const Size(1080, 7000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  tearDown(() => h.dispose());

  testWidgets('home shows each booth on its own card', (tester) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(HomeScreen(onOpenList: () {})));
    await tester.pumpAndSettle();
    expect(find.text('बूथ 22'), findsOneWidget);
    expect(find.text('बूथ 39'), findsOneWidget);
    expect(find.text('0/2 परिवार पूरे'), findsOneWidget);
    expect(find.text('30 परिवार'), findsOneWidget);
  });

  testWidgets('a booth tab lists only that booth, with status filters', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const BoothListScreen(initialIndex: 1)));
    await tester.pumpAndSettle();
    expect(find.text('मोहन पाल'), findsOneWidget);
    expect(find.text('रामलाल यादव'), findsNothing);

    await tapAndSettle(tester, find.text('बूथ 22'));
    expect(find.text('रामलाल यादव'), findsOneWidget);
    expect(find.text('2 / 2 परिवार'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'पूरा'));
    expect(find.text('0 / 2 परिवार'), findsOneWidget);
  });

  testWidgets('visit form: nobody home needs a revisit date (R3)', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const VisitFormScreen(familyId: 'f2')));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byType(Switch));
    await tapAndSettle(tester, find.text('सेव करें'));
    expect(find.text('दोबारा जाने की तारीख़ चुनें'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);
  });

  testWidgets(
    'visit form: every member needs an outcome, eligible needs a form',
    (tester) async {
      await setUpHarness(tester);
      await tester.pumpWidget(h.wrap(const VisitFormScreen(familyId: 'f1')));
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.text('सेव करें'));
      expect(find.text('हर सदस्य का परिणाम चुनें'), findsOneWidget);

      final eligible = find.widgetWithText(
        ChoiceChip,
        'पात्र – फॉर्म भराना है',
      );
      final shifted = find.widgetWithText(ChoiceChip, 'स्थानांतरित');
      final notMet = find.widgetWithText(ChoiceChip, 'नहीं मिले');
      await tapAndSettle(tester, eligible.at(0));
      await tapAndSettle(tester, shifted.at(1));
      await tapAndSettle(tester, notMet.at(2));
      await tapAndSettle(tester, find.text('सेव करें'));
      expect(find.text('कौन सा फॉर्म भरना है, चुनें'), findsOneWidget);

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'फॉर्म 6'));
      await tapAndSettle(tester, find.text('सेव करें'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      final data = h.store.data;
      expect(data.outbox.map((e) => e.entity), ['visit', 'form', 'form_event']);
      expect(data.visitsOf('f1').single.outcome, Outcome.eligible);
      expect(
        find.text('फॉर्म विवरण'),
        findsOneWidget,
        reason: 'goes on to the form',
      );
    },
  );

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
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      final form = h.store.data.form(formId)!;
      expect(form.status, FormStatus.submitted);
      expect(form.referenceNo, 'REF-001');
      expect(form.route, SubmitRoute.online);
      expect(
        find.text(
          'यह फॉर्म जमा हो चुका है – आगे की स्थिति कार्यालय दर्ज करेगा',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('family card shows members, forms and the visit button', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const FamilyScreen(familyId: 'f1')));
    await tester.pumpAndSettle();
    expect(find.text('मकान नं. 12'), findsOneWidget);
    expect(find.text('सीता यादव'), findsOneWidget);
    expect(find.text('भेंट दर्ज करें'), findsOneWidget);
    expect(find.text('अभी कोई भेंट नहीं'), findsOneWidget);
  });

  testWidgets('sync screen shows a refused change with its Hindi reason', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.runAsync(() async {
      await h.store.saveVisit(
        VisitDraft(familyId: 'f2', nobodyHome: true, revisitOn: Ist.today()),
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
    await tester.enterText(fields.at(0), 'नेहा यादव'); // name
    await tester.enterText(fields.at(1), 'रामलाल यादव'); // relative
    await tester.enterText(fields.at(2), '19'); // age
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'महिला'));

    await tester.enterText(fields.at(4), '12345'); // mobile, too short
    await tester.pump();
    await tapAndSettle(tester, find.text('सेव करें'));
    expect(find.text('सही मोबाइल नंबर डालें'), findsOneWidget);

    await tester.enterText(fields.at(4), '9876543210');
    await tester.pump();
    await tapAndSettle(tester, find.text('सेव करें'));
    expect(find.text('मोबाइल नंबर के लिए सहमति ज़रूरी है'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);

    await tapAndSettle(tester, find.byType(Checkbox));
    await tapAndSettle(tester, find.text('सेव करें'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    final voterItem = h.store.data.outbox.firstWhere(
      (e) => e.entity == 'voter',
    );
    expect(voterItem.payload['mobile'], '9876543210');
    expect(voterItem.payload['mobile_consent'], isTrue);
    expect(voterItem.payload['name_hi'], 'नेहा यादव');
  });

  testWidgets(
    'the location reading is taken when save is pressed, not before',
    (tester) async {
      await setUpHarness(tester);
      await tester.pumpWidget(h.wrap(const VisitFormScreen(familyId: 'f2')));
      await tester.pumpAndSettle();
      expect(
        Harness.gps.fixRequests,
        isEmpty,
        reason: 'opening the form takes no reading',
      );

      await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'नहीं मिले'));
      await tapAndSettle(tester, find.text('सेव करें'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      expect(Harness.gps.fixRequests, hasLength(1));
      final visit = h.store.data.outbox.single.payload;
      expect(visit['gps_lat'], 25.7612);
      expect(visit['gps_accuracy_m'], 8);
      expect(visit['flags'], isEmpty);
    },
  );

  testWidgets('saving with location refused asks again and does not save', (
    tester,
  ) async {
    await setUpHarness(tester);
    Harness.gps
      ..permission = LocationPermission.denied
      ..answer = LocationPermission.denied;
    await tester.pumpWidget(h.wrap(const VisitFormScreen(familyId: 'f2')));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'नहीं मिले'));
    await tapAndSettle(tester, find.text('सेव करें'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(Harness.gps.prompts, 1);
    expect(find.textContaining('स्थान की अनुमति नहीं मिली'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);

    // Allowed on the second try: the visit saves with a fresh reading.
    Harness.gps.answer = LocationPermission.whileInUse;
    await tapAndSettle(tester, find.text('अनुमति दें'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(h.store.data.outbox.single.payload['gps_lat'], 25.7612);
  });

  testWidgets('no fix in time: the visit still saves, flagged', (tester) async {
    await setUpHarness(tester);
    Harness.gps.timesOut = true;
    await tester.pumpWidget(h.wrap(const VisitFormScreen(familyId: 'f2')));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'नहीं मिले'));
    await tapAndSettle(tester, find.text('सेव करें'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    final visit = h.store.data.outbox.single.payload;
    expect(visit['gps_lat'], isNull);
    expect(visit['flags'], ['GPS_TIMEOUT']);
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
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('स्थान की अनुमति ज़रूरी है'), findsOneWidget);
    expect(find.text('आपके बूथ'), findsNothing);

    await tapAndSettle(tester, find.text('अनुमति दें'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('आपके बूथ'), findsOneWidget);
  });
}
