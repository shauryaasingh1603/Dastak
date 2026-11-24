import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';

/// Hindi label, icon and colour for each stored code. Every outcome chip gets
/// an icon and a colour as well as a word, for low-literacy users.
class CodeLabel {
  const CodeLabel(this.text, this.icon, this.color);
  final String text;
  final IconData icon;
  final Color color;
}

CodeLabel outcomeLabel(AppLocalizations l10n, String code) => switch (code) {
  Outcome.eligible => CodeLabel(
    l10n.outcomeEligible,
    Icons.how_to_reg,
    const Color(0xFF1F7A4D),
  ),
  Outcome.correction => CodeLabel(
    l10n.outcomeCorrection,
    Icons.edit_note,
    const Color(0xFF8A5A00),
  ),
  Outcome.movedIn => CodeLabel(
    l10n.outcomeMovedIn,
    Icons.home_outlined,
    const Color(0xFF0F6E77),
  ),
  Outcome.shifted => CodeLabel(
    l10n.outcomeShifted,
    Icons.moving,
    const Color(0xFF5B4FA8),
  ),
  Outcome.dead => CodeLabel(
    l10n.outcomeDead,
    Icons.remove_circle_outline,
    const Color(0xFF5F5F5F),
  ),
  Outcome.notMet => CodeLabel(
    l10n.outcomeNotMet,
    Icons.person_off_outlined,
    const Color(0xFFB4441F),
  ),
  Outcome.alreadyOnRoll => CodeLabel(
    l10n.outcomeOnRoll,
    Icons.verified_outlined,
    const Color(0xFF1E5AA8),
  ),
  Outcome.other => CodeLabel(
    l10n.outcomeOther,
    Icons.notes,
    const Color(0xFF5F5F5F),
  ),
  _ => CodeLabel(code, Icons.help_outline, const Color(0xFF5F5F5F)),
};

CodeLabel formStatusLabel(AppLocalizations l10n, String code) => switch (code) {
  FormStatus.filled => CodeLabel(
    l10n.formStatusFilled,
    Icons.edit_document,
    const Color(0xFF8A5A00),
  ),
  FormStatus.submitted => CodeLabel(
    l10n.formStatusSubmitted,
    Icons.outbox_outlined,
    const Color(0xFF1E5AA8),
  ),
  FormStatus.inEroList => CodeLabel(
    l10n.formStatusInEro,
    Icons.list_alt,
    const Color(0xFF5B4FA8),
  ),
  FormStatus.accepted => CodeLabel(
    l10n.formStatusAccepted,
    Icons.check_circle_outline,
    const Color(0xFF1F7A4D),
  ),
  FormStatus.rejected => CodeLabel(
    l10n.formStatusRejected,
    Icons.cancel_outlined,
    const Color(0xFFA3262A),
  ),
  FormStatus.hearing => CodeLabel(
    l10n.formStatusHearing,
    Icons.gavel,
    const Color(0xFFB4441F),
  ),
  _ => CodeLabel(code, Icons.help_outline, const Color(0xFF5F5F5F)),
};

String routeLabel(AppLocalizations l10n, String code) => switch (code) {
  SubmitRoute.bla2 => l10n.routeBla2,
  SubmitRoute.self => l10n.routeSelf,
  SubmitRoute.online => l10n.routeOnline,
  _ => code,
};

String docLabel(AppLocalizations l10n, String code) => switch (code) {
  'AADHAAR' => l10n.docAadhaar,
  'BIRTH_CERT' => l10n.docBirthCert,
  'HIGHSCHOOL' => l10n.docHighschool,
  'RATION' => l10n.docRation,
  'ELECTRICITY' => l10n.docElectricity,
  _ => l10n.docOther,
};

String relationLabel(AppLocalizations l10n, String? code) => switch (code) {
  'F' => l10n.relationF,
  'H' => l10n.relationH,
  'M' => l10n.relationM,
  _ => l10n.relationO,
};

String genderLabel(AppLocalizations l10n, String? code) => switch (code) {
  'M' => l10n.genderM,
  'F' => l10n.genderF,
  _ => l10n.genderO,
};

