import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart' show normalizeMobile;
import '../data/field_store.dart';
import '../data/models.dart';
import '../location.dart';
import 'dates.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'widgets.dart';

class _MemberState {
  _MemberState(this.voter)
    : outcome = voter.alreadyOnRoll ? Outcome.alreadyOnRoll : null;

  final Voter voter;
  String? outcome;
  String? formType; // '6', '8', or 'none'
  final docs = <String>{};
  final mobile = TextEditingController();
  bool consent = false;
}

/// "भेंट फॉर्म": records one door visit. Saves on the phone at once; the
/// sync sends it when there is network.
class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key, required this.familyId});

  final String familyId;

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _remarks = TextEditingController();
  final _scroll = ScrollController();
  List<_MemberState>? _members;
  bool _nobodyHome = false;
  String? _metPerson; // a voter id, or 'OTHER'
  String? _revisitOn;
  String? _error;
  bool _saving = false;
  LocationFix? _fix;

  @override
  void initState() {
    super.initState();
    takeFix().then((fix) {
      if (mounted) setState(() => _fix = fix);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _members ??= [
      for (final v in FieldScope.of(
        context,
      ).store.data.votersOf(widget.familyId))
        _MemberState(v),
    ];
  }

  @override
  void dispose() {
    _remarks.dispose();
    _scroll.dispose();
    for (final m in _members ?? const <_MemberState>[]) {
      m.mobile.dispose();
    }
    super.dispose();
  }

  String? _validate(AppLocalizations l10n) {
    if (_nobodyHome) {
      return _revisitOn == null ? l10n.errRevisitRequired : null; // R3
    }
    for (final m in _members!) {
      if (m.outcome == null) return l10n.errOutcomeRequired;
      if (Outcome.needsForm(m.outcome!) && m.formType == null) {
        return l10n.errFormRequired;
      }
      final mobile = m.mobile.text.trim();
      if (mobile.isNotEmpty) {
        if (normalizeMobile(mobile) == null) return l10n.errMobileInvalid; // R7
        if (!m.consent) return l10n.errConsentRequired;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final error = _validate(l10n);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    final scope = FieldScope.of(context);
    final fix = _fix;
    final metPerson = _metPerson == null
        ? null
        : _metPerson == 'OTHER'
        ? l10n.visitWhoMetOther
        : _members!.firstWhere((m) => m.voter.id == _metPerson).voter.nameHi;

    final formIds = await scope.store.saveVisit(
      VisitDraft(
        familyId: widget.familyId,
        nobodyHome: _nobodyHome,
        metPerson: metPerson,
        members: [
          for (final m in _members!)
            MemberEntry(
              voterId: m.voter.id,
              outcome: m.outcome!,
              formType: Outcome.needsForm(m.outcome!) && m.formType != 'none'
                  ? m.formType
                  : null,
              docs: m.outcome == Outcome.notMet ? const [] : m.docs.toList(),
              mobile: m.outcome == Outcome.notMet
                  ? null
                  : normalizeMobile(m.mobile.text),
              mobileConsent: m.consent,
            ),
        ],
        remarks: _remarks.text,
        revisitOn: _revisitOn,
        gpsLat: fix?.lat,
        gpsLng: fix?.lng,
        gpsAccuracy: fix?.accuracy,
        gpsFlag: fix == null ? 'GPS_OFF' : fix.flag,
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.visitSaved)));
    if (formIds.isEmpty) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => FormDetailScreen(formId: formIds.first),
        ),
      );
    }
  }

  Future<void> _pickRevisit() async {
    final settings = FieldScope.of(context).store.data.settings;
    final today = DateTime.parse(Ist.today());
    // R3: nobody home means come back within three days.
    final last = _nobodyHome
        ? today.add(const Duration(days: 3))
        : DateTime.parse(Ist.day(settings.claimsCloseAt));
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: last.isBefore(today) ? today : last,
      initialDate: _revisitOn != null
          ? DateTime.parse(_revisitOn!)
          : today.add(const Duration(days: 1)).isAfter(last)
          ? today
          : today.add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _revisitOn = dayOf(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = FieldScope.of(context).store.data;
    final family = data.family(widget.familyId);
    final members = _members!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.visitTitle)),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (family != null)
            Text(
              [
                if (family.houseNo != null) l10n.houseNo(family.houseNo!),
                if (family.headNameHi != null) family.headNameHi!,
              ].join(' · '),
              style: theme.textTheme.titleMedium,
            ),
          const SizedBox(height: 6),
          _GpsLine(fix: _fix),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: _nobodyHome,
              onChanged: (v) => setState(() {
                _nobodyHome = v;
                _revisitOn = null;
                _error = null;
              }),
              secondary: Icon(
                Icons.person_off_outlined,
                color: outcomeLabel(l10n, Outcome.notMet).color,
              ),
              title: Text(
                l10n.visitNobodyHome,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: _nobodyHome ? Text(l10n.visitNobodyHomeHint) : null,
            ),
          ),
          if (!_nobodyHome) ...[
            SectionTitle(l10n.visitWhoMet),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final m in members)
                  ChoiceChip(
                    label: Text(m.voter.nameHi),
                    selected: _metPerson == m.voter.id,
                    onSelected: (s) =>
                        setState(() => _metPerson = s ? m.voter.id : null),
                  ),
                ChoiceChip(
                  label: Text(l10n.visitWhoMetOther),
                  selected: _metPerson == 'OTHER',
                  onSelected: (s) =>
                      setState(() => _metPerson = s ? 'OTHER' : null),
                ),
              ],
            ),
            SectionTitle(l10n.visitMembers),
            for (final m in members) ...[
              _MemberEditor(
                state: m,
                data: data,
                onChanged: () => setState(() => _error = null),
              ),
              const SizedBox(height: 10),
            ],
          ],
          SectionTitle(l10n.visitRevisit),
          OutlinedButton.icon(
            onPressed: _pickRevisit,
            icon: const Icon(Icons.event),
            label: Text(
              _revisitOn == null ? l10n.visitPickDate : formatDay(_revisitOn!),
            ),
          ),
          if (_revisitOn != null && !_nobodyHome)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _revisitOn = null),
                child: Text(l10n.cancel),
              ),
            ),
          SectionTitle(l10n.visitRemarks),
          TextField(controller: _remarks, maxLines: 2, maxLength: 500),
          if (_error != null) ...[
            const SizedBox(height: 8),
            InfoBanner(icon: Icons.error_outline, text: _error!, error: true),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _GpsLine extends StatelessWidget {
  const _GpsLine({required this.fix});

  final LocationFix? fix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (text, icon, color) = switch (fix) {
      null => (
        l10n.gpsSearching,
        Icons.location_searching,
        theme.colorScheme.onSurfaceVariant,
      ),
      LocationFix(flag: null) => (
        l10n.gpsOk,
        Icons.location_on,
        const Color(0xFF1F7A4D),
      ),
      LocationFix(flag: 'GPS_INACCURATE') => (
        l10n.gpsWeak,
        Icons.location_on_outlined,
        const Color(0xFF8A5A00),
      ),
      _ => (l10n.gpsOff, Icons.location_off_outlined, const Color(0xFF8A5A00)),
    };
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _MemberEditor extends StatefulWidget {
  const _MemberEditor({
    required this.state,
    required this.data,
    required this.onChanged,
  });

  final _MemberState state;
  final FieldData data;
  final VoidCallback onChanged;

  @override
  State<_MemberEditor> createState() => _MemberEditorState();
}

class _MemberEditorState extends State<_MemberEditor> {
  void _update(VoidCallback change) {
    setState(change);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final m = widget.state;
    final voter = m.voter;
    final met = m.outcome != null && m.outcome != Outcome.notMet;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(voter.nameHi, style: theme.textTheme.titleMedium),
            Text(
              [
                if (voter.age != null) l10n.ageYears(voter.age!),
                if (voter.relativeNameHi != null)
                  '${relationLabel(l10n, voter.relationType)}: ${voter.relativeNameHi}',
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final code in Outcome.all)
                  () {
                    final label = outcomeLabel(l10n, code);
                    final selected = m.outcome == code;
                    return ChoiceChip(
                      avatar: Icon(
                        label.icon,
                        size: 18,
                        color: selected ? Colors.white : label.color,
                      ),
                      label: Text(label.text),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: label.color,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                      ),
                      onSelected: (_) => _update(() {
                        m.outcome = code;
                        if (!Outcome.needsForm(code)) m.formType = null;
                      }),
                    );
                  }(),
              ],
            ),
            if (m.outcome != null && Outcome.needsForm(m.outcome!)) ...[
              const SizedBox(height: 10),
              Text(
                l10n.visitWhichForm,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final type in ['6', '8'])
                    ChoiceChip(
                      label: Text(l10n.formType(type)),
                      selected: m.formType == type,
                      onSelected: widget.data.hasOpenForm(voter.id, type)
                          ? null
                          : (_) => _update(() => m.formType = type),
                    ),
                  ChoiceChip(
                    label: Text(l10n.formNone),
                    selected: m.formType == 'none',
                    onSelected: (_) => _update(() => m.formType = 'none'),
                  ),
                ],
              ),
              for (final type in ['6', '8'])
                if (widget.data.hasOpenForm(voter.id, type))
                  Text(
                    l10n.formAlreadyOpen(type),
                    style: theme.textTheme.bodySmall,
                  ),
              // R9: Form 6 needs age 18 on 1 Jan 2027. A warning only.
              if (m.formType == '6' && voter.age != null && voter.age! < 18)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: InfoBanner(
                    icon: Icons.warning_amber,
                    text: l10n.ageUnder18,
                  ),
                ),
            ],
            if (met) ...[
              const SizedBox(height: 10),
              Text(
                l10n.visitDocs,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final doc in Doc.all)
                    FilterChip(
                      label: Text(docLabel(l10n, doc)),
                      selected: m.docs.contains(doc),
                      onSelected: (s) => _update(
                        () => s ? m.docs.add(doc) : m.docs.remove(doc),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: m.mobile,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: l10n.visitMobile,
                  prefixText: '+91 ',
                ),
                onChanged: (_) => _update(() {}),
              ),
              if (m.mobile.text.isNotEmpty)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: m.consent,
                  onChanged: (v) => _update(() => m.consent = v ?? false),
                  title: Text(l10n.visitConsentLabel),
                  subtitle: Text('“${l10n.visitConsent}”'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
