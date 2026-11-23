import 'package:dastak/src/auth/auth_backend.dart';
import 'package:dastak/src/auth/auth_controller.dart';
import 'package:dastak/src/auth/key_value_store.dart';
import 'package:dastak/src/auth/models.dart';
import 'package:dastak/src/data/field_store.dart';
import 'package:dastak/src/data/local_db.dart';
import 'package:dastak/src/data/sync_service.dart';
import 'package:dastak/src/l10n.dart';
import 'package:dastak/src/theme.dart';
import 'package:dastak/src/ui/field_scope.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:drift/native.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_geolocator.dart';
import 'sample_snapshot.dart';

class _SignedInBackend implements AuthBackend {
  _SignedInBackend(this.profile);

  final Profile profile;

  @override
  bool get hasSession => true;
  @override
  Stream<void> get sessionEnded => const Stream.empty();
  @override
  Future<Profile?> fetchProfile() async => profile;
  @override
  Future<void> signOut() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A sync that never reaches a server.
class OfflineApi implements SyncApi {
  @override
  Future<List<({bool ok, String? code, String? messageHi})>> push(
    List<Map<String, dynamic>> items,
    DateTime deviceNow,
  ) async => throw const SyncNetworkException();

  @override
  Future<Map<String, dynamic>> pull() async =>
      throw const SyncNetworkException();

  @override
  Future<bool> uploadPhoto(String formId, Uint8List jpeg) async =>
      throw const SyncNetworkException();
}

/// A signed-in app on an in-memory database seeded with [sampleSnapshot].
class Harness {
  Harness._(this.db, this.store, this.auth, this.sync);

  final LocalDb db;
  final FieldStore store;
  final AuthController auth;
  final SyncService sync;

  /// The phone's location, scripted. Precise and on by default.
  static FakeGeolocator gps = FakeGeolocator();

  static Future<Harness> create({String role = 'volunteer'}) async {
    GeolocatorPlatform.instance = gps = FakeGeolocator();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = LocalDb(NativeDatabase.memory());
    final store = FieldStore(db);
    await store.applySnapshot(sampleSnapshot(), userId: 'me');
    final keys = MemoryKeyValueStore();
    final profile = Profile(
      id: 'me',
      name: 'सुनीता देवी',
      role: role,
      mobile: '9000000001',
    );
    await keys.write('profile', profile.encode());
    final auth = AuthController(
      backend: _SignedInBackend(profile),
      store: keys,
      pollInterval: const Duration(hours: 1),
    );
    await auth.start();
    final sync = SyncService(
      api: OfflineApi(),
      store: store,
      onAccessLost: () async {},
      interval: const Duration(hours: 1),
    );
    return Harness._(db, store, auth, sync);
  }

  Widget wrap(Widget home) => FieldScope(
    store: store,
    sync: sync,
    auth: auth,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: appLocale,
      supportedLocales: const [appLocale],
      localizationsDelegates: appLocalizationsDelegates,
      home: home,
    ),
  );

  Future<void> dispose() async {
    sync.dispose();
    auth.dispose();
    await db.close();
  }
}
