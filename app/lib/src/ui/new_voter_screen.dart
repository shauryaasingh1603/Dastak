import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart' show normalizeMobile;
import '../data/field_store.dart';
import 'field_scope.dart';
import 'form_detail_screen.dart';
import 'labels.dart';
import 'widgets.dart';

/// "नया मतदाता जोड़ें": someone at the house who is not on the list.
class NewVoterScreen extends StatefulWidget {
  const NewVoterScreen({super.key, required this.familyId});

  final String familyId;

  @override
  State<NewVoterScreen> createState() => _NewVoterScreenState();
}

class _NewVoterScreenState extends State<NewVoterScreen> {
  final _name = TextEditingController();
  final _relative = TextEditingController();
  final _age = TextEditingController();
  final _epic = TextEditingController();
  final _mobile = TextEditingController();
  bool _consent = false;
  String _relation = 'F';
  String? _gender;
  String _formType = '6';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _relative, _age, _epic, _mobile]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _ageValue => int.tryParse(_age.text.trim());

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final age = _ageValue;
    final String? error = _name.text.trim().isEmpty
        ? '${l10n.fieldName}: ${l10n.errRequired}'
        : _relative.text.trim().isEmpty
        ? '${l10n.fieldRelativeName}: ${l10n.errRequired}'
        : age == null || age < 1 || age > 120
        ? l10n.errAge
        : _gender == null
        ? '${l10n.fieldGender}: ${l10n.errRequired}'
        : _mobile.text.isNotEmpty && normalizeMobile(_mobile.text) == null
        ? l10n
              .errMobileInvalid // R7
        : _mobile.text.isNotEmpty && !_consent
        ? l10n.errConsentRequired
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
    if (formId == null) {
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newVoterTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
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
                  onSelected: (_) => setState(() => _formType = t),
                ),
            ],
          ),
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
