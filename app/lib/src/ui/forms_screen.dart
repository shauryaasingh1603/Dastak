import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'widgets.dart';

/// "फॉर्म स्थिति": every form in the user's booths, one tab per status.
class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final scope = FieldScope.of(context);

    return ListenableBuilder(
      listenable: scope.store,
      builder: (context, _) {
        final data = scope.store.data;
        final byStatus = {
          for (final s in FormStatus.all)
            s: [
              for (final f in data.forms)
                if (f.status == s) f,
            ],
        };
        return DefaultTabController(
          length: FormStatus.all.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.formsTitle),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: scheme.onPrimary,
                unselectedLabelColor: scheme.onPrimary.withValues(alpha: 0.75),
                indicatorColor: scheme.onPrimary,
                indicatorWeight: 3,
                tabs: [
                  for (final s in FormStatus.all)
                    Tab(
                      text:
                          '${formStatusLabel(l10n, s).text} (${byStatus[s]!.length})',
                    ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                for (final s in FormStatus.all)
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (scope.profile.isBla2) ...[
                        const QuotaCard(),
                        const SizedBox(height: 12),
                      ],
                      if (byStatus[s]!.isEmpty)
                        InfoBanner(
                          icon: Icons.inbox_outlined,
                          text: l10n.formsEmpty,
                        )
                      else
                        for (final form in byStatus[s]!) ...[
                          _FormTile(form: form, data: data),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormTile extends StatelessWidget {
  const _FormTile({required this.form, required this.data});

  final ClaimForm form;
  final FieldData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final voter = data.voter(form.voterId);
    final family = voter == null ? null : data.family(voter.familyId);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FormDetailScreen(formId: form.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${voter?.nameHi ?? '—'} · ${l10n.formType(form.formType)}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      [
                        if (family != null) l10n.boothNumber(family.partNo),
                        if (family?.houseNo != null)
                          l10n.houseNo(family!.houseNo!),
                        if (form.route != null) routeLabel(l10n, form.route!),
                        if (form.referenceNo != null) form.referenceNo!,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (form.pending)
                Pill(
                  dense: true,
                  label: CodeLabel(
                    l10n.notSynced,
                    Icons.cloud_upload_outlined,
                    const Color(0xFF8A5A00),
                  ),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
