import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/models.dart';
import 'booth_list_screen.dart';
import 'field_scope.dart';
import 'forms_screen.dart';
import 'home_screen.dart';
import 'location_gate.dart';
import 'sync_screen.dart';

/// The signed-in app: summary, my list, forms and sync, as bottom tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.profile});

  final Profile profile;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  FieldScope? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scope != null) return;
    final scope = _scope = FieldScope.of(context);
    scope.store.claimFor(widget.profile.id).then((_) {
      if (mounted) scope.sync.start(widget.profile.id);
    });
  }

  @override
  void dispose() {
    _scope?.sync.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = FieldScope.of(context);
    return ListenableBuilder(
      listenable: scope.store,
      builder: (context, _) {
        final unsent = scope.store.data.outbox.length;
        // Sync keeps running behind the gate; only field work waits for it.
        return LocationGate(
          child: Scaffold(
            body: IndexedStack(
              index: _tab,
              children: [
                HomeScreen(onOpenList: () => setState(() => _tab = 1)),
                const BoothListScreen(embedded: true),
                const FormsScreen(),
                const SyncScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.today_outlined),
                  selectedIcon: const Icon(Icons.today),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.list_alt_outlined),
                  selectedIcon: const Icon(Icons.list_alt),
                  label: l10n.navList,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.description_outlined),
                  selectedIcon: const Icon(Icons.description),
                  label: l10n.navForms,
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unsent > 0,
                    label: Text('$unsent'),
                    child: const Icon(Icons.sync),
                  ),
                  label: l10n.navSync,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
