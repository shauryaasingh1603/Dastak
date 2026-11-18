import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import '../text.dart';
import 'family_screen.dart';
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

/// One booth's families, grouped by section, filterable and searchable.
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

  @override
  bool get wantKeepAlive => true;

  bool _matches(FieldData data, Family family, String needle) {
    if (needle.isEmpty) return true;
    if ((family.houseNo ?? '').toLowerCase() == needle) return true;
    if (normalizeForSearch(family.headNameHi ?? '').contains(needle)) {
      return true;
    }
    for (final v in data.votersOf(family.id)) {
      if (normalizeForSearch(v.nameHi).contains(needle)) return true;
      if ((v.epic ?? '').toLowerCase().contains(needle)) return true;
    }
    return false;
  }

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
        final families = data.familiesInBooth(widget.booth.partNo)
          ..sort((a, b) {
            final bySection = (a.sectionNo ?? 1 << 30).compareTo(
              b.sectionNo ?? 1 << 30,
            );
            if (bySection != 0) return bySection;
            final byHouse = compareHouseNo(a.houseNo, b.houseNo);
            return byHouse != 0 ? byHouse : a.code.compareTo(b.code);
          });
        final needle = normalizeForSearch(_query);
        final shown = [
          for (final f in families)
            if ((_filter == null || data.statusOf(f.id) == _filter) &&
                _matches(data, f, needle))
              f,
        ];

        final rows = <Widget>[];
        int? section = -1;
        for (final family in shown) {
          if (family.sectionNo != section) {
            section = family.sectionNo;
            rows.add(
              SectionTitle(
                section == null
                    ? l10n.sectionUnknown
                    : l10n.sectionHeader(section),
              ),
            );
          }
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FamilyTile(
                family: family,
                status: data.statusOf(family.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FamilyScreen(familyId: family.id),
                  ),
                ),
              ),
            ),
          );
        }

        final filters = <(String, FamilyStatus?)>[
          (l10n.filterAll, null),
          (l10n.filterPending, FamilyStatus.pending),
          (l10n.filterDone, FamilyStatus.done),
          (l10n.filterRevisit, FamilyStatus.revisit),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
            const SizedBox(height: 4),
            Text(
              l10n.listShowing(shown.length, families.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (families.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InfoBanner(
                  icon: Icons.info_outline,
                  text: l10n.listEmpty,
                ),
              )
            else if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InfoBanner(
                  icon: Icons.search_off,
                  text: l10n.listNoMatch,
                ),
              ),
            ...rows,
          ],
        );
      },
    );
  }
}
