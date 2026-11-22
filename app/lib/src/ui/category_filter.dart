import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'labels.dart';

/// A sideways-scrolling row of category chips with how many people each
/// has; only categories present among [people] are offered.
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.people,
    required this.selected,
    required this.onChanged,
  });

  final List<Voter> people;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final counts = <String, int>{};
    for (final v in people) {
      counts.update(v.categoryCode, (n) => n + 1, ifAbsent: () => 1);
    }
    final codes = [
      for (final code in VoterCategory.all)
        if (counts.containsKey(code) || code == selected) code,
    ];
    if (codes.length < 2 && selected == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text(l10n.catFilterAll),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          for (final code in codes) ...[
            const SizedBox(width: 6),
            ChoiceChip(
              avatar: Icon(
                categoryLabel(l10n, code).icon,
                size: 18,
                color: categoryLabel(l10n, code).color,
              ),
              label: Text(
                '${categoryLabel(l10n, code).text} ${counts[code] ?? 0}',
              ),
              selected: selected == code,
              onSelected: (on) => onChanged(on ? code : null),
            ),
          ],
        ],
      ),
    );
  }
}
