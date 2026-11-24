import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../data/models.dart';
import 'dates.dart';
import 'eci_shot.dart';
import 'face_photo.dart';
import 'field_scope.dart';
import 'labels.dart';
import 'widgets.dart';

/// "फॉर्म विवरण": how a claim form was submitted, its receipt number, and its
/// status history.
class FormDetailScreen extends StatefulWidget {
  const FormDetailScreen({super.key, required this.formId});

  final String formId;

  @override
  State<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailScreen> {
  final _reference = TextEditingController();
  String? _route;
  String? _filedOn;
  String? _error;
  bool _busy = false;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    final form = FieldScope.of(context).store.data.form(widget.formId);
    if (form != null) {
      _route = form.route;
      _reference.text = form.referenceNo ?? '';
      _filedOn = form.filedOn ?? Ist.today();
    }
    _initialised = true;
  }

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  bool _changed(ClaimForm form) =>
      _route != form.route ||
      _reference.text.trim() != (form.referenceNo ?? '') ||
      _filedOn != form.filedOn;

  Future<void> _saveDetails({bool quiet = false}) async {
    final scope = FieldScope.of(context);
    final l10n = AppLocalizations.of(context);
    await scope.store.updateForm(
      widget.formId,
      route: _route,
      referenceNo: _reference.text,
      filedOn: _filedOn,
    );
    if (!quiet && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.formSaved)));
    }
  }

  /// Why the form cannot be marked submitted yet, or null if it can.
  String? _submitBlock(AppLocalizations l10n) {
    final scope = FieldScope.of(context);
    if (_route == null) return l10n.errRouteRequired;
    if (_reference.text.trim().isEmpty) return l10n.errReceiptRequired; // R1
    if (_route == SubmitRoute.bla2) {
      if (!scope.profile.isBla2) return l10n.formBla2Only;
      final settings = scope.store.data.settings;
      final count = scope.store.bla2Count(); // R2
      if (count.today >= settings.bla2DailyLimit) {
        return l10n.formQuotaDailyFull;
      }
      if (count.total >= settings.bla2TotalLimit) {
        return l10n.formQuotaTotalFull;
      }
    }
    return null;
  }

  Future<void> _submit(ClaimForm form) async {
    final l10n = AppLocalizations.of(context);
    final block = _submitBlock(l10n);
    if (block != null) {
      setState(() => _error = block);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    final store = FieldScope.of(context).store;
    if (_changed(form)) await _saveDetails(quiet: true);
    await store.markSubmitted(widget.formId);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.formSubmittedSaved)));
  }

  Future<void> _pickFiledOn() async {
    final today = DateTime.parse(Ist.today());
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2026, 11, 1),
      lastDate: today,
      initialDate: _filedOn != null ? DateTime.parse(_filedOn!) : today,
    );
    if (picked != null) setState(() => _filedOn = dayOf(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scope = FieldScope.of(context);

    return ListenableBuilder(
      listenable: scope.store,
      builder: (context, _) {
        final data = scope.store.data;
        final form = data.form(widget.formId);
        if (form == null) {
          return Scaffold(appBar: AppBar(title: Text(l10n.formTitle)));
        }
        final voter = data.voter(form.voterId);
        final family = voter == null ? null : data.family(voter.familyId);
        final editable = form.status == FormStatus.filled;
        final settings = data.settings;
        final count = scope.store.bla2Count();
        final nearLimit =
            scope.profile.isBla2 &&
            _route == SubmitRoute.bla2 &&
            (count.today >= settings.bla2DailyLimit - 2 ||
                count.total >= settings.bla2TotalLimit - 5);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.formTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.formOf(voter?.nameHi ?? '—', form.formType),
                        style: theme.textTheme.titleLarge,
                      ),
                      if (family != null)
                        Text(
                          [
                            if (family.houseNo != null)
                              l10n.houseNo(family.houseNo!),
                            l10n.boothNumber(family.partNo),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Pill(label: formStatusLabel(l10n, form.status)),
                    ],
                  ),
                ),
              ),
              if (form.byMe) ...[
                const SizedBox(height: 12),
                _PhotoCard(
                  form: form,
                  kind: PhotoKind.eci,
                  // Reloads the preview when a screenshot is added or sent.
                  key: ValueKey(
                    'eci${data.localEci.contains(form.id)}${form.hasEci}'
                    '${form.eciStatus}',
                  ),
                ),
                const SizedBox(height: 12),
                _PhotoCard(
                  form: form,
                  kind: PhotoKind.face,
                  // Reloads the preview when a photo is taken or sent.
                  key: ValueKey(
                    'face${data.localPhotos.contains(form.id)}${form.hasPhoto}',
                  ),
                ),
              ],
              if (scope.profile.isBla2) ...[
                const SizedBox(height: 12),
                const QuotaCard(),
              ],
              SectionTitle(l10n.formRoute),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final route in SubmitRoute.all)
                    ChoiceChip(
                      label: Text(routeLabel(l10n, route)),
                      selected: _route == route,
                      onSelected: editable
                          ? (_) => setState(() => _route = route)
                          : null,
                    ),
                ],
              ),
              SectionTitle(l10n.formReference),
              TextField(
                controller: _reference,
                enabled: editable,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() => _error = null),
              ),
              SectionTitle(l10n.formFiledOn),
              OutlinedButton.icon(
                onPressed: editable ? _pickFiledOn : null,
                icon: const Icon(Icons.event),
                label: Text(
                  _filedOn == null ? l10n.visitPickDate : formatDay(_filedOn!),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.formPhotoLater,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (editable) ...[
                if (nearLimit) ...[
                  const SizedBox(height: 12),
                  InfoBanner(
                    icon: Icons.warning_amber,
                    text: l10n.formQuotaWarn(
                      count.today,
                      settings.bla2DailyLimit,
                      count.total,
                      settings.bla2TotalLimit,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  InfoBanner(
                    icon: Icons.error_outline,
                    text: _error!,
                    error: true,
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _submit(form),
                  icon: const Icon(Icons.outbox_outlined),
                  label: Text(l10n.formMarkSubmitted),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy || !_changed(form) ? null : _saveDetails,
                  child: Text(l10n.formSaveDetails),
                ),
              ] else ...[
                const SizedBox(height: 12),
                InfoBanner(icon: Icons.lock_outline, text: l10n.formLocked),
              ],
              SectionTitle(l10n.formTimeline),
              for (final event in data.eventsOf(form.id))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Pill(
                        dense: true,
                        label: formStatusLabel(l10n, event.status),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          formatMoment(event.changedAt),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (event.pending)
                        Pill(
                          dense: true,
                          label: CodeLabel(
                            l10n.notSynced,
                            Icons.cloud_upload_outlined,
                            const Color(0xFF8A5A00),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The ECI screenshot or the applicant's face photo ([kind]): on this phone
/// (waiting to be sent), on the server, or missing, with a button to add or
/// change it.
class _PhotoCard extends StatefulWidget {
  const _PhotoCard({super.key, required this.form, required this.kind});

  final ClaimForm form;
  final String kind;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  Uint8List? _local;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    FieldScope.of(context).store
        .photoOf(widget.form.id, kind: widget.kind)
        .then((bytes) {
          if (mounted && bytes != null) setState(() => _local = bytes);
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = FieldScope.of(context).store;
    final form = widget.form;
    final eci = widget.kind == PhotoKind.eci;
    final onServer = eci ? form.hasEci : form.hasPhoto;
    final waiting = _local != null && !onServer;
    Future<void> changed(Uint8List? bytes) async {
      setState(() => _local = bytes);
      if (bytes == null) {
        await store.removeFormPhoto(form.id, kind: widget.kind);
      } else {
        await store.setFormPhoto(form.id, bytes, kind: widget.kind);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eci)
              EciShotField(
                shot: _local,
                onServer: form.hasEci,
                status: form.eciStatus,
                referenceNo: form.eciReferenceNo,
                onChanged: changed,
              )
            else
              FacePhotoField(
                photo: _local,
                onServer: form.hasPhoto,
                onChanged: changed,
              ),
            if (waiting) ...[
              const SizedBox(height: 6),
              Text(eci ? l10n.eciWaiting : l10n.photoWaiting),
            ] else if (_local == null && !onServer) ...[
              const SizedBox(height: 6),
              Text(eci ? l10n.eciMissing : l10n.photoMissing),
            ],
          ],
        ),
      ),
    );
  }
}
