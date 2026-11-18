// End-to-end check of device-approval sign-in against the real backend.
// Not part of the normal test run. It needs a registered test volunteer and
// an admin access token:
//
//   DASTAK_TEST_MOBILE=9000000001 DASTAK_ADMIN_TOKEN=<jwt> \
//     flutter test test_live/login_live_test.dart
import 'dart:io';

import 'package:dastak/config.dart';
import 'package:dastak/src/auth/auth_backend.dart';
import 'package:dastak/src/auth/auth_controller.dart';
import 'package:dastak/src/auth/key_value_store.dart';
import 'package:dastak/src/auth/models.dart';
import 'package:dastak/src/data/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';

class _EnvProxy extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..findProxy = HttpClient.findProxyFromEnvironment;
}

void main() {
  final adminToken = Platform.environment['DASTAK_ADMIN_TOKEN'];
  final mobile = Platform.environment['DASTAK_TEST_MOBILE'];
  final ready = adminToken != null && mobile != null;

  test(
    'enter mobile, admin approves, phone signs in and sees only its booths',
    () async {
      HttpOverrides.global = _EnvProxy();
      const noRefresh = AuthClientOptions(autoRefreshToken: false);
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        authOptions: noRefresh,
      );
      final admin = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        accessToken: () async => adminToken,
      );

      final auth = AuthController(
        backend: SupabaseAuthBackend(client),
        store: MemoryKeyValueStore(),
        deviceModel: 'live-test',
        pollInterval: const Duration(hours: 1),
      );
      addTearDown(auth.dispose);
      await auth.start();

      expect(await auth.submitMobile('9999999990'), LoginError.notRegistered);
      expect(await auth.submitMobile(mobile!), isNull);
      final pending = (auth.state as AuthWaiting).pending;
      expect(pending.matchCode, matches(r'^\d{4}$'));

      await auth.pollOnce();
      expect(auth.state, isA<AuthWaiting>(), reason: 'not approved yet');

      final decision = await admin.rpc(
        'decide_login_request',
        params: {'p_request_id': pending.requestId, 'p_approve': true},
      );
      expect(decision['ok'], isTrue);

      await auth.pollOnce();
      final profile = (auth.state as AuthSignedIn).profile;
      expect(profile.mobile, mobile);
      stdout.writeln('signed in as ${profile.name} (${profile.role})');

      final snapshot = await SupabaseSyncApi(client).pull();
      final parts = {
        for (final b in snapshot['booths'] as List) (b as Map)['part_no'],
      };
      stdout.writeln(
        'booths: $parts; families: ${(snapshot['families'] as List).length}',
      );
      expect(parts, isNotEmpty);
      expect(
        (snapshot['families'] as List).every(
          (f) => parts.contains((f as Map)['part_no']),
        ),
        isTrue,
      );

      await auth.verifyAccess();
      expect(auth.state, isA<AuthSignedIn>());

      // The admin signs this phone out: the next check must lock it.
      await admin
          .from('users')
          .update({'active_session_id': null})
          .eq('mobile', mobile);
      await auth.verifyAccess();
      expect((auth.state as AuthSignedOut).reason, LoginError.revoked);
      await expectLater(
        SupabaseSyncApi(client).pull(),
        throwsA(isA<SyncAccessException>()),
      );
    },
    skip: ready ? null : 'set DASTAK_ADMIN_TOKEN and DASTAK_TEST_MOBILE',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
