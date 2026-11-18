import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'field_scope.dart';
import 'labels.dart';

/// One family in a list: head of family, house number, visit status and a
/// tag when the family is high priority.
class FamilyTile extends StatelessWidget {
  const FamilyTile({
    super.key,
    required this.family,
    required this.status,
    this.onTap,
  });

  final Family family;
  final FamilyStatus status;
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
                    if (family.isHighPriority) ...[
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

class PriorityTag extends StatelessWidget {
  const PriorityTag({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 14, color: scheme.onErrorContainer),
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
    this.error = false,
  });

  final IconData icon;
  final String text;
  final Widget? action;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = error ? scheme.errorContainer : scheme.secondaryContainer;
    final fg = error ? scheme.onErrorContainer : scheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: fg)),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// A BLA-2's submissions against the 10-a-day and 30-in-total limits (R2).
class QuotaCard extends StatelessWidget {
  const QuotaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scope = FieldScope.of(context);
    final settings = scope.store.data.settings;
    final count = scope.store.bla2Count();
    final full =
        count.today >= settings.bla2DailyLimit ||
        count.total >= settings.bla2TotalLimit;
    return Card(
      color: full ? theme.colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.outbox_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.quotaLine(
                  count.today,
                  settings.bla2DailyLimit,
                  count.total,
                  settings.bla2TotalLimit,
                ),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A heading inside a scrolling page.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
