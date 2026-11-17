import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'auth/auth_controller.dart';
import 'data/field_repository.dart';
import 'l10n.dart';
import 'theme.dart';
import 'ui/home_screen.dart';
import 'ui/login_screen.dart';
import 'ui/waiting_screen.dart';

class DastakApp extends StatefulWidget {
  const DastakApp({super.key, required this.auth, required this.repository});

  final AuthController auth;
  final FieldRepository repository;

  @override
  State<DastakApp> createState() => _DastakAppState();
}

class _DastakAppState extends State<DastakApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Coming back to the app: check at once instead of waiting for the timer.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        widget.auth.pollOnce();
        widget.auth.verifyAccess();
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
    return MaterialApp(
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
          AuthSignedIn(:final profile) => HomeScreen(
            key: ValueKey(profile.id),
            auth: widget.auth,
            profile: profile,
            repository: widget.repository,
          ),
        },
      ),
    );
  }
}
