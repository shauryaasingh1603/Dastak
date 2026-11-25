import 'package:dastak/src/auth/models.dart';
import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/ui/booth_list_screen.dart';
import 'package:dastak/src/ui/form_detail_screen.dart';
import 'package:dastak/src/location.dart';
import 'package:dastak/src/ui/face_photo.dart';
import 'package:dastak/src/ui/home_screen.dart';
import 'package:dastak/src/ui/location_gate.dart';
import 'package:dastak/src/ui/main_shell.dart';
import 'package:dastak/src/ui/new_voter_screen.dart';
import 'package:dastak/src/ui/person_screen.dart';
import 'package:dastak/src/ui/search_screen.dart';
import 'package:dastak/src/ui/sync_screen.dart';
import 'package:dastak/src/ui/eci_shot.dart';
import 'package:dastak/src/ui/visit_form_screen.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

// A tiny valid JPEG, and another standing in for an ECI screenshot.
final _jpeg = Uint8List.fromList(const [
  255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, //
  255, 219, 0, 67, 0, 13, 9, 10, 11, 10, 8, 13, 11, 10, 11, 14, 14, 13, 15,
  19, 32, 21, 19, 18, 18, 19, 39, 28, 30, 23, 32, 46, 41, 49, 3, 17, 0, 63, 0,
  146, 138, 40, 174, 19, 210, 63, 255, 217,
]);
final _screenshot = Uint8List.fromList([
  ..._jpeg.sublist(0, 20),
  1,
  ..._jpeg.sublist(20),
]);

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
    FacePhotoField.take = () async => _jpeg;
    EciShotField.pick = () async => _screenshot;
    addTearDown(() {
      FacePhotoField.take = takeWithCamera;
      EciShotField.pick = pickScreenshot;
    });
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

  tearDown(() => h.dispose());

  testWidgets('home counts people, booth by booth', (tester) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(HomeScreen(onOpenList: () {})));
    await tester.pumpAndSettle();
    expect(find.text('बूथ 22'), findsOneWidget);
    expect(find.text('बूथ 39'), findsOneWidget);
    expect(find.text('0/5 लोग पूरे'), findsOneWidget);
    expect(find.text('आज का लक्ष्य'), findsNothing, reason: 'no daily target');
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

  testWidgets('a visit is one of two choices; one must be picked', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();
    expect(find.text('कोई नहीं मिला'), findsOneWidget);
    expect(find.text('नाम कट गया है, फ़ॉर्म 6 भरना है'), findsOneWidget);
    expect(find.text('अन्य कारण'), findsNothing);
    await save(tester);
    expect(find.text('ऊपर दो में से एक चुनें'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);
  });

  testWidgets('nobody met: comes back tomorrow unless another day is picked', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();
    expect(
      Harness.gps.fixRequests,
      isEmpty,
      reason: 'opening the form takes no reading',
    );
    await tapAndSettle(tester, find.text('कोई नहीं मिला'));
    await tapAndSettle(tester, find.textContaining('परसों'));
    await save(tester);
    await settle(tester);

    expect(Harness.gps.fixRequests, hasLength(1));
    final visit = h.store.data.outbox.single.payload;
    expect(visit['outcome'], Outcome.notMet);
    expect(visit['revisit_on'], Ist.addDays(Ist.today(), 2));
    expect(visit['voters'], [containsPair('voter_id', 'v4')]);
    expect(visit['gps_lat'], 25.7612);
    expect(visit['gps_accuracy_m'], 8);
    expect(visit['flags'], isEmpty);
    expect(find.byType(VisitFormScreen), findsNothing, reason: 'closed');
  });

  testWidgets('form 6: a reminder first, then the ECI screenshot is required', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text('नाम कट गया है, फ़ॉर्म 6 भरना है'));
    expect(find.text('पहले ECI ऐप में फ़ॉर्म 6 भरें'), findsOneWidget);
    // The example screenshot can be opened from the reminder.
    await tapAndSettle(tester, find.text('उदाहरण देखें').last);
    expect(find.text('ऐसा स्क्रीनशॉट लगाएँ'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    await tapAndSettle(tester, find.text('ठीक है').last);
    await tapAndSettle(tester, find.text('ठीक है'));
    expect(find.text('पहले ECI ऐप में फ़ॉर्म 6 भरें'), findsNothing);

    await save(tester);
    expect(find.text('ECI ऐप का स्क्रीनशॉट लगाएँ'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);

    await tapAndSettle(tester, find.text('स्क्रीनशॉट लगाएँ'));
    await tapAndSettle(tester, find.text('फ़ोटो लें'));
    // The number is always asked for: a number, or "declined".
    await save(tester);
    expect(
      find.text('मोबाइल नंबर डालें या “नंबर देने से मना किया” चुनें'),
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
    await settle(tester);

    final data = h.store.data;
    expect(data.outbox.map((e) => e.entity), ['visit', 'form', 'form_event']);
    final visit = data.outbox.first.payload;
    expect(visit['outcome'], Outcome.eligible);
    expect(visit['contact_name'], isNull);
    expect(
      (visit['voters'] as List).single,
      allOf(
        containsPair('voter_id', 'v4'),
        containsPair('mobile', '9876543210'),
        containsPair('mobile_consent', true),
      ),
    );
    final form = data.forms.single;
    expect(form.formType, '6');
    expect(data.localEci, {form.id});
    expect(data.localPhotos, {form.id});
    expect(
      await tester.runAsync(() => h.store.photoOf(form.id, kind: 'eci')),
      _screenshot,
    );
    expect(await tester.runAsync(() => h.store.photoOf(form.id)), _jpeg);
  });

  testWidgets('saving with location refused asks again and does not save', (
    tester,
  ) async {
    await setUpHarness(tester);
    Harness.gps
      ..permission = LocationPermission.denied
      ..answer = LocationPermission.denied;
    await tester.pumpWidget(h.wrap(const VisitFormScreen(voterId: 'v4')));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('कोई नहीं मिला'));
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
    await tapAndSettle(tester, find.text('कोई नहीं मिला'));
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

    // Why they are added comes first; "other" asks for a short note.
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'अन्य').first);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'बाहर से आकर बसे');
    await tester.enterText(fields.at(1), 'नेहा यादव');
    await tester.enterText(fields.at(2), 'रामलाल यादव');
    await tester.enterText(fields.at(3), '19');
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'महिला'));

    await tester.enterText(fields.at(5), '12345');
    await tester.pump();
    await save(tester);
    expect(find.text('सही मोबाइल नंबर डालें'), findsOneWidget);

    await tester.enterText(fields.at(5), '9876543210');
    await tester.pump();
    await save(tester);
    expect(find.text('मोबाइल नंबर के लिए सहमति ज़रूरी है'), findsOneWidget);
    expect(h.store.data.outbox, isEmpty);

    await tapAndSettle(
      tester,
      find.widgetWithText(
        CheckboxListTile,
        'मतदाता को पढ़कर सुनाया और सहमति ली',
      ),
    );
    await save(tester);
    expect(find.text('ECI ऐप का स्क्रीनशॉट लगाएँ'), findsOneWidget);
    await tapAndSettle(tester, find.text('स्क्रीनशॉट लगाएँ'));
    await save(tester);
    await settle(tester);

    final voterItem = h.store.data.outbox.firstWhere(
      (e) => e.entity == 'voter',
    );
    expect(voterItem.payload['mobile'], '9876543210');
    expect(voterItem.payload['mobile_consent'], isTrue);
    expect(voterItem.payload['new_reason'], 'OTHER');
    expect(voterItem.payload['new_reason_note'], 'बाहर से आकर बसे');
    expect(voterItem.payload['family_id'], 'f1');
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

  testWidgets('a booth tab filters people by category', (tester) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const BoothListScreen()));
    await tester.pumpAndSettle();
    expect(find.text('5 / 5 लोग'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'दोहरा नाम 1'));
    expect(find.text('1 / 5 लोग'), findsOneWidget);
    expect(find.text('पूजा यादव'), findsOneWidget);
    expect(find.text('सीता यादव'), findsNothing);

    await tapAndSettle(
      tester,
      find.widgetWithText(ChoiceChip, 'सभी श्रेणियाँ'),
    );
    expect(find.text('5 / 5 लोग'), findsOneWidget);
  });

  testWidgets('person card shows the category and the 2026 entry to check', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const PersonScreen(voterId: 'v1')));
    await tester.pumpAndSettle();
    expect(find.text('शायद सूची में है'), findsOneWidget);
    expect(find.text('2027 ड्राफ्ट सूची: भाग 24, सेक्शन 3'), findsOneWidget);
    expect(
      find.textContaining('मिलती-जुलती प्रविष्टि (पहले जाँचें)'),
      findsOneWidget,
    );
  });

  testWidgets('search finds people in every booth, in English letters too', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const PersonSearchScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'mohan');
    await settle(tester);
    expect(find.text('मोहन पाल'), findsOneWidget);
    expect(find.text('1 लोग मिले'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'yadav');
    await settle(tester);
    expect(find.text('4 लोग मिले'), findsOneWidget);
  });

  testWidgets('someone who turned 18, at a house nobody listed lives in', (
    tester,
  ) async {
    await setUpHarness(tester);
    await tester.pumpWidget(h.wrap(const NewVoterScreen(partNo: 39)));
    await tester.pumpAndSettle();

    await tapAndSettle(
      tester,
      find.widgetWithText(ChoiceChip, 'इस साल 18 के हुए'),
    );
    final fields = find.byType(TextField);
    // House, name, relative, age (filled in as 18), EPIC, mobile.
    expect(tester.widget<TextField>(fields.at(3)).controller!.text, '18');
    await save(tester);
    expect(find.text('मकान नंबर लिखें'), findsOneWidget);

    await tester.enterText(fields.at(0), '7क');
    await tester.enterText(fields.at(1), 'आरती पाल');
    await tester.enterText(fields.at(2), 'मोहन पाल');
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'महिला'));
    await tester.enterText(fields.at(3), '21');
    await save(tester);
    expect(
      find.text('इस साल 18 के हुए: उम्र 17 या 18 होनी चाहिए'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(3), '18');
    await save(tester);
    expect(
      find.text('मोबाइल नंबर डालें या “नंबर देने से मना किया” चुनें'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('नंबर देने से मना किया'));
    await tapAndSettle(tester, find.text('स्क्रीनशॉट लगाएँ'));
    await save(tester);
    await settle(tester);

    final outbox = h.store.data.outbox;
    expect(outbox.map((e) => e.entity).take(2), ['family', 'voter']);
    expect(outbox[0].payload, {
      'part_no': 39,
      'house_no': '7क',
      'head_name_hi': 'आरती पाल',
    });
    expect(outbox[1].payload['family_id'], outbox[0].uuid);
    expect(outbox[1].payload['new_reason'], 'TURNED_18_THIS_YEAR');
    expect(outbox.where((e) => e.entity == 'form'), hasLength(1));
    // Listed in booth 39 straight away.
    expect(
      h.store.data.peopleInBooth(39).map((v) => v.nameHi),
      contains('आरती पाल'),
    );
  });

  testWidgets('form detail: the ECI screenshot and what was read from it', (
    tester,
  ) async {
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
    expect(find.text('ECI स्क्रीनशॉट नहीं लगा है। इसे लगाएँ।'), findsOneWidget);

    await tapAndSettle(tester, find.text('स्क्रीनशॉट लगाएँ'));
    await settle(tester);
    expect(h.store.data.localEci, {formId});
    expect(
      find.text('स्क्रीनशॉट फ़ोन पर है, नेटवर्क मिलते ही भेजा जाएगा'),
      findsOneWidget,
    );
  });
}
