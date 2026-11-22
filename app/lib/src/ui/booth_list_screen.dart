import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../search.dart';
import 'category_filter.dart';
import 'person_screen.dart';
import 'person_tile.dart';
import 'search_screen.dart';
import 'field_scope.dart';
import 'widgets.dart';

/// "मेरी सूची": one tab per booth. Each tab shows only that booth's families.
class BoothListScreen extends StatelessWidget {
  const BoothListScreen({
    super.key,
    this.initialIndex = 0,
    this.embedded = false,
  });

  final int initialIndex;

  /// Shown as a bottom tab rather than pushed: no back button.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final store = FieldScope.of(context).store;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final booths = store.data.booths;
        if (booths.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.listTitle),
              automaticallyImplyLeading: !embedded,
              actions: const [_SearchAction()],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: InfoBanner(
                icon: Icons.info_outline,
                text: l10n.homeNoBooths,
              ),
            ),
          );
        }
        if (booths.length == 1) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${l10n.listTitle} · ${l10n.boothNumber(booths.single.partNo)}',
              ),
              automaticallyImplyLeading: !embedded,
              actions: const [_SearchAction()],
            ),
            body: BoothFamilies(booth: booths.single),
          );
        }
        return DefaultTabController(
          key: ValueKey(booths.map((b) => b.partNo).join(',')),
          length: booths.length,
          initialIndex: initialIndex.clamp(0, booths.length - 1),
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.listTitle),
              automaticallyImplyLeading: !embedded,
              actions: const [_SearchAction()],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: scheme.onPrimary,
                unselectedLabelColor: scheme.onPrimary.withValues(alpha: 0.75),
                indicatorColor: scheme.onPrimary,
                indicatorWeight: 3,
                tabs: [
                  for (final booth in booths)
                    Tab(text: l10n.boothNumber(booth.partNo)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                for (final booth in booths)
                  BoothFamilies(
                    key: PageStorageKey(booth.partNo),
                    booth: booth,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One booth's listed people, in 2025 roll order, filterable and searchable.
class BoothFamilies extends StatefulWidget {
  const BoothFamilies({super.key, required this.booth});

  final Booth booth;

  @override
  State<BoothFamilies> createState() => _BoothFamiliesState();
}

class _BoothFamiliesState extends State<BoothFamilies>
    with AutomaticKeepAliveClientMixin {
  String _query = '';
  FamilyStatus? _filter;
  String? _category;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = FieldScope.of(context).store;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final data = store.data;
        final people = data.peopleInBooth(widget.booth.partNo);
        final query = PersonQuery(_query);
        final shown = [
          for (final v in people)
            if ((_filter == null || data.personStatus(v.id) == _filter) &&
                (_category == null || v.categoryCode == _category) &&
                query.matches(data, v))
              v,
        ];
        final filters = <(String, FamilyStatus?)>[
          (l10n.filterAll, null),
          (l10n.filterPending, FamilyStatus.pending),
          (l10n.filterDone, FamilyStatus.done),
          (l10n.filterRevisit, FamilyStatus.revisit),
        ];

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: shown.length + 1,
          itemBuilder: (context, index) {
            if (index > 0) {
              final voter = shown[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PersonTile(
                  voter: voter,
                  family: data.family(voter.familyId),
                  status: data.personStatus(voter.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PersonScreen(voterId: voter.id),
                    ),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.booth.stationHi != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      widget.booth.stationHi!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.listSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final (label, status) in filters)
                      ChoiceChip(
                        label: Text(label),
                        selected: _filter == status,
                        onSelected: (_) => setState(() => _filter = status),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                CategoryFilter(
                  people: people,
                  selected: _category,
                  onChanged: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.listShowingPeople(shown.length, people.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (people.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InfoBanner(
                      icon: Icons.info_outline,
                      text: l10n.listEmptyPeople,
                    ),
                  )
                else if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InfoBanner(
                      icon: Icons.search_off,
                      text: l10n.listNoMatchPeople,
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }
}

class _SearchAction extends StatelessWidget {
  const _SearchAction();

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).searchTitle,
    icon: const Icon(Icons.search),
    onPressed: () => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PersonSearchScreen())),
  );
}
