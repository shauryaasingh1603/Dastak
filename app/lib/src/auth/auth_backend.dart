import 'package:supabase/supabase.dart';

import 'models.dart';

/// Server calls the sign-in flow needs. Split out so the flow can be tested
/// without a network.
abstract class AuthBackend {
  /// Whether a session is stored on this phone.
  bool get hasSession;

  /// Fires when the server ends the session (for example the refresh token
  /// was revoked).
  Stream<void> get sessionEnded;

  /// Asks to sign in as [mobile]. Throws [LoginException].
  /// [deviceKey] stays on this phone for good: once an admin approves this
  /// phone, later requests carrying it are approved at once for 35 days.
  Future<({String requestId, String matchCode})> requestLogin({
    required String mobile,
    required String deviceId,
    required String deviceSecret,
    String? deviceModel,
    String? deviceKey,
  });

  /// Asks whether the admin has decided. Throws [LoginException] with
  /// [LoginError.network] when the server cannot be reached.
  Future<LoginStatus> checkStatus({
    required String requestId,
    required String deviceSecret,
  });

  /// Stores the approved session on the phone.
  Future<void> adoptSession(SessionTokens tokens);

  /// The caller's own profile, or null if this phone no longer has access
  /// (deactivated, or signed in on another phone). Throws [LoginException]
  /// with [LoginError.network] when the server cannot be reached.
  Future<Profile?> fetchProfile();

  Future<void> signOut();
}

class SupabaseAuthBackend implements AuthBackend {
  SupabaseAuthBackend(this._client);

  final SupabaseClient _client;

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  Stream<void> get sessionEnded => _client.auth.onAuthStateChange.where(
    (state) => state.event == AuthChangeEvent.signedOut,
  );

  @override
  Future<({String requestId, String matchCode})> requestLogin({
    required String mobile,
    required String deviceId,
    required String deviceSecret,
    String? deviceModel,
    String? deviceKey,
  }) async {
    final Map<String, dynamic> result;
    try {
      result = Map<String, dynamic>.from(
        await _client.rpc(
          'request_login',
          params: {
            'p_mobile': mobile,
            'p_device_id': deviceId,
            'p_device_secret': deviceSecret,
            'p_device_model': deviceModel,
            'p_device_key': deviceKey,
          },
        ) as Map,
      );
    } on PostgrestException {
      throw const LoginException(LoginError.generic);
    } catch (_) {
      throw const LoginException(LoginError.network);
    }

    if (result['ok'] == true) {
      return (
        requestId: result['request_id'] as String,
        matchCode: result['match_code'] as String,
      );
    }
    throw LoginException(switch (result['code']) {
      'NOT_REGISTERED' => LoginError.notRegistered,
      'TOO_MANY' => LoginError.tooMany,
      _ => LoginError.generic,
    });
  }

  @override
  Future<LoginStatus> checkStatus({
    required String requestId,
    required String deviceSecret,
  }) async {
    final Map<String, dynamic> body;
    try {
      final response = await _client.functions.invoke(
        'login-status',
        body: {'request_id': requestId, 'device_secret': deviceSecret},
      );
      body = Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      // 5xx: the server is having trouble; keep waiting. 4xx: the request is unusable.
      if (e.status >= 500) throw const LoginException(LoginError.network);
      return const LoginClosed(LoginError.generic);
    } catch (_) {
      throw const LoginException(LoginError.network);
    }

    switch (body['status']) {
      case 'pending':
        return const LoginPending();
      case 'approved':
        final session = Map<String, dynamic>.from(body['session'] as Map);
        return LoginApproved(
          SessionTokens(
            accessToken: session['access_token'] as String,
            refreshToken: session['refresh_token'] as String,
          ),
          Profile.fromJson(Map<String, dynamic>.from(body['user'] as Map)),
        );
      case 'rejected':
        return const LoginClosed(LoginError.rejected);
      case 'expired':
        return const LoginClosed(LoginError.expired);
      default:
        // 'consumed' or 'unknown': this request cannot produce a session any more.
        return const LoginClosed(LoginError.generic);
    }
  }

  @override
  Future<void> adoptSession(SessionTokens tokens) async {
    try {
      await _client.auth.setSession(
        tokens.refreshToken,
        accessToken: tokens.accessToken,
      );
    } on AuthException {
      throw const LoginException(LoginError.generic);
    } catch (_) {
      throw const LoginException(LoginError.network);
    }
  }

  @override
  Future<Profile?> fetchProfile() async {
    try {
      // Row-level security returns only the caller's own row, and no row at
      // all once the phone has lost access.
      final row = await _client
          .from('users')
          .select('id, name, role, mobile')
          .maybeSingle();
      return row == null ? null : Profile.fromJson(row);
    } on PostgrestException catch (e) {
      // The token itself was refused: treat as lost access.
      if (e.code == 'PGRST301' || e.code == 'PGRST303') return null;
      throw const LoginException(LoginError.network);
    } catch (_) {
      throw const LoginException(LoginError.network);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Signing out must always work offline; the local session is dropped regardless.
    }
  }
}
