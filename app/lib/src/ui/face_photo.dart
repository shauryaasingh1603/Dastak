import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Lets the volunteer take a photo or pick an image (such as a screenshot
/// from the ECI website) and returns it, or null if they cancelled.
/// Replaced in tests.
typedef PhotoTaker = Future<Uint8List?> Function();

Future<Uint8List?> takeWithCamera() async {
  final file = await ImagePicker().pickImage(
    // In the browser this opens the phone's own chooser: camera, photos or
    // files, so one button covers a new photo and an ECI screenshot.
    source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
    // Large enough to read an ECI screenshot, still light on data
    // (about 100–300 KB).
    maxWidth: 1280,
    maxHeight: 1600,
    imageQuality: 75,
  );
  return file?.readAsBytes();
}

/// "चेहरे की फ़ोटो": shown once a form is chosen. Take, retake or remove the
/// applicant's face photo; [photo] is what has been taken so far.
class FacePhotoField extends StatelessWidget {
  const FacePhotoField({
    super.key,
    required this.photo,
    required this.onChanged,
    this.onServer = false,
  });

  final Uint8List? photo;
  final ValueChanged<Uint8List?> onChanged;

  /// The server already has a photo for this form (none on the phone).
  final bool onServer;

  static PhotoTaker take = takeWithCamera;

  Future<void> _take(BuildContext context) async {
    try {
      final bytes = await take();
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
    final bytes = photo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.photoTitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(l10n.photoHint, style: muted),
        const SizedBox(height: 6),
        if (bytes != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  bytes,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  semanticLabel: l10n.photoTitle,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 88,
                    height: 88,
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
                      onPressed: () => _take(context),
                      icon: const Icon(Icons.camera_alt_outlined),
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
          if (onServer)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF1F7A4D),
                  ),
                  const SizedBox(width: 6),
                  Text(l10n.photoOnServer),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => _take(context),
            icon: const Icon(Icons.photo_camera_front_outlined),
            label: Text(onServer ? l10n.photoRetake : l10n.photoTake),
          ),
        ],
      ],
    );
  }
}
