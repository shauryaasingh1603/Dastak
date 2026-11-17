import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/models.dart';
import '../data/field_repository.dart';
import 'booth_list_screen.dart';
import 'messages.dart';
import 'widgets.dart';

/// Today's summary: who is signed in and which booths they work in. Each
/// booth opens its own family list, so a volunteer with several booths never
/// sees them all mixed together.
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
  List<BoothSummary>? _booths;
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
      final booths = await widget.repository.loadBooths(widget.profile.id);
      if (!mounted) return;
      setState(() {
        _booths = booths;
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

  void _openBooth(int index) {
    final booths = _booths;
    if (booths == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BoothListScreen(
          booths: booths,
          initialIndex: index,
          repository: widget.repository,
        ),
      ),
    );
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
    final booths = _booths;

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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
              InfoBanner(
                icon: Icons.wifi_off,
                text: booths == null ? l10n.errNetwork : l10n.homeOffline,
                action: TextButton(onPressed: _load, child: Text(l10n.retry)),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.homeBooths, style: theme.textTheme.titleMedium),
            if (booths != null && booths.length > 1)
              Text(
                l10n.homeBoothsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            if (booths == null && _loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (booths != null && booths.isEmpty)
              InfoBanner(icon: Icons.info_outline, text: l10n.homeNoBooths)
            else if (booths != null)
              for (final (index, booth) in booths.indexed) ...[
                if (index > 0) const SizedBox(height: 8),
                _BoothCard(booth: booth, onTap: () => _openBooth(index)),
              ],
          ],
        ),
      ),
    );
  }
}

class _BoothCard extends StatelessWidget {
  const _BoothCard({required this.booth, required this.onTap});

  final BoothSummary booth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${booth.partNo}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.boothNumber(booth.partNo),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (booth.stationHi != null)
                      Text(
                        booth.stationHi!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    Text(
                      l10n.homeFamilyCount(booth.familyCount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
