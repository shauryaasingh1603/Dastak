import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';

/// Shows the 4-digit code the volunteer reads to the admin, and waits.
class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key, required this.auth, required this.state});

  final AuthController auth;
  final AuthWaiting state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.waitingTitle), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.waitingCodeLabel, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Semantics(
                    label: state.pending.matchCode.split('').join(' '),
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final digit in state.pending.matchCode.split(''))
                            Container(
                              width: 60,
                              height: 76,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: scheme.primary, width: 2),
                              ),
                              child: Text(
                                digit,
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                  height: 1.1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.waitingInstruction, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    '+91 ${state.pending.mobile}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.offline)
                        Icon(Icons.wifi_off, color: scheme.error)
                      else
                        const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3)),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          state.offline ? l10n.waitingOffline : l10n.waitingChecking,
                          style: theme.textTheme.bodyMedium?.copyWith(color: state.offline ? scheme.error : null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  TextButton(onPressed: auth.cancelWaiting, child: Text(l10n.waitingCancel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
