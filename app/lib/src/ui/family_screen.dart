import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'dates.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'new_voter_screen.dart';
import 'visit_form_screen.dart';
import 'widgets.dart';

/// "परिवार कार्ड": one family, its members with their forms, and past visits.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = FieldScope.of(context).store;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final data = store.data;
        final family = data.family(familyId);
        if (family == null) {
          return Scaffold(appBar: AppBar(title: Text(l10n.familyTitle)));
        }
        final voters = data.votersOf(familyId);
        final visits = data.visitsOf(familyId);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.familyTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        family.houseNo == null
                            ? family.code
                            : l10n.houseNo(family.houseNo!),
                        style: theme.textTheme.titleLarge,
                      ),
                      if (family.headNameHi != null)
                        Text(
                          l10n.familyHead(family.headNameHi!),
                          style: theme.textTheme.bodyLarge,
                        ),
                      Text(
                        [
                          l10n.boothNumber(family.partNo),
                          if (family.sectionNo != null)
                            l10n.sectionHeader(family.sectionNo!),
                          family.code,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Pill(
                            label: familyStatusLabel(
                              l10n,
                              data.statusOf(familyId),
                            ),
                          ),
                          if (family.isHighPriority) const PriorityTag(),
                          if (family.needsReview)
                            Pill(
                              label: CodeLabel(
                                l10n.needsReview,
                                Icons.flag_outlined,
                                const Color(0xFFA3262A),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SectionTitle(l10n.familyMembers),
              for (final voter in voters) ...[
                _MemberCard(voter: voter, forms: data.formsOf(voter.id)),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NewVoterScreen(familyId: familyId),
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
                  _VisitCard(visit: visit, voters: voters),
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
                    builder: (_) => VisitFormScreen(familyId: familyId),
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

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.voter, required this.forms});

  final Voter voter;
  final List<ClaimForm> forms;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final reason = reasonLabel(l10n, voter);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(voter.nameHi, style: theme.textTheme.titleMedium),
                if (voter.isNew)
                  Pill(
                    dense: true,
                    label: CodeLabel(
                      l10n.newVoterTag,
                      Icons.fiber_new_outlined,
                      const Color(0xFF0F6E77),
                    ),
                  ),
                if (voter.alreadyOnRoll)
                  Pill(
                    dense: true,
                    label: outcomeLabel(l10n, Outcome.alreadyOnRoll),
                  ),
                if (voter.pending)
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
            if (voter.relativeNameHi != null)
              Text(
                '${relationLabel(l10n, voter.relationType)}: ${voter.relativeNameHi}',
                style: theme.textTheme.bodyMedium,
              ),
            Text(
              [
                if (voter.age != null) l10n.ageYears(voter.age!),
                if (voter.gender != null) genderLabel(l10n, voter.gender),
                voter.epic == null
                    ? l10n.epicMissing
                    : l10n.epicLine(voter.epic!),
              ].join(' · '),
              style: muted,
            ),
            if (reason != null) Text(reason, style: muted),
            for (final form in forms) ...[
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FormDetailScreen(formId: form.id),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.formType(form.formType),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Pill(
                        dense: true,
                        label: formStatusLabel(l10n, form.status),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit, required this.voters});

  final Visit visit;
  final List<Voter> voters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final names = {for (final v in voters) v.id: v.nameHi};
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
            Pill(label: outcomeLabel(l10n, visit.outcome)),
            for (final m in visit.members)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${names[m.voterId] ?? '—'}: ${outcomeLabel(l10n, m.outcome).text}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
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
