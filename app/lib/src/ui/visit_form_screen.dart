import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart' show normalizeMobile;
import '../data/field_store.dart';
import '../data/models.dart';
import '../location.dart';
import 'dates.dart';
import 'face_photo.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'location_gate.dart';
import 'search_screen.dart';
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
  Uint8List? photo;
}

/// "भेंट फॉर्म": one door visit, opened from one listed person. The
/// volunteer confirms who else on the list lives at this house, records who
/// answered the door with their number (or that they refused), and an
/// outcome for each listed person. Saves on the phone at once.
class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key, required this.voterId});

  final String voterId;

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _remarks = TextEditingController();
  final _contactName = TextEditingController();
  final _contactMobile = TextEditingController();
  final _states = <String, _MemberState>{};
  final _alsoHere = <String>{};
  late Voter _lead;
  List<Voter> _candidates = const [];
  bool _initialised = false;

  bool _nobodyHome = false;
  String? _contactRelation;
  bool _contactConsent = false;
  bool _contactRefused = false;
  String? _revisitOn;
  String? _error;
  bool _saving = false;
  bool _locating = false;
  LocationAccess? _locationProblem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    final data = FieldScope.of(context).store.data;
    _lead = data.voter(widget.voterId)!;
    _candidates = data.sameHouseCandidates(widget.voterId);
    _initialised = true;
  }

  @override
  void dispose() {
    _remarks.dispose();
    _contactName.dispose();
    _contactMobile.dispose();
    for (final m in _states.values) {
      m.mobile.dispose();
    }
    super.dispose();
  }

  /// The family names someone at the door gives: find each on the list and
  /// count them in this visit, as one household.
  Future<void> _addBySearch() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            PersonSearchScreen(pick: true, exclude: {_lead.id, ..._alsoHere}),
      ),
    );
    if (picked == null || !mounted) return;
    final voter = FieldScope.of(context).store.data.voter(picked);
    if (voter == null) return;
    setState(() {
      if (!_candidates.any((v) => v.id == picked)) {
        _candidates = [..._candidates, voter];
      }
      _alsoHere.add(picked);
      _error = null;
    });
  }

  _MemberState _state(Voter voter) =>
      _states.putIfAbsent(voter.id, () => _MemberState(voter));

  /// The person the visit was opened from, then those confirmed at the door.
  List<_MemberState> get _covered => [
    _state(_lead),
    for (final v in _candidates)
      if (_alsoHere.contains(v.id)) _state(v),
  ];

  String? _validate(AppLocalizations l10n) {
    if (_nobodyHome) {
      return _revisitOn == null ? l10n.errRevisitRequired : null; // R3
    }
    if (_contactName.text.trim().isEmpty) return l10n.errContactName;
    final contactMobile = _contactMobile.text.trim();
    if (contactMobile.isEmpty && !_contactRefused) {
      return l10n.errContactRequired;
    }
    if (contactMobile.isNotEmpty) {
      if (normalizeMobile(contactMobile) == null) {
        return l10n.errMobileInvalid; // R7
      }
      if (!_contactConsent) return l10n.errConsentRequired;
    }
    for (final m in _covered) {
      if (m.outcome == null) return l10n.errOutcomeRequired;
      if (Outcome.needsForm(m.outcome!) && m.formType == null) {
        return l10n.errFormRequired;
      }
      final mobile = m.mobile.text.trim();
      if (mobile.isNotEmpty) {
        if (normalizeMobile(mobile) == null) return l10n.errMobileInvalid;
        if (!m.consent) return l10n.errConsentRequired;
      }
    }
    // Nobody on the list was met: the visit needs a revisit date (R3).
    if (_covered.every((m) => m.outcome == Outcome.notMet) &&
        _revisitOn == null) {
      return l10n.errRevisitRequired;
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
      _locationProblem = null;
      _saving = true;
    });

    // Precise location is required; ask now if it was turned off since sign-in.
    final access = await locationAccess(ask: true);
    if (!mounted) return;
    if (access != LocationAccess.granted) {
      setState(() {
        _locationProblem = access;
        _saving = false;
      });
      return;
    }

    // The fix is taken now, at the door, when save is pressed.
    setState(() => _locating = true);
    final fix = await takePreciseFix();
    if (!mounted) return;
    setState(() => _locating = false);

    final store = FieldScope.of(context).store;
    final contactMobile = normalizeMobile(_contactMobile.text);
    final formIds = await store.saveVisit(
      VisitDraft(
        familyId: _lead.familyId,
        nobodyHome: _nobodyHome,
        metPerson: _nobodyHome ? null : _contactName.text,
        members: [
          for (final m in _covered)
            _nobodyHome
                ? MemberEntry(voterId: m.voter.id, outcome: Outcome.notMet)
                : MemberEntry(
                    voterId: m.voter.id,
                    outcome: m.outcome!,
                    formType:
                        Outcome.needsForm(m.outcome!) && m.formType != 'none'
                        ? m.formType
                        : null,
                    docs: m.outcome == Outcome.notMet
                        ? const []
                        : m.docs.toList(),
                    mobile: m.outcome == Outcome.notMet
                        ? null
                        : normalizeMobile(m.mobile.text),
                    mobileConsent: m.consent,
                    photo: m.photo,
                  ),
        ],
        remarks: _remarks.text,
        revisitOn: _revisitOn,
        gpsLat: fix.lat,
        gpsLng: fix.lng,
        gpsAccuracy: fix.accuracy,
        gpsFlag: fix.flag,
        contactName: _contactName.text,
        contactRelation: _contactRelation,
        contactMobile: contactMobile,
        contactConsent: contactMobile != null && _contactConsent,
        contactRefused: contactMobile == null && _contactRefused,
      ),
    );
    if (!mounted) return;
    final metres = fix.accuracy?.round();
    final message = !fix.hasPosition
        ? l10n.visitSavedNoGps
        : fix.flag == 'GPS_INACCURATE'
        ? l10n.visitSavedRoughGps(metres ?? 0)
        : l10n.visitSavedWithGps(metres ?? 0);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
    final first = today.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: last.isBefore(today) ? today : last,
      initialDate: _revisitOn != null
          ? DateTime.parse(_revisitOn!)
          : (first.isAfter(last) ? today : first),
    );
    if (picked != null) setState(() => _revisitOn = dayOf(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = FieldScope.of(context).store.data;
    final family = data.family(_lead.familyId);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.visitTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(_lead.nameHi, style: theme.textTheme.titleMedium),
          if (family?.houseNo != null && family!.houseNo!.isNotEmpty)
            Text(l10n.houseNo(family.houseNo!), style: muted),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.my_location,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.visitLocationNote,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
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
          SectionTitle(l10n.visitSameHouse),
          if (_candidates.isEmpty)
            Text(l10n.visitNoSuggestions, style: muted)
          else ...[
            Text(l10n.visitSameHouseHint, style: muted),
            const SizedBox(height: 4),
            for (final v in _candidates)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _alsoHere.contains(v.id),
                onChanged: (on) => setState(() {
                  on == true ? _alsoHere.add(v.id) : _alsoHere.remove(v.id);
                  _error = null;
                }),
                title: Text(v.nameHi),
                subtitle: Text(
                  [
                    if (v.relativeNameHi != null)
                      '${relationLabel(l10n, v.relationType)}: ${v.relativeNameHi}',
                    if (v.age != null) l10n.ageYears(v.age!),
                  ].join(' · '),
                ),
              ),
          ],
          const SizedBox(height: 6),
          Text(l10n.visitAddBySearchHint, style: muted),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _addBySearch,
            icon: const Icon(Icons.person_search_outlined),
            label: Text(l10n.visitAddBySearch),
          ),
          if (!_nobodyHome) ...[
            SectionTitle(l10n.contactTitle),
            TextField(
              controller: _contactName,
              decoration: InputDecoration(labelText: l10n.contactName),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.contactRelation,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final code in ContactRelation.all)
                  ChoiceChip(
                    label: Text(contactRelationLabel(l10n, code)),
                    selected: _contactRelation == code,
                    onSelected: (s) =>
                        setState(() => _contactRelation = s ? code : null),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactMobile,
              enabled: !_contactRefused,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: l10n.contactMobile,
                prefixText: '+91 ',
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_contactMobile.text.isNotEmpty && !_contactRefused)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _contactConsent,
                onChanged: (v) => setState(() {
                  _contactConsent = v ?? false;
                  _error = null;
                }),
                title: Text(l10n.visitConsentLabel),
                subtitle: Text('“${l10n.visitConsent}”'),
              ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _contactRefused,
              onChanged: (v) => setState(() {
                _contactRefused = v ?? false;
                if (_contactRefused) {
                  _contactMobile.clear();
                  _contactConsent = false;
                }
                _error = null;
              }),
              title: Text(l10n.contactRefused),
            ),
            SectionTitle(l10n.visitMembers),
            for (final m in _covered) ...[
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
          if (_locationProblem != null) ...[
            const SizedBox(height: 8),
            LocationProblem(
              access: _locationProblem!,
              onAsk: _save,
              onRecheck: _save,
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _locating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_locating ? l10n.visitLocating : l10n.save),
          ),
        ],
      ),
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
              // Right after the form is chosen: the applicant's face photo.
              if (m.formType == '6' || m.formType == '8') ...[
                const SizedBox(height: 10),
                FacePhotoField(
                  photo: m.photo,
                  onChanged: (bytes) => _update(() => m.photo = bytes),
                ),
              ],
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
                  labelText: l10n.memberMobile,
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