/// Why the person is on the list (the workbook's category).
CodeLabel categoryLabel(AppLocalizations l10n, String code) => switch (code) {
  VoterCategory.untraceable => CodeLabel(
    l10n.catUntraceable,
    Icons.person_search_outlined,
    const Color(0xFF1C5CAB),
  ),
  VoterCategory.shifted => CodeLabel(
    l10n.catShifted,
    Icons.home_work_outlined,
    const Color(0xFF8A5A00),
  ),
  VoterCategory.deceased => CodeLabel(
    l10n.catDeceased,
    Icons.do_not_disturb_on_outlined,
    const Color(0xFF52514E),
  ),
  VoterCategory.duplicate => CodeLabel(
    l10n.catDuplicate,
    Icons.content_copy_outlined,
    const Color(0xFF6B4FA0),
  ),
  VoterCategory.alreadyBack => CodeLabel(
    l10n.catAlreadyBack,
    Icons.verified_outlined,
    const Color(0xFF1F7A4D),
  ),
  VoterCategory.onDraftRoll => CodeLabel(
    l10n.catOnDraftRoll,
    Icons.how_to_reg_outlined,
    const Color(0xFF1F7A4D),
  ),
  VoterCategory.possHigh => CodeLabel(
    l10n.catPossHigh,
    Icons.report_outlined,
    const Color(0xFFA3262A),
  ),
  VoterCategory.possMedium => CodeLabel(
    l10n.catPossMedium,
    Icons.help_outline,
    const Color(0xFFB4441F),
  ),
  VoterCategory.possLow => CodeLabel(
    l10n.catPossLow,
    Icons.fact_check_outlined,
    const Color(0xFF0F6E77),
  ),
  _ => CodeLabel(
    l10n.catAdded,
    Icons.fiber_new_outlined,
    const Color(0xFF0F6E77),
  ),
};

/// What the category means for the volunteer at the door.
String categoryHint(AppLocalizations l10n, String code) => switch (code) {
  VoterCategory.untraceable => l10n.catHintUntraceable,
  VoterCategory.shifted => l10n.catHintShifted,
  VoterCategory.deceased => l10n.catHintDeceased,
  VoterCategory.duplicate => l10n.catHintDuplicate,
  VoterCategory.alreadyBack => l10n.catHintAlreadyBack,
  VoterCategory.onDraftRoll => l10n.catHintOnDraftRoll,
  VoterCategory.possHigh => l10n.catHintPossHigh,
  VoterCategory.possMedium => l10n.catHintPossMedium,
  VoterCategory.possLow => l10n.catHintPossLow,
  _ => l10n.catHintAdded,
};

CodeLabel familyStatusLabel(AppLocalizations l10n, FamilyStatus status) =>
    switch (status) {
      FamilyStatus.pending => CodeLabel(
        l10n.statusPending,
        Icons.radio_button_unchecked,
        const Color(0xFF6B6860),
      ),
      FamilyStatus.done => CodeLabel(
        l10n.statusDone,
        Icons.check_circle,
        const Color(0xFF1F7A4D),
      ),
      FamilyStatus.revisit => CodeLabel(
        l10n.statusRevisit,
        Icons.replay,
        const Color(0xFFB4441F),
      ),
    };

String contactRelationLabel(AppLocalizations l10n, String code) =>
    switch (code) {
      'FATHER' => l10n.relFather,
      'MOTHER' => l10n.relMother,
      'HUSBAND' => l10n.relHusband,
      'WIFE' => l10n.relWife,
      'SON' => l10n.relSon,
      'DAUGHTER' => l10n.relDaughter,
      'SIBLING' => l10n.relSibling,
      'SELF' => l10n.relSelf,
      _ => l10n.relOther,
    };

String entityLabel(AppLocalizations l10n, String entity) => switch (entity) {
  'visit' => l10n.entityVisit,
  'form' => l10n.entityForm,
  'form_event' => l10n.entityFormEvent,
  'voter' => l10n.entityVoter,
  _ => entity,
};

/// A small rounded tag with an icon.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.dense = false});

  final CodeLabel label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: label.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(label.icon, size: dense ? 14 : 16, color: label.color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label.text,
              style: style?.copyWith(
                color: label.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
