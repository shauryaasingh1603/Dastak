import 'package:dastak/src/data/field_repository.dart';
import 'package:dastak/src/l10n.dart';
import 'package:dastak/src/ui/booth_list_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase/supabase.dart';

class _FakeRepository extends FieldRepository {
  _FakeRepository()
    : super(
        SupabaseClient(
          'http://localhost',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  final loaded = <int>[];

  @override
  Future<List<FamilyRow>> loadBoothFamilies(int partNo) async {
    loaded.add(partNo);
    FamilyRow row(String id, int section, String house, String name) =>
        FamilyRow(
          id: id,
          code: '371-$partNo-$id',
          partNo: partNo,
          sectionNo: section,
          houseNo: house,
          headNameHi: name,
          priority: 2,
        );
    return [
      row('1', 1, '12', 'रामलाल यादव'),
      row('2', 1, '13', 'सलीम सिद्दीक़ी'),
      row('3', 2, '4', 'सुनीता यादव'),
    ];
  }
}

const _booths = [
  BoothSummary(partNo: 22, stationHi: 'पहला केंद्र', familyCount: 3),
  BoothSummary(partNo: 39, stationHi: 'दूसरा केंद्र', familyCount: 3),
];

Widget _app(Widget home) => MaterialApp(
  locale: appLocale,
  supportedLocales: const [appLocale],
  localizationsDelegates: appLocalizationsDelegates,
  home: home,
);

void main() {
  testWidgets('opens on the tapped booth and loads only that booth', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(
      _app(
        BoothListScreen(
          booths: _booths,
          repository: repository,
          initialIndex: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('बूथ 22'), findsOneWidget);
    expect(find.text('बूथ 39'), findsOneWidget);
    expect(find.text('दूसरा केंद्र'), findsOneWidget);
    expect(repository.loaded, [39]);
    expect(find.text('अनुभाग 1'), findsOneWidget);
    expect(find.text('अनुभाग 2'), findsOneWidget);

    await tester.tap(find.text('बूथ 22'));
    await tester.pumpAndSettle();
    expect(find.text('पहला केंद्र'), findsOneWidget);
    expect(repository.loaded, containsAll([39, 22]));
  });

  testWidgets('search narrows the booth list, ignoring nukta differences', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        BoothListScreen(
          booths: const [
            BoothSummary(partNo: 22, stationHi: null, familyCount: 3),
          ],
          repository: _FakeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 / 3 परिवार'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'यादव');
    await tester.pump();
    expect(find.text('2 / 3 परिवार'), findsOneWidget);
    expect(find.text('सलीम सिद्दीक़ी'), findsNothing);

    await tester.enterText(find.byType(TextField), 'सिद्दीकी');
    await tester.pump();
    expect(find.text('1 / 3 परिवार'), findsOneWidget);
    expect(find.text('सलीम सिद्दीक़ी'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '13');
    await tester.pump();
    expect(find.text('1 / 3 परिवार'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'कोई नहीं');
    await tester.pump();
    expect(find.text('खोज से कोई परिवार नहीं मिला'), findsOneWidget);
  });
}
