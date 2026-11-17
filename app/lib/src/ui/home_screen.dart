import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/models.dart';
import '../data/field_repository.dart';
import 'messages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.auth,
    required this.profile,
    required this.repository,
  });

  final AuthController auth;
  final Profile profile;
  final FieldRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeData? _data;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await widget.repository.loadHome();
      if (!mounted) return;
      setState(() {
        _data = data;
        _failed = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
      // The failure may mean this phone lost access rather than the network.
      widget.auth.verifyAccess();
    }
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = _data;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            onPressed: _confirmLogout,
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverList.list(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeGreeting(widget.profile.name),
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            '${roleText(l10n, widget.profile.role)} · ${widget.profile.mobile}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_failed) ...[
                    const SizedBox(height: 12),
                    _Banner(
                      icon: Icons.wifi_off,
                      text: data == null ? l10n.errNetwork : l10n.homeOffline,
                      action: TextButton(
                        onPressed: _load,
                        child: Text(l10n.retry),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(l10n.homeBooths, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (data == null && _loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (data != null && data.booths.isEmpty)
                    _Banner(icon: Icons.info_outline, text: l10n.homeNoBooths)
                  else if (data != null)
                    Card(
                      child: Column(
                        children: [
                          for (final (index, booth) in data.booths.indexed) ...[
                            if (index > 0) const Divider(height: 1),
                            ListTile(
                              title: Text(
                                l10n.homeBoothLine(booth.partNo, booth.nameHi),
                              ),
                              trailing: Text(
                                l10n.homeFamilyCount(booth.familyCount),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (data != null && data.booths.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(l10n.listTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (data.families.isEmpty)
                      _Banner(icon: Icons.info_outline, text: l10n.listEmpty),
                  ],
                ],
              ),
            ),
            if (data != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: data.families.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _FamilyTile(family: data.families[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  const _FamilyTile({required this.family});

  final FamilyRow family;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    family.headNameHi ?? family.code,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    family.houseNo != null && family.houseNo!.isNotEmpty
                        ? l10n.houseNo(family.houseNo!)
                        : family.code,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (family.isHighPriority)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 16,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    Text(
                      l10n.priorityHigh,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
