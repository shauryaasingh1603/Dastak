// Renders the main screens to PNG files with the bundled Hindi font, so the
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
import 'package:dastak/src/data/field_repository.dart';
import 'package:dastak/src/l10n.dart';
import 'package:dastak/src/theme.dart';
import 'package:dastak/src/ui/booth_list_screen.dart';
import 'package:dastak/src/ui/home_screen.dart';
import 'package:dastak/src/ui/login_screen.dart';
import 'package:dastak/src/ui/waiting_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase/supabase.dart';

class _NoBackend implements AuthBackend {
  @override
  bool get hasSession => false;
  @override
  Stream<void> get sessionEnded => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _SampleRepository extends FieldRepository {
  _SampleRepository()
    : super(
        SupabaseClient(
          'http://localhost',
          'preview',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  static const booths = [
    BoothSummary(
      partNo: 22,
      stationHi: 'प्राथमिक विद्यालय जफ़राबाद, कक्ष सं. 1',
      familyCount: 47,
    ),
    BoothSummary(partNo: 23, stationHi: 'पंचायत भवन नाथूपुर', familyCount: 40),
    BoothSummary(
      partNo: 39,
      stationHi: 'कन्या पूर्व माध्यमिक विद्यालय, उत्तरी भाग',
      familyCount: 52,
    ),
    BoothSummary(partNo: 45, stationHi: null, familyCount: 0),
  ];

  @override
  Future<List<BoothSummary>> loadBooths(String userId) async => booths;

  @override
  Future<List<FamilyRow>> loadBoothFamilies(int partNo) async => [
    FamilyRow(
      id: '1',
      code: '371-0$partNo-F0001',
      partNo: partNo,
      sectionNo: 1,
      houseNo: '12',
      headNameHi: 'रामलाल यादव',
      priority: 1,
    ),
    FamilyRow(
      id: '2',
      code: '371-0$partNo-F0002',
      partNo: partNo,
      sectionNo: 1,
      houseNo: '13क',
      headNameHi: 'श्रीमती सावित्री मिश्रा',
      priority: 2,
    ),
    FamilyRow(
      id: '3',
      code: '371-0$partNo-F0003',
      partNo: partNo,
      sectionNo: 2,
      houseNo: '4',
      headNameHi: 'मोहम्मद इमरान सिद्दीक़ी',
      priority: 3,
    ),
    FamilyRow(
      id: '4',
      code: '371-0$partNo-F0004',
      partNo: partNo,
      sectionNo: 2,
      houseNo: '21',
      headNameHi: 'क्षत्रपाल त्रिपाठी',
      priority: 1,
    ),
  ];
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
  final auth = AuthController(
    backend: _NoBackend(),
    store: MemoryKeyValueStore(),
  );
  const profile = Profile(
    id: 'u1',
    name: 'सुनीता देवी',
    role: 'bla2',
    mobile: '9000000001',
  );
  const pending = PendingLogin(
    requestId: 'r',
    matchCode: '4821',
    mobile: '9000000001',
    deviceSecret: 's',
  );

  setUpAll(() async {
    await _loadFont(fontFamily, [
      'assets/fonts/NotoSansDevanagari-400.ttf',
      'assets/fonts/NotoSansDevanagari-500.ttf',
      'assets/fonts/NotoSansDevanagari-700.ttf',
    ]);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  Future<void> shoot(WidgetTester tester, String name, Widget screen) async {
    // A small, cheap phone: 360 x 720 dp.
    tester.view.physicalSize = const Size(720, 1440);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: appLocalizationsDelegates,
        home: screen,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
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

  testWidgets(
    'login',
    (tester) => shoot(tester, 'login', LoginScreen(auth: auth)),
  );
  testWidgets(
    'login with error',
    (tester) => shoot(
      tester,
      'login_error',
      LoginScreen(auth: auth, reason: LoginError.rejected),
    ),
  );
  testWidgets(
    'waiting',
    (tester) => shoot(
      tester,
      'waiting',
      WaitingScreen(auth: auth, state: const AuthWaiting(pending)),
    ),
  );
  testWidgets(
    'waiting offline',
    (tester) => shoot(
      tester,
      'waiting_offline',
      WaitingScreen(
        auth: auth,
        state: const AuthWaiting(pending, offline: true),
      ),
    ),
  );
  testWidgets(
    'home',
    (tester) => shoot(
      tester,
      'home',
      HomeScreen(auth: auth, profile: profile, repository: _SampleRepository()),
    ),
  );
  testWidgets(
    'booth list',
    (tester) => shoot(
      tester,
      'booth_list',
      BoothListScreen(
        booths: _SampleRepository.booths,
        repository: _SampleRepository(),
        initialIndex: 1,
      ),
    ),
  );
}
