import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'src/app.dart';
import 'src/auth/auth_backend.dart';
import 'src/auth/auth_controller.dart';
import 'src/auth/key_value_store.dart';
import 'src/auth/secure_session_storage.dart';
import 'src/data/field_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const store = SecureKeyValueStore();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(store),
      detectSessionInUri: false,
    ),
  );
  final client = Supabase.instance.client;

  final auth = AuthController(
    backend: SupabaseAuthBackend(client),
    store: store,
    deviceModel: await _deviceModel(),
    pollInterval: loginPollInterval,
  );

  runApp(DastakApp(auth: auth, repository: FieldRepository(client)));
  unawaited(auth.start());
}

/// "Xiaomi Redmi 9A": shown to the admin next to the sign-in request.
Future<String?> _deviceModel() async {
  try {
    final info = await DeviceInfoPlugin().androidInfo;
    return '${info.manufacturer} ${info.model}'.trim();
  } catch (_) {
    return null;
  }
}
