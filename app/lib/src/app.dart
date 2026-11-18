import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'auth/auth_controller.dart';
import 'data/field_store.dart';
import 'data/sync_service.dart';
import 'l10n.dart';
import 'theme.dart';
import 'ui/field_scope.dart';
import 'ui/login_screen.dart';
import 'ui/main_shell.dart';
import 'ui/waiting_screen.dart';

class DastakApp extends StatefulWidget {
  const DastakApp({
    super.key,
    required this.auth,
    required this.store,
    required this.sync,
  });

  final AuthController auth;
  final FieldStore store;
  final SyncService sync;

  @override
  State<DastakApp> createState() => _DastakAppState();
}

class _DastakAppState extends State<DastakApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Coming back to the app: check at once instead of waiting for a timer.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        widget.auth.pollOnce();
        widget.auth.verifyAccess();
        widget.sync.syncNow();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FieldScope(
      store: widget.store,
      sync: widget.sync,
      auth: widget.auth,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: appLocalizationsDelegates,
        home: ListenableBuilder(
          listenable: widget.auth,
          builder: (context, _) => switch (widget.auth.state) {
            AuthLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            AuthSignedOut(:final reason) => LoginScreen(
              key: ValueKey(reason),
              auth: widget.auth,
              reason: reason,
            ),
            final AuthWaiting state => WaitingScreen(
              auth: widget.auth,
              state: state,
            ),
            AuthSignedIn(:final profile) => MainShell(
              key: ValueKey(profile.id),
              profile: profile,
            ),
          },
        ),
      ),
    );
  }
}
