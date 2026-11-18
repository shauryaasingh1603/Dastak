import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/sync_service.dart';
import 'booth_list_screen.dart';
import 'dates.dart';
import 'field_scope.dart';
import 'messages.dart';
import 'widgets.dart';

/// "आज का सारांश": today's progress, the deadline, sync state and the
/// volunteer's booths. Each booth opens on its own.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenList});

  final VoidCallback onOpenList;

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final scope = FieldScope.of(context);
    if (scope.store.data.hasUnsent) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.logoutBlocked),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.yes),
            ),
          ],
        ),
      );
      return;
    }
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
    if (confirmed == true) await scope.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scope = FieldScope.of(context);
    final profile = scope.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([scope.store, scope.sync]),
        builder: (context, _) {
          final data = scope.store.data;
          final firstSync = data.lastSyncAt == null;
          final today = Ist.today();

          final doneToday = {
            for (final v in data.visits)
              if (v.byMe && Ist.day(v.visitedAt) == today) v.familyId,
          }.length;
          final remaining = data.families
              .where((f) => data.statusOf(f.id) == FamilyStatus.pending)
              .length;
          final revisitToday = data.families.where((f) {
            final visits = data.visitsOf(f.id);
            final due = visits.isEmpty ? null : visits.first.revisitOn;
            return due != null && due.compareTo(today) <= 0;
          }).length;
          final formsFilled = data.forms.where((f) => f.byMe).length;
          final daysLeft = daysUntil(data.settings.claimsCloseAt);
          final stale =
              data.oldestUnsentAt != null &&
              DateTime.now().toUtc().difference(data.oldestUnsentAt!) >
                  const Duration(hours: 24);

          return RefreshIndicator(
            onRefresh: scope.sync.syncNow,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _DeadlineBanner(daysLeft: daysLeft),
                if (stale) ...[
                  const SizedBox(height: 8),
                  _AlertBanner(text: l10n.outboxStale),
                ],
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting(profile.name),
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          '${roleText(l10n, profile.role)} · ${profile.mobile}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (firstSync)
                  scope.sync.running || scope.sync.problem == SyncProblem.none
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              Text(l10n.firstSyncLoading),
                            ],
                          ),
                        )
                      : InfoBanner(
                          icon: Icons.wifi_off,
                          text: l10n.firstSyncFailed,
                          action: TextButton(
                            onPressed: scope.sync.syncNow,
                            child: Text(l10n.retry),
                          ),
                        )
                else ...[
                  _StatsGrid(
                    items: [
                      (
                        l10n.homeTarget,
                        l10n.homeFamilyCount(data.settings.dailyFamilyTarget),
                        Icons.flag_outlined,
                      ),
                      (
                        l10n.homeDoneToday,
                        '$doneToday',
                        Icons.check_circle_outline,
                      ),
                      (
                        l10n.homeRemaining,
                        '$remaining',
                        Icons.pending_outlined,
                      ),
                      (l10n.homeRevisitToday, '$revisitToday', Icons.replay),
                      (
                        l10n.homeFormsFilled,
                        '$formsFilled',
                        Icons.description_outlined,
                      ),
                      (
                        l10n.homeSyncState,
                        data.hasUnsent
                            ? l10n.syncPendingCount(data.outbox.length)
                            : '✓',
                        Icons.sync,
                      ),
                    ],
                  ),
                  if (profile.isBla2) ...[
                    const SizedBox(height: 12),
                    QuotaCard(),
                  ],
                  const SizedBox(height: 20),
                  Text(l10n.homeBooths, style: theme.textTheme.titleMedium),
                  if (data.booths.length > 1)
                    Text(
                      l10n.homeBoothsHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (data.booths.isEmpty)
                    InfoBanner(
                      icon: Icons.info_outline,
                      text: l10n.homeNoBooths,
                    )
                  else
                    for (final (index, booth) in data.booths.indexed) ...[
                      if (index > 0) const SizedBox(height: 8),
                      _BoothCard(
                        booth: booth,
                        total: data.familiesInBooth(booth.partNo).length,
                        done: data
                            .familiesInBooth(booth.partNo)
                            .where(
                              (f) =>
                                  data.statusOf(f.id) != FamilyStatus.pending,
                            )
                            .length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                BoothListScreen(initialIndex: index),
                          ),
                        ),
                      ),
                    ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DeadlineBanner extends StatelessWidget {
  const _DeadlineBanner({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = daysLeft > 0
        ? l10n.homeDeadline(daysLeft)
        : daysLeft == 0
        ? l10n.homeDeadlineToday
        : l10n.claimsClosed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: scheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: scheme.onError),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: scheme.onError,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<(String, String, IconData)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, value, icon) in items)
              SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(value, style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BoothCard extends StatelessWidget {
  const _BoothCard({
    required this.booth,
    required this.total,
    required this.done,
    required this.onTap,
  });

  final Booth booth;
  final int total;
  final int done;
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
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.boothProgress(done, total),
                      style: theme.textTheme.bodySmall?.copyWith(
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
