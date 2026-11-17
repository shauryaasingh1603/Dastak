import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/field_repository.dart';
import '../text.dart';
import 'widgets.dart';

/// "मेरी सूची": one tab per booth. Only the open booth's families are loaded
/// and shown; the tabs switch between booths.
class BoothListScreen extends StatelessWidget {
  const BoothListScreen({
    super.key,
    required this.booths,
    required this.repository,
    this.initialIndex = 0,
  });

  final List<BoothSummary> booths;
  final FieldRepository repository;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (booths.length == 1) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.boothNumber(booths.single.partNo))),
        body: BoothFamilies(booth: booths.single, repository: repository),
      );
    }

    return DefaultTabController(
      length: booths.length,
      initialIndex: initialIndex.clamp(0, booths.length - 1),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.listTitle),
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
                repository: repository,
              ),
          ],
        ),
      ),
    );
  }
}

/// One booth's families, grouped by section and searchable.
class BoothFamilies extends StatefulWidget {
  const BoothFamilies({
    super.key,
    required this.booth,
    required this.repository,
  });

  final BoothSummary booth;
  final FieldRepository repository;

  @override
  State<BoothFamilies> createState() => _BoothFamiliesState();
}

class _BoothFamiliesState extends State<BoothFamilies>
    with AutomaticKeepAliveClientMixin {
  List<FamilyRow>? _families;
  bool _failed = false;
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final families = await widget.repository.loadBoothFamilies(
        widget.booth.partNo,
      );
      if (mounted) setState(() => _families = families);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  List<FamilyRow> _filtered(List<FamilyRow> families) {
    final needle = normalizeForSearch(_query);
    if (needle.isEmpty) return families;
    return [
      for (final f in families)
        if (normalizeForSearch(f.headNameHi ?? '').contains(needle) ||
            (f.houseNo ?? '').toLowerCase() == needle ||
            f.code.toLowerCase().contains(needle))
          f,
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final families = _families;

    if (families == null) {
      return _failed
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: InfoBanner(
                icon: Icons.wifi_off,
                text: l10n.errNetwork,
                action: TextButton(onPressed: _load, child: Text(l10n.retry)),
              ),
            )
          : const Center(child: CircularProgressIndicator());
    }

    final shown = _filtered(families);
    final rows = <Widget>[];
    int? section = -1;
    for (final family in shown) {
      if (family.sectionNo != section) {
        section = family.sectionNo;
        rows.add(
          _SectionHeader(
            text: section == null
                ? l10n.sectionUnknown
                : l10n.sectionHeader(section),
          ),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FamilyTile(family: family),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
          const SizedBox(height: 6),
          Text(
            l10n.listShowing(shown.length, families.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (families.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InfoBanner(icon: Icons.info_outline, text: l10n.listEmpty),
            )
          else if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InfoBanner(icon: Icons.search_off, text: l10n.listNoMatch),
            ),
          ...rows,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
