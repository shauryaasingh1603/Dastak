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

String? reasonLabel(AppLocalizations l10n, Voter voter) {
  if (voter.sourceList == 'POSS_DEL') return l10n.reasonPossDel;
  return switch (voter.asddReason) {
    'SHIFTED' => l10n.reasonShifted,
    'UNTRACEABLE' => l10n.reasonUntraceable,
    _ => null,
  };
}

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
