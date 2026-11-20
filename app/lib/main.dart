import 'dart:async';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'src/app.dart';
import 'src/auth/auth_backend.dart';
import 'src/auth/auth_controller.dart';
import 'src/auth/key_value_store.dart';
import 'src/auth/secure_session_storage.dart';
import 'src/data/field_store.dart';
import 'src/data/local_db.dart';
import 'src/data/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keys = SecureKeyValueStore();
  // Opening the local database (which in a browser downloads its engine)
  // runs alongside the backend set-up, so the first screen comes sooner.
  final storeReady = () async {
    final store = FieldStore(
      LocalDb(openLocalDb(key: await _databaseKey(keys))),
    );
    await store.reload();
    return store;
  }();
  final deviceModel = _deviceModel();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(keys),
      detectSessionInUri: false,
    ),
  );
  final client = Supabase.instance.client;
  final store = await storeReady;

  late final AuthController auth;
  final sync = SyncService(
    api: SupabaseSyncApi(client),
    store: store,
    // The server refused this phone: confirm, then sign out and wipe.
    onAccessLost: () => auth.verifyAccess(),
  );
  auth = AuthController(
    backend: SupabaseAuthBackend(client),
    store: keys,
    deviceModel: await deviceModel,
    pollInterval: loginPollInterval,
    onAccessLost: () async {
      sync.stop();
      await store.wipe();
    },
  );

  runApp(DastakApp(auth: auth, store: store, sync: sync));
  unawaited(auth.start());
}

/// The local database's encryption key: random, made once per install, kept
/// in the Android Keystore.
Future<String> _databaseKey(KeyValueStore keys) async {
  const name = 'db_key';
  final existing = await keys.read(name);
  if (existing != null) return existing;
  final random = Random.secure();
  final key = List.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await keys.write(name, key);
  return key;
}

/// "Xiaomi Redmi 9A": shown to the admin next to the sign-in request.
Future<String?> _deviceModel() async {
  try {
    final plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final info = await plugin.webBrowserInfo;
      return 'Web browser (${info.browserName.name})';
    }
    final info = await plugin.androidInfo;
    final label = '${info.manufacturer} ${info.model}'.trim();
    return label.isEmpty ? null : label;
  } catch (_) {
    return null;
  }
}
