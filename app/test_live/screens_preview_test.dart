// Renders the app's screens to PNG files with the bundled Hindi font, so the
// layout can be checked without a phone. Not part of the normal test run:
//
//   flutter test --update-goldens test_live/screens_preview_test.dart
//
// Images are written to test_live/previews/.
import 'dart:io';

import 'package:dastak/src/auth/auth_backend.dart';
import 'package:dastak/src/auth/auth_controller.dart';
import 'package:dastak/src/auth/key_value_store.dart';
import 'package:dastak/src/auth/models.dart';
import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/models.dart';
import 'package:dastak/src/ui/booth_list_screen.dart';
import 'package:dastak/src/ui/family_screen.dart';
import 'package:dastak/src/ui/form_detail_screen.dart';
import 'package:dastak/src/ui/forms_screen.dart';
import 'package:dastak/src/ui/login_screen.dart';
import 'package:dastak/src/ui/main_shell.dart';
import 'package:dastak/src/ui/new_voter_screen.dart';
import 'package:dastak/src/ui/sync_screen.dart';
import 'package:dastak/src/ui/visit_form_screen.dart';
import 'package:dastak/src/ui/waiting_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/harness.dart';

import 'package:dastak/src/ui/location_gate.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class _NoBackend implements AuthBackend {
  @override
  bool get hasSession => false;
  @override
  Stream<void> get sessionEnded => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    loader.addFont(
      File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
    );
  }
  await loader.load();
}

void main() {
  late Harness h;
  late String formId;

  setUpAll(() async {
    await _loadFont('NotoSansDevanagari', [
      'assets/fonts/NotoSansDevanagari-400.ttf',
      'assets/fonts/NotoSansDevanagari-500.ttf',
      'assets/fonts/NotoSansDevanagari-700.ttf',
    ]);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget screen, {
    String role = 'bla2',
    double height = 1440,
    bool settle = true,
    void Function()? before,
  }) async {
    await tester.runAsync(() async {
      h = await Harness.create(role: role);
      // Some work already done: one visit with a form, one family to revisit.
      formId = (await h.store.saveVisit(
        const VisitDraft(
          familyId: 'f1',
          nobodyHome: false,
          members: [
            MemberEntry(
              voterId: 'v1',
              outcome: Outcome.eligible,
              formType: '6',
              docs: ['AADHAAR'],
            ),
            MemberEntry(voterId: 'v2', outcome: Outcome.shifted),
            MemberEntry(voterId: 'v3', outcome: Outcome.notMet),
          ],
          remarks: 'शाम को दोबारा आएँ',
        ),
      )).single;
      await h.store.saveVisit(
        VisitDraft(familyId: 'f2', nobodyHome: true, revisitOn: Ist.today()),
      );
    });
    addTearDown(() => tester.runAsync(h.dispose));
    before?.call();
    // A small, cheap phone: 360 dp wide.
    tester.view.physicalSize = Size(720, height);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(h.wrap(screen));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(
      tester.takeException(),
      isNull,
      reason: '$name must lay out without overflow',
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('previews/$name.png'),
    );
  }

  testWidgets('login', (tester) async {
    final auth = AuthController(
      backend: _NoBackend(),
      store: MemoryKeyValueStore(),
    );
    await shoot(tester, 'login', LoginScreen(auth: auth));
  });

  testWidgets('login with error', (tester) async {
    final auth = AuthController(
      backend: _NoBackend(),
      store: MemoryKeyValueStore(),
    );
    await shoot(
      tester,
      'login_error',
      LoginScreen(auth: auth, reason: LoginError.rejected),
    );
  });

  testWidgets('waiting', (tester) async {
    final auth = AuthController(
      backend: _NoBackend(),
      store: MemoryKeyValueStore(),
    );
    const pending = PendingLogin(
      requestId: 'r',
      matchCode: '4821',
      mobile: '9000000001',
      deviceSecret: 's',
    );
    await shoot(
      tester,
      'waiting',
      WaitingScreen(auth: auth, state: const AuthWaiting(pending)),
      settle: false,
    );
  });

  testWidgets('home', (tester) async {
    await shoot(
      tester,
      'home',
      const MainShell(
        profile: Profile(
          id: 'me',
          name: 'सुनीता देवी',
          role: 'bla2',
          mobile: '9000000001',
        ),
      ),
      height: 2000,
    );
  });

  testWidgets(
    'booth list',
    (tester) => shoot(tester, 'booth_list', const BoothListScreen()),
  );
  testWidgets(
    'family',
    (tester) => shoot(
      tester,
      'family',
      const FamilyScreen(familyId: 'f1'),
      height: 2600,
    ),
  );
  testWidgets(
    'visit form',
    (tester) => shoot(
      tester,
      'visit_form',
      const VisitFormScreen(familyId: 'f1'),
      height: 3000,
    ),
  );
  testWidgets('form detail', (tester) async {
    await tester.runAsync(() async {});
    await shoot(
      tester,
      'form_detail',
      Builder(builder: (_) => FormDetailScreen(formId: formId)),
      height: 1800,
    );
  });
  testWidgets('forms', (tester) => shoot(tester, 'forms', const FormsScreen()));
  testWidgets('sync', (tester) => shoot(tester, 'sync', const SyncScreen()));
  testWidgets(
    'new voter',
    (tester) => shoot(
      tester,
      'new_voter',
      const NewVoterScreen(familyId: 'f1'),
      height: 2000,
    ),
  );
  testWidgets(
    'location permission',
    (tester) => shoot(
      tester,
      'location_permission',
      const LocationGate(child: SizedBox()),
      before: () => Harness.gps.permission = LocationPermission.deniedForever,
    ),
  );
}
