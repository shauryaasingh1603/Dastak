import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'dates.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'new_voter_screen.dart';
import 'person_tile.dart';
import 'visit_form_screen.dart';
import 'widgets.dart';

/// One listed person: their details, forms, others recorded at the same
/// house, and the visits that covered them.
class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key, required this.voterId});

  final String voterId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = FieldScope.of(context).store;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final data = store.data;
        final voter = data.voter(voterId);
        if (voter == null) {
          return Scaffold(appBar: AppBar(title: Text(l10n.personTitle)));
        }
        final family = data.family(voter.familyId);
        final category = voter.categoryCode;
        final household = data.householdOf(voterId);
        final sameRecord = [
          for (final v in data.votersOf(voter.familyId))
            if (v.id != voterId) v,
        ];
        final visits = data.visitsFor(voterId);
        final muted = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

        return Scaffold(
          appBar: AppBar(title: Text(l10n.personTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(voter.nameHi, style: theme.textTheme.titleLarge),
                      if (voter.relativeNameHi != null)
                        Text(
                          '${relationLabel(l10n, voter.relationType)}: ${voter.relativeNameHi}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      Text(
                        [
                          if (voter.age != null) l10n.ageYears(voter.age!),
                          if (voter.gender != null)
                            genderLabel(l10n, voter.gender),
                          voter.epic == null
                              ? l10n.epicMissing
                              : l10n.epicLine(voter.epic!),
                        ].join(' · '),
                        style: muted,
                      ),
                      if (family != null)
                        Text(
                          family.houseNo == null || family.houseNo!.isEmpty
                              ? l10n.boothNumber(family.partNo)
                              : l10n.houseAndBooth(
                                  family.houseNo!,
                                  family.partNo,
                                ),
                          style: muted,
                        ),
                      const SizedBox(height: 10),
                      Pill(label: categoryLabel(l10n, category)),
                      const SizedBox(height: 4),
                      Text(categoryHint(l10n, category), style: muted),
                      if (voter.newReason != null)
                        Text(
                          [
                            voter.newReason == NewReason.turned18
                                ? l10n.newReasonTurned18
                                : l10n.newReasonOther,
                            ?voter.newReasonNote,
                          ].join(': '),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (voter.closest2026 != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.closestEntry(voter.closest2026!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Pill(
                            label: familyStatusLabel(
                              l10n,
                              data.personStatus(voterId),
                            ),
                          ),
                          if (family?.isHighPriority ?? false)
                            const PriorityTag(),
                          if (voter.isNew)
                            Pill(
                              label: CodeLabel(
                                l10n.newVoterTag,
                                Icons.fiber_new_outlined,
                                const Color(0xFF0F6E77),
                              ),
                            ),
                          if (voter.alreadyOnRoll)
                            Pill(
                              label: outcomeLabel(l10n, Outcome.alreadyOnRoll),
                            ),
                          if (family?.needsReview ?? false)
                            Pill(
                              label: CodeLabel(
                                l10n.needsReview,
                                Icons.flag_outlined,
                                const Color(0xFFA3262A),
                              ),
                            ),
                          if (voter.pending)
                            Pill(
                              label: CodeLabel(
                                l10n.notSynced,
                                Icons.cloud_upload_outlined,
                                const Color(0xFF8A5A00),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              for (final form in data.formsOf(voterId)) ...[
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Text(
                      l10n.formType(form.formType),
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Pill(
                          dense: true,
                          label: formStatusLabel(l10n, form.status),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FormDetailScreen(formId: form.id),
                      ),
                    ),
                  ),
                ),
              ],
              if (household.isNotEmpty) ...[
                SectionTitle(l10n.personHousehold),
                for (final other in household) ...[
                  PersonTile(
                    voter: other,
                    family: data.family(other.familyId),
                    status: data.personStatus(other.id),
                    showBooth:
                        data.family(other.familyId)?.partNo != family?.partNo,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PersonScreen(voterId: other.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (sameRecord.isNotEmpty) ...[
                SectionTitle(l10n.personSameRecord),
                for (final other in sameRecord) ...[
                  PersonTile(
                    voter: other,
                    family: data.family(other.familyId),
                    status: data.personStatus(other.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PersonScreen(voterId: other.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NewVoterScreen(familyId: voter.familyId),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.voterAdd),
              ),
              SectionTitle(l10n.familyPrevVisits),
              if (visits.isEmpty)
                Text(l10n.familyNoVisits, style: theme.textTheme.bodyMedium)
              else
                for (final visit in visits) ...[
                  _VisitCard(visit: visit, voterId: voterId),
                  const SizedBox(height: 8),
                ],
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VisitFormScreen(voterId: voterId),
                  ),
                ),
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: Text(l10n.visitAdd),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit, required this.voterId});

  final Visit visit;
  final String voterId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mine = visit.members.where((m) => m.voterId == voterId);
    final outcome = mine.isEmpty ? visit.outcome : mine.first.outcome;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatMoment(visit.visitedAt)} · ${visit.byMe ? l10n.visitByMe : l10n.visitByOther}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (visit.pending)
                  Pill(
                    dense: true,
                    label: CodeLabel(
                      l10n.notSynced,
                      Icons.cloud_upload_outlined,
                      const Color(0xFF8A5A00),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Pill(label: outcomeLabel(l10n, outcome)),
            if (visit.revisitOn != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.revisitOn(formatDay(visit.revisitOn!)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            if (visit.remarks != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(visit.remarks!, style: theme.textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}
