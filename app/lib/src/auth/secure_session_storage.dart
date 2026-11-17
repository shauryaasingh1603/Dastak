import 'package:supabase_flutter/supabase_flutter.dart';

import 'key_value_store.dart';

/// Keeps the Supabase session in encrypted storage instead of plain
/// shared preferences.
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage(this._store);

  static const _key = 'supabase_session';
  final KeyValueStore _store;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => (await _store.read(_key)) != null;

  @override
  Future<String?> accessToken() => _store.read(_key);

  @override
  Future<void> removePersistedSession() => _store.delete(_key);

  @override
  Future<void> persistSession(String persistSessionString) => _store.write(_key, persistSessionString);
}
