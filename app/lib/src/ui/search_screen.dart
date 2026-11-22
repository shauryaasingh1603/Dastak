import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../search.dart';
import 'category_filter.dart';
import 'field_scope.dart';
import 'labels.dart';
import 'person_screen.dart';
import 'person_tile.dart';
import 'widgets.dart';

/// "लोग खोजें": every person in all of the volunteer's booths, by name,
/// relative's name (Hindi or English letters), EPIC or house number, with
/// the category filter.
///
/// With [pick], it chooses a household member during a visit instead: a tap
/// returns that person's id, and people in [exclude] are shown as already
/// added.
class PersonSearchScreen extends StatefulWidget {
  const PersonSearchScreen({
    super.key,
    this.pick = false,
    this.exclude = const {},
  });

  final bool pick;
  final Set<String> exclude;

  @override
  State<PersonSearchScreen> createState() => _PersonSearchScreenState();
}

class _PersonSearchScreenState extends State<PersonSearchScreen> {
  static const _limit = 100;

  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = FieldScope.of(context).store;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pick ? l10n.visitPickTitle : l10n.searchTitle),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final data = store.data;
          final everyone = [
            for (final b in data.booths) ...data.peopleInBooth(b.partNo),
          ];
          final query = PersonQuery(_query);
          final searching = !query.isEmpty || _category != null;
          final found = searching
              ? [
                  for (final v in everyone)
                    if ((_category == null || v.categoryCode == _category) &&
                        query.matches(data, v))
                      v,
                ]
              : const <Voter>[];
          final shown = found.take(_limit).toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: shown.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      autofocus: true,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryFilter(
                      people: everyone,
                      selected: _category,
                      onChanged: (c) => setState(() => _category = c),
                    ),
                    const SizedBox(height: 8),
                    if (!searching)
                      Text(l10n.searchStart, style: muted)
                    else if (found.isEmpty)
                      InfoBanner(
                        icon: Icons.search_off,
                        text: l10n.searchNoResult,
                      )
                    else ...[
                      Text(l10n.searchResults(found.length), style: muted),
                      if (found.length > _limit)
                        Text(l10n.searchMore(_limit), style: muted),
                    ],
                    const SizedBox(height: 8),
                  ],
                );
              }
              final voter = shown[index - 1];
              final added = widget.exclude.contains(voter.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PersonTile(
                  voter: voter,
                  family: data.family(voter.familyId),
                  status: data.personStatus(voter.id),
                  showBooth: data.booths.length > 1,
                  trailing: widget.pick
                      ? (added
                            ? Pill(
                                dense: true,
                                label: CodeLabel(
                                  l10n.visitAlreadyAdded,
                                  Icons.check,
                                  const Color(0xFF1F7A4D),
                                ),
                              )
                            : Icon(
                                Icons.add_circle_outline,
                                color: theme.colorScheme.primary,
                                size: 30,
                              ))
                      : null,
                  onTap: widget.pick
                      ? (added
                            ? null
                            : () => Navigator.of(context).pop(voter.id))
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PersonScreen(voterId: voter.id),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// A search box that opens [PersonSearchScreen]: shown at the top of the
/// home screen.
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PersonSearchScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.searchOpen,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
