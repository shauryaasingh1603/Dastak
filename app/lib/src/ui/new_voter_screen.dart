import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart' show normalizeMobile;
import '../data/field_store.dart';
import '../data/models.dart';
import 'eci_shot.dart';
import 'face_photo.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'widgets.dart';

/// "नया मतदाता जोड़ें": someone who is not on the list, such as a person who
/// turned 18 this year. Opened from a listed person ([familyId]: the same
/// household), or on its own, when nobody at the house is on the list: then
/// the volunteer picks the booth ([partNo] preselects it) and house number,
/// and a new household record is made.
class NewVoterScreen extends StatefulWidget {
  const NewVoterScreen({super.key, this.familyId, this.partNo});

  final String? familyId;
  final int? partNo;

  @override
  State<NewVoterScreen> createState() => _NewVoterScreenState();
}

class _NewVoterScreenState extends State<NewVoterScreen> {
  final _name = TextEditingController();
  final _relative = TextEditingController();
  final _age = TextEditingController();
  final _epic = TextEditingController();
  final _mobile = TextEditingController();
  final _house = TextEditingController();
  final _reasonNote = TextEditingController();
  String? _reason;
  int? _part;
  Uint8List? _photo;
  Uint8List? _eci;
  bool _consent = false;
  String _relation = 'F';
  String? _gender;
  String _formType = '6';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _relative,
      _age,
      _epic,
      _mobile,
      _house,
      _reasonNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _ageValue => int.tryParse(_age.text.trim());

  bool get _newHousehold => widget.familyId == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_part == null && _newHousehold) {
      final booths = FieldScope.of(context).store.data.booths;
      _part =
          widget.partNo ?? (booths.length == 1 ? booths.single.partNo : null);
    }
  }

  void _chooseReason(String reason) => setState(() {
    _reason = reason;
    _error = null;
    // Someone who turned 18 this year is 18 (17 if the birthday is still
    // to come before 1 January) and needs Form 6.
    if (reason == NewReason.turned18) {
      if (_age.text.trim().isEmpty) _age.text = '18';
      _formType = '6';
    }
  });

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final age = _ageValue;
    final String? error = _reason == null
        ? l10n.errNewReason
        : _newHousehold && _part == null
        ? '${l10n.newVoterBooth}: ${l10n.errRequired}'
        : _newHousehold && _house.text.trim().isEmpty
        ? l10n.errNewVoterHouse
        : _name.text.trim().isEmpty
        ? '${l10n.fieldName}: ${l10n.errRequired}'
        : _relative.text.trim().isEmpty
        ? '${l10n.fieldRelativeName}: ${l10n.errRequired}'
        : age == null || age < 1 || age > 120
        ? l10n.errAge
        : _reason == NewReason.turned18 && (age < 17 || age > 18)
        ? l10n.errTurned18Age
        : _gender == null
        ? '${l10n.fieldGender}: ${l10n.errRequired}'
        : _mobile.text.isNotEmpty && normalizeMobile(_mobile.text) == null
        ? l10n
              .errMobileInvalid // R7
        : _mobile.text.isNotEmpty && !_consent
        ? l10n.errConsentRequired
        // Form 6 is filed in the ECI app; its screenshot is the proof.
        : _formType == '6' && _eci == null
        ? l10n.errEciRequired
        : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    final formId = await FieldScope.of(context).store.addVoter(
      NewVoterDraft(
        familyId: widget.familyId,
        household: _newHousehold
            ? NewHousehold(partNo: _part!, houseNo: _house.text)
            : null,
        newReason: _reason,
        newReasonNote: _reason == NewReason.other ? _reasonNote.text : null,
        photo: _formType == 'none' ? null : _photo,
        eci: _formType == 'none' ? null : _eci,
        nameHi: _name.text,
        relationType: _relation,
        relativeNameHi: _relative.text,
        age: age!,
        gender: _gender!,
        epic: _epic.text,
        formType: _formType == 'none' ? null : _formType,
        mobile: normalizeMobile(_mobile.text),
        mobileConsent: _consent,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.newVoterSaved)));
    if (formId == null || _formType == '6') {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => FormDetailScreen(formId: formId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final age = _ageValue;
    final booths = FieldScope.of(context).store.data.booths;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newVoterTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionTitle(l10n.newVoterReason),
          Wrap(
            spacing: 8,
            children: [
              for (final (code, label) in [
                (NewReason.turned18, l10n.newReasonTurned18),
                (NewReason.other, l10n.newReasonOther),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _reason == code,
                  onSelected: (_) => _chooseReason(code),
                ),
            ],
          ),
          if (_reason == NewReason.other) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _reasonNote,
              maxLength: 200,
              decoration: InputDecoration(labelText: l10n.newReasonNote),
            ),
          ],
          if (_newHousehold) ...[
            SectionTitle(l10n.newVoterBooth),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final b in booths)
                  ChoiceChip(
                    label: Text(l10n.boothNumber(b.partNo)),
                    selected: _part == b.partNo,
                    onSelected: (_) => setState(() {
                      _part = b.partNo;
                      _error = null;
                    }),
                  ),
              ],
            ),
            SectionTitle(l10n.newVoterHouse),
            TextField(
              controller: _house,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.newVoterHouseHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          SectionTitle(l10n.fieldName),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
          ),
          SectionTitle(l10n.fieldRelation),
          Wrap(
            spacing: 8,
            children: [
              for (final r in ['F', 'H', 'M', 'O'])
                ChoiceChip(
                  label: Text(relationLabel(l10n, r)),
                  selected: _relation == r,
                  onSelected: (_) => setState(() => _relation = r),
                ),
            ],
          ),
          SectionTitle(l10n.fieldRelativeName),
          TextField(controller: _relative),
          SectionTitle(l10n.fieldAge),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onChanged: (_) => setState(() {}),
          ),
          SectionTitle(l10n.fieldGender),
          Wrap(
            spacing: 8,
            children: [
              for (final g in ['M', 'F', 'O'])
                ChoiceChip(
                  label: Text(genderLabel(l10n, g)),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                ),
            ],
          ),
          SectionTitle(l10n.fieldEpic),
          TextField(
            controller: _epic,
            textCapitalization: TextCapitalization.characters,
          ),
          SectionTitle(l10n.visitMobile),
          TextField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(prefixText: '+91 '),
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
          SectionTitle(l10n.visitWhichForm),
          Wrap(
            spacing: 8,
            children: [
              for (final t in ['6', '8', 'none'])
                ChoiceChip(
                  label: Text(t == 'none' ? l10n.formNone : l10n.formType(t)),
                  selected: _formType == t,
                  onSelected: (_) async {
                    setState(() {
                      _formType = t;
                      _error = null;
                    });
                    if (t == '6') await showEciReminder(context);
                  },
                ),
            ],
          ),
          if (_formType != 'none') ...[
            const SizedBox(height: 12),
            EciShotField(
              shot: _eci,
              onChanged: (bytes) => setState(() {
                _eci = bytes;
                _error = null;
              }),
            ),
            const SizedBox(height: 12),
            FacePhotoField(
              photo: _photo,
              onChanged: (bytes) => setState(() => _photo = bytes),
            ),
          ],
          // R9: a warning, not a block.
          if (_formType == '6' && age != null && age < 18) ...[
            const SizedBox(height: 8),
            InfoBanner(icon: Icons.warning_amber, text: l10n.ageUnder18),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            InfoBanner(icon: Icons.error_outline, text: _error!, error: true),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.person_add_alt),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
