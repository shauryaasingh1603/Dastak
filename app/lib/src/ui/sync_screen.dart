import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/sync_service.dart';
import 'dates.dart';
import 'field_scope.dart';
import 'labels.dart';
import 'widgets.dart';

/// "सिंक स्थिति": what is waiting to be sent, the last sync, and anything the
/// server refused, with the reason in Hindi.
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  String _describe(FieldData data, OutboxEntry item) {
    final p = item.payload;
    switch (item.entity) {
      case 'visit':
        final family = data.family(p['family_id'] as String? ?? '');
        return family?.headNameHi ?? family?.code ?? '';
      case 'voter':
        return p['name_hi'] as String? ?? '';
      case 'form':
        return data.voter(p['voter_id'] as String? ?? '')?.nameHi ?? '';
      case 'form_event':
        final form = data.form(p['form_id'] as String? ?? '');
        return form == null ? '' : data.voter(form.voterId)?.nameHi ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scope = FieldScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncTitle),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([scope.store, scope.sync]),
        builder: (context, _) {
          final data = scope.store.data;
          final sync = scope.sync;
          final rejected = [
            for (final e in data.outbox)
              if (e.rejected) e,
          ];
          final pending = data.pendingCount;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (sync.running)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          else
                            Icon(
                              pending == 0 && rejected.isEmpty
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_upload_outlined,
                              color: pending == 0 && rejected.isEmpty
                                  ? const Color(0xFF1F7A4D)
                                  : theme.colorScheme.primary,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sync.running
                                  ? l10n.syncRunning
                                  : pending > 0
                                  ? l10n.syncPendingCount(pending)
                                  : l10n.syncAllSent,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.lastSyncAt == null
                            ? l10n.syncNever
                            : l10n.syncLast(formatMoment(data.lastSyncAt!)),
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (!sync.running &&
                          sync.problem != SyncProblem.none) ...[
                        const SizedBox(height: 8),
                        InfoBanner(
                          icon: Icons.wifi_off,
                          text: sync.problem == SyncProblem.offline
                              ? l10n.syncOffline
                              : l10n.syncServerError,
                        ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: sync.running ? null : sync.syncNow,
                        icon: const Icon(Icons.sync),
                        label: Text(l10n.syncNow),
                      ),
                    ],
                  ),
                ),
              ),
              if (rejected.isNotEmpty) ...[
                SectionTitle('${l10n.syncErrors} (${rejected.length})'),
                for (final item in rejected) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entityLabel(l10n, item.entity)} · ${_describe(data, item)}',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            formatMoment(item.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          InfoBanner(
                            icon: Icons.error_outline,
                            text: item.errorHi ?? l10n.errGeneric,
                            error: true,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () =>
                                    scope.store.retryRejected(item.seq),
                                child: Text(l10n.syncRetry),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(l10n.syncDiscardConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(l10n.no),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(l10n.yes),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await scope.store.discardRejected(item.seq);
                                    await scope.sync.syncNow();
                                  }
                                },
                                child: Text(l10n.syncDiscard),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              const SizedBox(height: 16),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) => Text(
                  l10n.appVersion(
                    snapshot.data == null
                        ? '…'
                        : '${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
