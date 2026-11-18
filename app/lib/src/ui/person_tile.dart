import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'labels.dart';
import 'widgets.dart';

/// One listed person: name, relative, house number, and visit status.
class PersonTile extends StatelessWidget {
  const PersonTile({
    super.key,
    required this.voter,
    required this.family,
    required this.status,
    this.onTap,
  });

  final Voter voter;
  final Family? family;
  final FamilyStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final house = family?.houseNo;
    final details = [
      if (voter.relativeNameHi != null)
        '${relationLabel(l10n, voter.relationType)}: ${voter.relativeNameHi}',
      if (house != null && house.isNotEmpty) l10n.houseNo(house),
      if (voter.age != null) l10n.ageYears(voter.age!),
    ].join(' · ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voter.nameHi, style: theme.textTheme.titleMedium),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (family?.isHighPriority ?? false) ...[
                      const SizedBox(height: 4),
                      const PriorityTag(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Pill(label: familyStatusLabel(l10n, status)),
            ],
          ),
        ),
      ),
    );
  }
}
