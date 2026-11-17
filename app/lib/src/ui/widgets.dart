import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/field_repository.dart';

/// One family in a list: head of family, house number, and a tag when the
/// family is high priority.
class FamilyTile extends StatelessWidget {
  const FamilyTile({super.key, required this.family, this.onTap});

  final FamilyRow family;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final house = family.houseNo;
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
                    Text(
                      family.headNameHi ?? family.code,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      house != null && house.isNotEmpty
                          ? l10n.houseNo(house)
                          : family.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (family.isHighPriority) const PriorityTag(),
            ],
          ),
        ),
      ),
    );
  }
}

class PriorityTag extends StatelessWidget {
  const PriorityTag({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 16, color: scheme.onErrorContainer),
          Text(
            AppLocalizations.of(context).priorityHigh,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width notice with an icon and an optional action.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.action,
  });

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
