import 'dart:async';

import 'package:dastak/src/auth/auth_backend.dart';
import 'package:dastak/src/auth/auth_controller.dart';
import 'package:dastak/src/auth/key_value_store.dart';
import 'package:dastak/src/auth/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = Profile(id: 'u1', name: 'रामलाल', role: 'volunteer', mobile: '9000000001');
const _approved = LoginApproved(SessionTokens(accessToken: 'a', refreshToken: 'r'), _profile);

/// Scriptable stand-in for the server.
class FakeBackend implements AuthBackend {
  @override
  bool hasSession = false;

  final ended = StreamController<void>.broadcast();
  @override
  Stream<void> get sessionEnded => ended.stream;

  LoginError? requestError;
  int requests = 0;
  String? lastMobile;
  String? lastSecret;

  /// Answers for successive status checks; the last one repeats.
  List<Object> statuses = [const LoginPending()];
  int checks = 0;

  bool adoptFailsWithNetwork = false;
  int adopts = 0;

  Object? profileAnswer = _profile; // Profile, null (revoked) or LoginException
  bool signedOut = false;

  @override
  Future<({String requestId, String matchCode})> requestLogin({
    required String mobile,
    required String deviceId,
    required String deviceSecret,
    String? deviceModel,
  }) async {
    requests++;
    lastMobile = mobile;
    lastSecret = deviceSecret;
    if (requestError != null) throw LoginException(requestError!);
    return (requestId: 'req-$requests', matchCode: '4821');
  }

  @override
  Future<LoginStatus> checkStatus({required String requestId, required String deviceSecret}) async {
    final answer = statuses[checks < statuses.length ? checks : statuses.length - 1];
    checks++;
    if (answer is LoginException) throw answer;
    return answer as LoginStatus;
  }

  @override
  Future<void> adoptSession(SessionTokens tokens) async {
    adopts++;
    if (adoptFailsWithNetwork) throw const LoginException(LoginError.network);
    hasSession = true;
  }

  @override
  Future<Profile?> fetchProfile() async {
    final answer = profileAnswer;
    if (answer is LoginException) throw answer;
    return answer as Profile?;
  }

  @override
  Future<void> signOut() async {
    hasSession = false;
    signedOut = true;
  }
}

