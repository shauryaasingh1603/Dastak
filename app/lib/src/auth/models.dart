import 'dart:convert';

/// The signed-in field user.
class Profile {
  const Profile({required this.id, required this.name, required this.role, required this.mobile});

  final String id;
  final String name;

  /// `volunteer` or `bla2`.
  final String role;
  final String mobile;

  bool get isBla2 => role == 'bla2';

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        mobile: (json['mobile'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role, 'mobile': mobile};

  String encode() => jsonEncode(toJson());
  static Profile decode(String source) => Profile.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

/// A sign-in request that is waiting for an admin. Kept on the phone so the
/// wait survives the app being closed.
class PendingLogin {
  const PendingLogin({
    required this.requestId,
    required this.matchCode,
    required this.mobile,
    required this.deviceSecret,
  });

  final String requestId;

  /// The 4-digit code the volunteer reads to the admin.
  final String matchCode;
  final String mobile;

  /// Proves to the server that this phone made the request. Never shown.
  final String deviceSecret;

  factory PendingLogin.fromJson(Map<String, dynamic> json) => PendingLogin(
        requestId: json['request_id'] as String,
        matchCode: json['match_code'] as String,
        mobile: json['mobile'] as String,
        deviceSecret: json['device_secret'] as String,
      );

  String encode() => jsonEncode({
        'request_id': requestId,
        'match_code': matchCode,
        'mobile': mobile,
        'device_secret': deviceSecret,
      });

  static PendingLogin decode(String source) =>
      PendingLogin.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

/// Why a sign-in step failed, in terms the UI can explain.
enum LoginError { invalidMobile, notRegistered, tooMany, network, generic, rejected, expired, revoked }

class LoginException implements Exception {
  const LoginException(this.error);
  final LoginError error;

  @override
  String toString() => 'LoginException(${error.name})';
}

/// Tokens handed over once an admin approves the request.
class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// Answer to "has the admin decided yet?".
sealed class LoginStatus {
  const LoginStatus();
}

class LoginPending extends LoginStatus {
  const LoginPending();
}

class LoginApproved extends LoginStatus {
  const LoginApproved(this.tokens, this.profile);
  final SessionTokens tokens;
  final Profile profile;

  String encode() => jsonEncode({
        'access_token': tokens.accessToken,
        'refresh_token': tokens.refreshToken,
        'profile': profile.toJson(),
      });

  static LoginApproved decode(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return LoginApproved(
      SessionTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      ),
      Profile.fromJson(json['profile'] as Map<String, dynamic>),
    );
  }
}

/// Rejected, expired, or no longer usable. The phone must ask again.
class LoginClosed extends LoginStatus {
  const LoginClosed(this.error);
  final LoginError error;
}
