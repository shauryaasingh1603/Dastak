import '../../l10n/app_localizations.dart';
import '../auth/models.dart';

/// The Hindi sentence shown for each sign-in problem.
String loginErrorText(AppLocalizations l10n, LoginError error) => switch (error) {
      LoginError.invalidMobile => l10n.errMobileInvalid,
      LoginError.notRegistered => l10n.errNotRegistered,
      LoginError.tooMany => l10n.errTooMany,
      LoginError.network => l10n.errNetwork,
      LoginError.generic => l10n.errGeneric,
      LoginError.rejected => l10n.loginRejected,
      LoginError.expired => l10n.loginExpired,
      LoginError.revoked => l10n.accessRevoked,
    };

String roleText(AppLocalizations l10n, String role) => role == 'bla2' ? l10n.roleBla2 : l10n.roleVolunteer;