void main() {
  late FakeBackend backend;
  late MemoryKeyValueStore store;
  late AuthController auth;
  var wipes = 0;

  AuthController build() => AuthController(
        backend: backend,
        store: store,
        deviceModel: 'Test Phone',
        // Long enough that tests drive polling by hand.
        pollInterval: const Duration(hours: 1),
        onAccessLost: () async => wipes++,
      );

  setUp(() {
    backend = FakeBackend();
    store = MemoryKeyValueStore();
    wipes = 0;
    auth = build();
  });

  tearDown(() => auth.dispose());

  group('normalizeMobile', () {
    test('accepts common ways of writing a number', () {
      expect(normalizeMobile('9000000001'), '9000000001');
      expect(normalizeMobile('+91 90000 00001'), '9000000001');
      expect(normalizeMobile('090000-00001'), '9000000001');
    });

    test('rejects numbers that cannot be Indian mobiles', () {
      expect(normalizeMobile(''), isNull);
      expect(normalizeMobile('12345'), isNull);
      expect(normalizeMobile('5000000001'), isNull);
      expect(normalizeMobile('90000000011'), isNull);
    });
  });

  test('a fresh install starts signed out', () async {
    await auth.start();
    expect(auth.state, isA<AuthSignedOut>());
    expect((auth.state as AuthSignedOut).reason, isNull);
  });

  test('an invalid number never reaches the server', () async {
    await auth.start();
    expect(await auth.submitMobile('1234'), LoginError.invalidMobile);
    expect(backend.requests, 0);
    expect(auth.state, isA<AuthSignedOut>());
  });

  test('an unregistered number is reported and nothing is stored', () async {
    await auth.start();
    backend.requestError = LoginError.notRegistered;
    expect(await auth.submitMobile('9000000001'), LoginError.notRegistered);
    expect(auth.state, isA<AuthSignedOut>());
    expect(store.values.containsKey('pending_login'), isFalse);
  });

  test('a registered number waits with the code, then signs in on approval', () async {
    await auth.start();
    expect(await auth.submitMobile('+91 90000 00001'), isNull);

    final waiting = auth.state as AuthWaiting;
    expect(waiting.pending.matchCode, '4821');
    expect(backend.lastMobile, '9000000001');
    expect(backend.lastSecret!.length, 64);

    await auth.pollOnce();
    expect(auth.state, isA<AuthWaiting>(), reason: 'still pending');

    backend.statuses = [_approved];
    backend.checks = 0;
    await auth.pollOnce();

    expect((auth.state as AuthSignedIn).profile.name, 'रामलाल');
    expect(backend.hasSession, isTrue);
    expect(store.values.containsKey('pending_login'), isFalse);
    expect(store.values.containsKey('approved_login'), isFalse);
    expect(store.values.containsKey('profile'), isTrue);
  });

  test('each request uses a new secret but the same device id', () async {
    await auth.start();
    await auth.submitMobile('9000000001');
    final firstSecret = backend.lastSecret;
    final deviceId = store.values['device_id'];
    await auth.cancelWaiting();
    await auth.submitMobile('9000000001');
    expect(backend.lastSecret, isNot(firstSecret));
    expect(store.values['device_id'], deviceId);
  });

  test('rejection returns to login with the reason', () async {
    await auth.start();
    await auth.submitMobile('9000000001');
    backend.statuses = [const LoginClosed(LoginError.rejected)];
    await auth.pollOnce();
    expect((auth.state as AuthSignedOut).reason, LoginError.rejected);
    expect(store.values.containsKey('pending_login'), isFalse);
  });

  test('losing the network while waiting keeps waiting and recovers', () async {
    await auth.start();
    await auth.submitMobile('9000000001');
    backend.statuses = [const LoginException(LoginError.network), const LoginPending(), _approved];

    await auth.pollOnce();
    expect((auth.state as AuthWaiting).offline, isTrue);
    await auth.pollOnce();
    expect((auth.state as AuthWaiting).offline, isFalse);
    await auth.pollOnce();
    expect(auth.state, isA<AuthSignedIn>());
  });

  test('a session issued just as the network drops is kept and used later', () async {
    await auth.start();
    await auth.submitMobile('9000000001');
    backend.statuses = [_approved, const LoginClosed(LoginError.generic)];
    backend.adoptFailsWithNetwork = true;

    await auth.pollOnce();
    expect(auth.state, isA<AuthWaiting>());
    expect(backend.checks, 1);

    // The server would now say the request is spent; the phone must not ask.
    backend.adoptFailsWithNetwork = false;
    await auth.pollOnce();
    expect(auth.state, isA<AuthSignedIn>());
    expect(backend.checks, 1);
    expect(backend.adopts, 2);
  });

  test('the wait survives an app restart', () async {
    await auth.start();
    await auth.submitMobile('9000000001');
    auth.dispose();

    auth = build();
    await auth.start();
    expect((auth.state as AuthWaiting).pending.matchCode, '4821');
  });

  test('cancelling the wait forgets the request', () async {
    await auth.start();
    await auth.submitMobile('9000000001');
    await auth.cancelWaiting();
    expect(auth.state, isA<AuthSignedOut>());
    expect(store.values.containsKey('pending_login'), isFalse);
  });

  group('once signed in', () {
    setUp(() async {
      backend.hasSession = true;
      await store.write('profile', _profile.encode());
    });

    test('a restart goes straight to the signed-in state', () async {
      await auth.start();
      await pumpEventQueue();
      expect((auth.state as AuthSignedIn).profile.id, 'u1');
    });

    test('being offline keeps the user signed in', () async {
      backend.profileAnswer = const LoginException(LoginError.network);
      await auth.start();
      await auth.verifyAccess();
      await pumpEventQueue();
      expect(auth.state, isA<AuthSignedIn>());
      expect(wipes, 0);
    });

    test('a deactivated or replaced phone is signed out and wiped', () async {
      backend.profileAnswer = null;
      await auth.start();
      await auth.verifyAccess();
      await pumpEventQueue();
      expect((auth.state as AuthSignedOut).reason, LoginError.revoked);
      expect(backend.signedOut, isTrue);
      expect(wipes, 1);
      expect(store.values.containsKey('profile'), isFalse);
    });

    test('the server ending the session signs the user out', () async {
      backend.profileAnswer = const LoginException(LoginError.network);
      await auth.start();
      backend.ended.add(null);
      await pumpEventQueue();
      expect((auth.state as AuthSignedOut).reason, LoginError.revoked);
      expect(wipes, 1);
    });

    test('a changed name on the server is picked up', () async {
      backend.profileAnswer = const Profile(id: 'u1', name: 'रामलाल यादव', role: 'bla2', mobile: '9000000001');
      await auth.start();
      await auth.verifyAccess();
      await pumpEventQueue();
      final profile = (auth.state as AuthSignedIn).profile;
      expect(profile.name, 'रामलाल यादव');
      expect(profile.isBla2, isTrue);
    });

    test('signing out wipes local data', () async {
      await auth.start();
      await auth.signOut();
      expect(auth.state, isA<AuthSignedOut>());
      expect(wipes, 1);
    });
  });
}
