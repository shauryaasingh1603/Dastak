import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../location.dart';

/// Shows [child] only once precise location is allowed and switched on.
/// Until then, explains why it is needed and how to allow it. Checks again
/// whenever the app comes back to the front (e.g. from the phone's settings).
class LocationGate extends StatefulWidget {
  const LocationGate({super.key, required this.child});

  final Widget child;

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate> {
  LocationAccess? _access;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check({bool ask = false}) async {
    final access = await locationAccess(ask: ask);
    if (mounted) setState(() => _access = access);
  }

  @override
  Widget build(BuildContext context) {
    final access = _access;
    if (access == LocationAccess.granted) return widget.child;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locTitle),
        automaticallyImplyLeading: false,
      ),
      body: access == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Icon(
                    Icons.location_on,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.locExplain,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  LocationProblem(
                    access: access,
                    onAsk: () => _check(ask: true),
                    onRecheck: _check,
                  ),
                ],
              ),
            ),
    );
  }
}

/// What is wrong with location access, and the buttons that fix it.
class LocationProblem extends StatelessWidget {
  const LocationProblem({
    super.key,
    required this.access,
    required this.onAsk,
    required this.onRecheck,
    this.web = kIsWeb,
  });

  final LocationAccess access;

  /// In a browser the website cannot open the phone's settings; the steps
  /// go through the browser's own site settings instead.
  final bool web;
  final VoidCallback onAsk;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final message = switch (access) {
      LocationAccess.denied => web ? l10n.locDeniedWeb : l10n.locDenied,
      LocationAccess.blocked => web ? l10n.locBlockedWeb : l10n.locBlocked,
      LocationAccess.approximate => l10n.locApproximate,
      LocationAccess.serviceOff => l10n.locServiceOff,
      LocationAccess.granted => '',
    };
    final settings = OutlinedButton.icon(
      onPressed: () => openLocationFix(access),
      icon: const Icon(Icons.settings_outlined),
      label: Text(
        access == LocationAccess.serviceOff
            ? l10n.locTurnOn
            : l10n.locOpenSettings,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_off_outlined, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (access == LocationAccess.denied ||
            access == LocationAccess.approximate) ...[
          FilledButton.icon(
            onPressed: onAsk,
            icon: const Icon(Icons.my_location),
            label: Text(l10n.locAllow),
          ),
          const SizedBox(height: 8),
          if (access == LocationAccess.approximate && !web) settings,
        ] else ...[
          if (!web) ...[settings, const SizedBox(height: 8)],
          TextButton(onPressed: onRecheck, child: Text(l10n.locCheckAgain)),
        ],
      ],
    );
  }
}
