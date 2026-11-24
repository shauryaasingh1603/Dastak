import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'face_photo.dart' show PhotoTaker;

/// The blurred example of the ECI "Track application status" page.
const eciExampleAsset = 'assets/images/eci_example.jpg';

/// Picks a screenshot from the phone's photos.
Future<Uint8List?> pickScreenshot() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    // Large enough to read every character of the reference number.
    maxWidth: 1280,
    maxHeight: 2400,
    imageQuality: 80,
  );
  return file?.readAsBytes();
}

/// "पहले ECI ऐप में फ़ॉर्म 6 भरें": shown when Form 6 is chosen, before the
/// volunteer goes on.
Future<void> showEciReminder(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.assignment_late_outlined, size: 32),
      title: Text(l10n.eciReminderTitle),
      content: SingleChildScrollView(child: Text(l10n.eciReminderBody)),
      actions: [
        TextButton(
          onPressed: () => showEciExample(context),
          child: Text(l10n.eciExample),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.eciReminderOk),
        ),
      ],
    ),
  );
}

/// The example screenshot, with the reference number and name hidden.
Future<void> showEciExample(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.eciExampleTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.eciExampleNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  eciExampleAsset,
                  fit: BoxFit.contain,
                  semanticLabel: l10n.eciExampleTitle,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.eciReminderOk),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// "ECI स्क्रीनशॉट (ज़रूरी)": add, change or remove the screenshot of the
/// ECI application; [shot] is what has been added on this phone so far.
class EciShotField extends StatelessWidget {
  const EciShotField({
    super.key,
    required this.shot,
    required this.onChanged,
    this.onServer = false,
    this.status,
    this.referenceNo,
  });

  final Uint8List? shot;
  final ValueChanged<Uint8List?> onChanged;

  /// The server already has a screenshot for this form, and how far it has
  /// been read ([EciStatus]) with the reference number it shows.
  final bool onServer;
  final String? status;
  final String? referenceNo;

  static PhotoTaker pick = pickScreenshot;

  Future<void> _pick(BuildContext context) async {
    try {
      final bytes = await pick();
      if (bytes != null && bytes.isNotEmpty) onChanged(bytes);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).photoFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final bytes = shot;

    final reading = !onServer || bytes != null
        ? null
        : switch (status) {
            EciStatus.read => (
              Icons.check_circle,
              const Color(0xFF1F7A4D),
              l10n.eciReadOk(referenceNo ?? ''),
            ),
            EciStatus.failed => (
              Icons.error_outline,
              const Color(0xFFB4441F),
              l10n.eciReadFailed,
            ),
            EciStatus.notEci => (
              Icons.error_outline,
              const Color(0xFFB4441F),
              l10n.eciNotEci,
            ),
            _ => (
              Icons.check_circle,
              const Color(0xFF1F7A4D),
              l10n.eciOnServer,
            ),
          };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eciTitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(l10n.eciHint, style: muted),
        const SizedBox(height: 6),
        if (bytes != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  bytes,
                  width: 72,
                  height: 120,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  semanticLabel: l10n.eciTitle,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 72,
                    height: 120,
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _pick(context),
                      icon: const Icon(Icons.screenshot_outlined),
                      label: Text(l10n.photoRetake),
                    ),
                    TextButton(
                      onPressed: () => onChanged(null),
                      child: Text(l10n.photoRemove),
                    ),
                  ],
                ),
              ),
            ],
          )
        else ...[
          if (reading != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(reading.$1, size: 18, color: reading.$2),
                  const SizedBox(width: 6),
                  Expanded(child: Text(reading.$3)),
                ],
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _pick(context),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(onServer ? l10n.photoRetake : l10n.eciAdd),
              ),
              TextButton(
                onPressed: () => showEciExample(context),
                child: Text(l10n.eciExample),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
