import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart' show normalizeMobile;
import '../data/field_store.dart';
import '../data/models.dart';
import '../location.dart';
import 'dates.dart';
import 'eci_shot.dart';
import 'face_photo.dart';
import 'field_scope.dart';
import 'labels.dart';
import 'location_gate.dart';
import 'widgets.dart';

/// The three things that can happen at the door.
enum VisitChoice { notMet, form6, other }

/// "भेंट दर्ज करें": one visit to one listed person, in three choices:
///
/// * कोई नहीं मिला: pick when to come back.
/// * नाम कट गया है, फ़ॉर्म 6 भरना है: the volunteer files Form 6 in the ECI
///   app first (a reminder says so), then adds the screenshot of its "Track
///   application status" page, which is required. The server reads the
///   reference number from it.
/// * अन्य कारण: what it was, in a few taps or in words.
///
/// Saves on the phone at once, with the location taken when save is pressed.
class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key, required this.voterId});

  final String voterId;

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _reason = TextEditingController();
  final _mobile = TextEditingController();

  VisitChoice? _choice;
  String _revisitOn = Ist.addDays(Ist.today(), 1);
  String? _otherOutcome; // an Outcome code, for "अन्य कारण"
  Uint8List? _eci;
  Uint8List? _photo;
  bool _consent = false;

  String? _error;
  bool _saving = false;
  bool _locating = false;
  LocationAccess? _locationProblem;

  @override
  void dispose() {
    _reason.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _choose(VisitChoice choice) async {
    setState(() {
      _choice = choice;
      _error = null;
    });
    // Form 6 is filed in the ECI app first: say so every time.
    if (choice == VisitChoice.form6) await showEciReminder(context);
  }

  String? _validate(AppLocalizations l10n) {
    switch (_choice) {
      case null:
        return l10n.errChooseOption;
      case VisitChoice.notMet:
        return null;
      case VisitChoice.form6:
        if (_eci == null) return l10n.errEciRequired;
        final mobile = _mobile.text.trim();
        if (mobile.isNotEmpty) {
          if (normalizeMobile(mobile) == null) return l10n.errMobileInvalid;
          if (!_consent) return l10n.errConsentRequired;
        }
        return null;
      case VisitChoice.other:
        if (_otherOutcome == null) return l10n.errOtherReason;
        if (_otherOutcome == Outcome.other && _reason.text.trim().isEmpty) {
          return l10n.errOtherReason;
        }
        return null;
    }
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
    final voter = store.data.voter(widget.voterId)!;
    final choice = _choice!;
    final mobile = choice == VisitChoice.form6
        ? normalizeMobile(_mobile.text)
        : null;
    final MemberEntry member = switch (choice) {
      VisitChoice.notMet => MemberEntry(
        voterId: voter.id,
        outcome: Outcome.notMet,
      ),
      VisitChoice.form6 => MemberEntry(
        voterId: voter.id,
        outcome: Outcome.eligible,
        formType: '6',
        mobile: mobile,
        mobileConsent: mobile != null && _consent,
        photo: _photo,
        eci: _eci,
      ),
      VisitChoice.other => MemberEntry(
        voterId: voter.id,
        outcome: _otherOutcome!,
      ),
    };
    await store.saveVisit(
      VisitDraft(
        familyId: voter.familyId,
        nobodyHome: choice == VisitChoice.notMet,
        members: [member],
        remarks: choice == VisitChoice.other ? _reason.text : null,
        revisitOn: choice == VisitChoice.notMet ? _revisitOn : null,
        gpsLat: fix.lat,
        gpsLng: fix.lng,
        gpsAccuracy: fix.accuracy,
        gpsFlag: fix.flag,
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = FieldScope.of(context).store.data;
    final voter = data.voter(widget.voterId)!;
    final family = data.family(voter.familyId);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.visitAdd)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(voter.nameHi, style: theme.textTheme.titleMedium),
          Text(
            [
              if (voter.relativeNameHi != null)
                '${relationLabel(l10n, voter.relationType)}: ${voter.relativeNameHi}',
              if (voter.age != null) l10n.ageYears(voter.age!),
              if (family?.houseNo != null && family!.houseNo!.isNotEmpty)
                l10n.houseNo(family.houseNo!),
            ].join(' · '),
            style: muted,
          ),
          SectionTitle(l10n.visitChoose),
          _ChoiceCard(
            icon: Icons.person_off_outlined,
            color: const Color(0xFFB4441F),
            title: l10n.visitNobodyHome,
            hint: l10n.visitOptNotMetHint,
            selected: _choice == VisitChoice.notMet,
            onTap: () => _choose(VisitChoice.notMet),
          ),
          _ChoiceCard(
            icon: Icons.how_to_reg,
            color: const Color(0xFF1F7A4D),
            title: l10n.visitOptForm6,
            hint: l10n.visitOptForm6Hint,
            selected: _choice == VisitChoice.form6,
            onTap: () => _choose(VisitChoice.form6),
          ),
          _ChoiceCard(
            icon: Icons.notes,
            color: const Color(0xFF5F5F5F),
            title: l10n.visitOptOther,
            hint: l10n.visitOptOtherHint,
            selected: _choice == VisitChoice.other,
            onTap: () => _choose(VisitChoice.other),
          ),

          if (_choice == VisitChoice.notMet) ...[
            SectionTitle(l10n.visitRevisit),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (days, text) in [
                  (1, l10n.revisitTomorrow),
                  (2, l10n.revisitDayAfter),
                  (3, l10n.revisitIn3Days),
                ])
                  () {
                    final day = Ist.addDays(Ist.today(), days);
                    return ChoiceChip(
                      label: Text('$text (${formatDay(day)})'),
                      selected: _revisitOn == day,
                      onSelected: (_) => setState(() => _revisitOn = day),
                    );
                  }(),
              ],
            ),
          ],

          if (_choice == VisitChoice.form6) ...[
            const SizedBox(height: 12),
            if (data.hasOpenForm(voter.id, '6'))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InfoBanner(
                  icon: Icons.info_outline,
                  text: l10n.form6AlreadyOpen,
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EciShotField(
                      shot: _eci,
                      onChanged: (bytes) => setState(() {
                        _eci = bytes;
                        _error = null;
                      }),
                    ),
                    const Divider(height: 28),
                    FacePhotoField(
                      photo: _photo,
                      onChanged: (bytes) => setState(() => _photo = bytes),
                    ),
                    const Divider(height: 28),
                    TextField(
                      controller: _mobile,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.visitMobile,
                        prefixText: '+91 ',
                      ),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    if (_mobile.text.isNotEmpty)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _consent,
                        onChanged: (v) => setState(() {
                          _consent = v ?? false;
                          _error = null;
                        }),
                        title: Text(l10n.visitConsentLabel),
                        subtitle: Text('“${l10n.visitConsent}”'),
                      ),
                  ],
                ),
              ),
            ),
            // R9: Form 6 needs age 18 on 1 Jan 2027. A warning only.
            if (voter.age != null && voter.age! < 18)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: InfoBanner(
                  icon: Icons.warning_amber,
                  text: l10n.ageUnder18,
                ),
              ),
          ],

          if (_choice == VisitChoice.other) ...[
            SectionTitle(l10n.otherWhat),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (code, text) in [
                  (Outcome.alreadyOnRoll, l10n.otherOnRoll),
                  (Outcome.dead, l10n.otherDead),
                  (Outcome.shifted, l10n.otherShifted),
                  (Outcome.other, l10n.otherSomething),
                ])
                  ChoiceChip(
                    label: Text(text),
                    selected: _otherOutcome == code,
                    onSelected: (_) => setState(() {
                      _otherOutcome = code;
                      _error = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reason,
              maxLines: 2,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: _otherOutcome == Outcome.other
                    ? l10n.otherReason
                    : l10n.otherReasonOptional,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.my_location,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.visitLocationNote, style: muted)),
            ],
          ),
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

/// One of the three big choices.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? color : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      color: selected ? color.withValues(alpha: 0.08) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      hint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? color : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
