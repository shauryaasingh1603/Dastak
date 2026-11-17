import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'auth_backend.dart';
import 'key_value_store.dart';
import 'models.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut({this.reason});

  /// Why the user landed here, if it was not their own choice.
  final LoginError? reason;
}

class AuthWaiting extends AuthState {
  const AuthWaiting(this.pending, {this.offline = false});
  final PendingLogin pending;

  /// The last check could not reach the server.
  final bool offline;
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.profile);
  final Profile profile;
}

/// Drives device-approval sign-in:
/// enter mobile → wait for the admin with a 4-digit code → signed in.
class AuthController extends ChangeNotifier {
  AuthController({
    required this._backend,
    required this._store,
    this.deviceModel,
    this.pollInterval = const Duration(seconds: 4),
    this.onAccessLost,
  });

  static const _deviceIdKey = 'device_id';
  static const _pendingKey = 'pending_login';
  static const _approvedKey = 'approved_login';
  static const _profileKey = 'profile';

  final AuthBackend _backend;
  final KeyValueStore _store;
  final String? deviceModel;
  final Duration pollInterval;

  /// Called when this phone loses access, so local voter data can be wiped.
  final Future<void> Function()? onAccessLost;

  AuthState _state = const AuthLoading();
  AuthState get state => _state;

  Timer? _pollTimer;
  StreamSubscription<void>? _sessionEndedSub;
  bool _polling = false;
  bool _verifying = false;
  bool _disposed = false;

  /// Restores whatever the phone was doing when the app last closed.
  Future<void> start() async {
    _sessionEndedSub = _backend.sessionEnded.listen((_) {
      if (_state is AuthSignedIn) _loseAccess();
    });

    final storedProfile = await _store.read(_profileKey);
    if (_backend.hasSession && storedProfile != null) {
      _set(AuthSignedIn(Profile.decode(storedProfile)));
      unawaited(verifyAccess());
      return;
    }

    final storedPending = await _store.read(_pendingKey);
    if (storedPending != null) {
      _set(AuthWaiting(PendingLogin.decode(storedPending)));
      _startPolling();
      unawaited(pollOnce());
      return;
    }

    _set(const AuthSignedOut());
  }

  /// Asks to sign in. Returns null on success, or the reason it failed.
  Future<LoginError?> submitMobile(String input) async {
    final mobile = normalizeMobile(input);
    if (mobile == null) return LoginError.invalidMobile;

    final secret = _randomHex(32);
    try {
      final result = await _backend.requestLogin(
        mobile: mobile,
        deviceId: await _deviceId(),
        deviceSecret: secret,
        deviceModel: deviceModel,
      );
      final pending = PendingLogin(
        requestId: result.requestId,
        matchCode: result.matchCode,
        mobile: mobile,
        deviceSecret: secret,
      );
      await _store.write(_pendingKey, pending.encode());
      _set(AuthWaiting(pending));
      _startPolling();
      return null;
    } on LoginException catch (e) {
      return e.error;
    }
  }

  /// One check of the pending request. Safe to call at any time.
  Future<void> pollOnce() async {
    final current = _state;
    if (current is! AuthWaiting || _polling) return;
    _polling = true;
    try {
      // The server hands the session over exactly once. If the network dropped
      // before it was stored, finish with the saved copy instead of asking again.
      final saved = await _store.read(_approvedKey);
      final status = saved != null
          ? LoginApproved.decode(saved)
          : await _backend.checkStatus(
              requestId: current.pending.requestId,
              deviceSecret: current.pending.deviceSecret,
            );
      // Cancelled while the call was in flight.
      if (_state is! AuthWaiting) return;
      switch (status) {
        case LoginPending():
          if (current.offline) _set(AuthWaiting(current.pending));
        case LoginApproved(:final tokens, :final profile):
          if (saved == null) await _store.write(_approvedKey, status.encode());
          await _backend.adoptSession(tokens);
          await _store.write(_profileKey, profile.encode());
          await _clearPending();
          _set(AuthSignedIn(profile));
        case LoginClosed(:final error):
          await _clearPending();
          _set(AuthSignedOut(reason: error));
      }
    } on LoginException catch (e) {
      if (_state is! AuthWaiting) return;
      if (e.error == LoginError.network) {
        if (!current.offline) _set(AuthWaiting(current.pending, offline: true));
      } else {
        await _clearPending();
        _set(AuthSignedOut(reason: e.error));
      }
    } finally {
      _polling = false;
    }
  }

  /// Gives up waiting, for example to correct a mistyped number.
  Future<void> cancelWaiting() async {
    await _clearPending();
    _set(const AuthSignedOut());
  }

  Future<void> _clearPending() async {
    _stopPolling();
    await _store.delete(_pendingKey);
    await _store.delete(_approvedKey);
  }

  /// Confirms with the server that this phone still has access. Offline, the
  /// phone keeps working; access is re-checked on the next connection.
  Future<void> verifyAccess() async {
    if (_state is! AuthSignedIn || _verifying) return;
    _verifying = true;
    try {
      final profile = await _backend.fetchProfile();
      if (_state is! AuthSignedIn) return;
      if (profile == null) {
        await _loseAccess();
      } else {
        await _store.write(_profileKey, profile.encode());
        _set(AuthSignedIn(profile));
      }
    } on LoginException {
      // Offline or server trouble: stay signed in.
    } finally {
      _verifying = false;
    }
  }

  Future<void> signOut() async {
    if (_state is! AuthSignedIn) return;
    _set(const AuthSignedOut());
    await _store.delete(_profileKey);
    await _backend.signOut();
    await onAccessLost?.call();
  }

  Future<void> _loseAccess() async {
    if (_state is! AuthSignedIn) return;
    // Leave the signed-in state first so a second trigger cannot wipe twice.
    _set(const AuthSignedOut(reason: LoginError.revoked));
    await _store.delete(_profileKey);
    await _backend.signOut();
    await onAccessLost?.call();
  }

  Future<String> _deviceId() async {
    final existing = await _store.read(_deviceIdKey);
    if (existing != null) return existing;
    final created = _randomHex(16);
    await _store.write(_deviceIdKey, created);
    return created;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) => pollOnce());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _set(AuthState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopPolling();
    _sessionEndedSub?.cancel();
    super.dispose();
  }
}

/// Returns the 10-digit Indian mobile number in [input], or null if there is
/// not exactly one. Accepts spaces, dashes and a leading +91 or 0.
String? normalizeMobile(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    digits = digits.substring(2);
  }
  if (digits.length == 11 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return RegExp(r'^[6-9]\d{9}$').hasMatch(digits) ? digits : null;
}

String _randomHex(int bytes) {
  final random = Random.secure();
  return List.generate(
    bytes,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
