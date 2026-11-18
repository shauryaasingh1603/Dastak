import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'ids.dart';
import 'local_db.dart';
import 'models.dart';

/// What the volunteer filled in for one member during a visit.
class MemberEntry {
  const MemberEntry({
    required this.voterId,
    required this.outcome,
    this.formType,
    this.docs = const [],
    this.mobile,
    this.mobileConsent = false,
  });

  final String voterId;
  final String outcome;

  /// '6', '8', or null for no form.
  final String? formType;
  final List<String> docs;
  final String? mobile;
  final bool mobileConsent;
}

class VisitDraft {
  const VisitDraft({
    required this.familyId,
    required this.nobodyHome,
    this.metPerson,
    this.members = const [],
    this.remarks,
    this.revisitOn,
    this.gpsLat,
    this.gpsLng,
    this.gpsAccuracy,
    this.gpsFlag,
  });

  final String familyId;
  final bool nobodyHome;
  final String? metPerson;
  final List<MemberEntry> members;
  final String? remarks;
  final String? revisitOn;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsAccuracy;

  /// GPS_OFF, GPS_DENIED or GPS_INACCURATE (R5).
  final String? gpsFlag;
}

class NewVoterDraft {
  const NewVoterDraft({
    required this.familyId,
    required this.nameHi,
    required this.relationType,
    required this.relativeNameHi,
    required this.age,
    required this.gender,
    this.epic,
    this.formType,
  });

  final String familyId;
  final String nameHi;
  final String relationType;
  final String relativeNameHi;
  final int age;
  final String gender;
  final String? epic;
  final String? formType;
}

/// The phone's working copy: reads the local database into [data] and
/// records every change in the local tables plus the outbox, in one
/// transaction, so nothing is lost if the app closes before it syncs.
class FieldStore extends ChangeNotifier {
  FieldStore(this.db);

  final LocalDb db;

  FieldData _data = FieldData.empty();
  FieldData get data => _data;

  bool _loaded = false;
  bool get loaded => _loaded;

  /// Called after every local change, so the sync can start at once.
  VoidCallback? onLocalChange;

  static const _settingsKey = 'settings';
  static const _quotaKey = 'quota';
  static const _lastSyncKey = 'last_sync_at';
  static const _ownerKey = 'owner_user_id';

  // ---------------------------------------------------------------------------
  // Reading
  // ---------------------------------------------------------------------------

  Future<void> reload() async {
    final meta = {
      for (final m in await db.select(db.meta).get()) m.key: m.value,
    };
    final members = <String, List<VisitMember>>{};
    for (final m in await db.select(db.visitVoters).get()) {
      (members[m.visitId] ??= []).add(
        VisitMember(
          voterId: m.voterId,
          outcome: m.voterOutcome,
          docs: m.docsSeen.isEmpty ? const [] : m.docsSeen.split(','),
        ),
      );
    }

    final quotaJson = meta[_quotaKey];
    final quota = quotaJson == null
        ? null
        : () {
            final q = jsonDecode(quotaJson) as Map<String, dynamic>;
            return Quota(
              day: q['day'] as String,
              today: q['today'] as int,
              total: q['total'] as int,
            );
          }();

    _data = FieldData(
      booths: [
        for (final b in await (db.select(
          db.booths,
        )..orderBy([(t) => OrderingTerm(expression: t.partNo)])).get())
          Booth(partNo: b.partNo, stationHi: b.stationHi),
      ],
      families: [
        for (final f in await db.select(db.families).get())
          Family(
            id: f.id,
            code: f.code,
            partNo: f.partNo,
            sectionNo: f.sectionNo,
            houseNo: f.houseNo,
            headNameHi: f.headNameHi,
            priority: f.priority,
            needsReview: f.needsReview,
          ),
      ],
      voters: [
        for (final v in await db.select(db.voters).get())
          Voter(
            id: v.id,
            familyId: v.familyId,
            epic: v.epic,
            nameHi: v.nameHi,
            relationType: v.relationType,
            relativeNameHi: v.relativeNameHi,
            age: v.age,
            gender: v.gender,
            sourceList: v.sourceList,
            asddReason: v.asddReason,
            matchConfidence: v.matchConfidence,
            alreadyOnRoll: v.alreadyOnRoll,
            pending: v.pending,
          ),
      ],
      visits: [
        for (final v in await db.select(db.visits).get())
          Visit(
            id: v.id,
            familyId: v.familyId,
            byMe: v.byMe,
            visitedAt: v.visitedAt,
            outcome: v.outcome,
            revisitOn: v.revisitOn,
            remarks: v.remarks,
            pending: v.pending,
            members: members[v.id] ?? const [],
          ),
      ],
      forms: [
        for (final f in await db.select(db.forms).get())
          ClaimForm(
            id: f.id,
            voterId: f.voterId,
            formType: f.formType,
            route: f.route,
            referenceNo: f.referenceNo,
            filedOn: f.filedOn,
            byMe: f.byMe,
            status: f.currentStatus,
            updatedAt: f.updatedAt,
            pending: f.pending,
          ),
      ],
      events: [
        for (final e in await db.select(db.formEvents).get())
          FormEvent(
            id: e.id,
            formId: e.formId,
            status: e.status,
            changedAt: e.changedAt,
            byMe: e.byMe,
            pending: e.pending,
          ),
      ],
      settings: meta[_settingsKey] == null
          ? CampaignSettings.defaults
          : CampaignSettings.fromJson(
              jsonDecode(meta[_settingsKey]!) as Map<String, dynamic>,
            ),
      quota: quota,
      outbox: [
        for (final o in await (db.select(
          db.outbox,
        )..orderBy([(t) => OrderingTerm(expression: t.seq)])).get())
          OutboxEntry(
            seq: o.seq,
            uuid: o.uuid,
            entity: o.entity,
            payload: OutboxEntry.decodePayload(o.payload),
            createdAt: o.createdAt,
            rejected: o.state == 'rejected',
            errorCode: o.errorCode,
            errorHi: o.errorHi,
          ),
      ],
      lastSyncAt: meta[_lastSyncKey] == null
          ? null
          : DateTime.parse(meta[_lastSyncKey]!),
    );
    _loaded = true;
    notifyListeners();
  }

  /// BLA-2 submissions so far, including ones not yet sent (R2).
  ({int today, int total}) bla2Count() {
    final today = Ist.today();
    final quota = _data.quota;
    var countToday = quota != null && quota.day == today ? quota.today : 0;
    var countTotal = quota?.total ?? 0;
    for (final e in _data.events) {
      if (!e.pending || !e.byMe || e.status != FormStatus.submitted) continue;
      if (_data.form(e.formId)?.route != SubmitRoute.bla2) continue;
      countTotal++;
      if (Ist.day(e.changedAt) == today) countToday++;
    }
    return (today: countToday, total: countTotal);
  }

  // ---------------------------------------------------------------------------
  // Local changes
  // ---------------------------------------------------------------------------

  /// Records a door visit. Returns the ids of any forms it started.
  Future<List<String>> saveVisit(VisitDraft draft) async {
    final visitId = newId();
    final now = DateTime.now().toUtc();
    final createdForms = <String>[];

    final outcome = draft.nobodyHome
        ? Outcome.notMet
        : _familyOutcome(draft.members.map((m) => m.outcome));

    await db.transaction(() async {
      await db
          .into(db.visits)
          .insert(
            VisitsCompanion.insert(
              id: visitId,
              familyId: draft.familyId,
              byMe: true,
              visitedAt: now,
              outcome: outcome,
              revisitOn: Value(draft.revisitOn),
              remarks: Value(_blankToNull(draft.remarks)),
              pending: const Value(true),
            ),
          );
      for (final m
          in draft.nobodyHome ? const <MemberEntry>[] : draft.members) {
        await db
            .into(db.visitVoters)
            .insert(
              VisitVotersCompanion.insert(
                visitId: visitId,
                voterId: m.voterId,
                voterOutcome: m.outcome,
                docsSeen: Value(m.docs.join(',')),
              ),
            );
      }
      await _enqueue('visit', visitId, {
        'family_id': draft.familyId,
        'visited_at': now.toIso8601String(),
        'outcome': outcome,
        'met_person': _blankToNull(draft.metPerson),
        'remarks': _blankToNull(draft.remarks),
        'revisit_on': draft.revisitOn,
        'gps_lat': draft.gpsLat,
        'gps_lng': draft.gpsLng,
        'gps_accuracy_m': draft.gpsAccuracy,
        'flags': [?draft.gpsFlag],
        'voters': [
          for (final m
              in draft.nobodyHome ? const <MemberEntry>[] : draft.members)
            {
              'voter_id': m.voterId,
              'voter_outcome': m.outcome,
              'docs_seen': m.docs,
              'mobile': _blankToNull(m.mobile),
              'mobile_consent': m.mobileConsent,
            },
        ],
      });

      for (final m
          in draft.nobodyHome ? const <MemberEntry>[] : draft.members) {
        final type = m.formType;
        if (type == null || _data.hasOpenForm(m.voterId, type)) continue;
        createdForms.add(await _startForm(m.voterId, type, now));
      }
    });

    await _afterChange();
    return createdForms;
  }

  /// Adds a voter found at the house who is not on the list. Returns the id
  /// of the form started for them, if any.
  Future<String?> addVoter(NewVoterDraft draft) async {
    final voterId = newId();
    final now = DateTime.now().toUtc();
    String? formId;
    await db.transaction(() async {
      await db
          .into(db.voters)
          .insert(
            VotersCompanion.insert(
              id: voterId,
              familyId: draft.familyId,
              epic: Value(_blankToNull(draft.epic)?.toUpperCase()),
              nameHi: draft.nameHi.trim(),
              relationType: Value(draft.relationType),
              relativeNameHi: Value(draft.relativeNameHi.trim()),
              age: Value(draft.age),
              gender: Value(draft.gender),
              sourceList: 'NEW',
              pending: const Value(true),
            ),
          );
      await _enqueue('voter', voterId, {
        'family_id': draft.familyId,
        'name_hi': draft.nameHi.trim(),
        'relation_type': draft.relationType,
        'relative_name_hi': draft.relativeNameHi.trim(),
        'age': draft.age,
        'gender': draft.gender,
        'epic': _blankToNull(draft.epic)?.toUpperCase(),
      });
      if (draft.formType != null) {
        formId = await _startForm(voterId, draft.formType!, now);
      }
    });
    await _afterChange();
    return formId;
  }

  /// Saves how and when a form was submitted, and its receipt number.
  Future<void> updateForm(
    String formId, {
    required String? route,
    required String? referenceNo,
    required String? filedOn,
  }) async {
    final form = _data.form(formId);
    if (form == null) return;
    await db.transaction(() async {
      await (db.update(db.forms)..where((t) => t.id.equals(formId))).write(
        FormsCompanion(
          route: Value(route),
          referenceNo: Value(_blankToNull(referenceNo)),
          filedOn: Value(filedOn),
          updatedAt: Value(DateTime.now().toUtc()),
          pending: const Value(true),
        ),
      );
      await _enqueue('form', formId, {
        'voter_id': form.voterId,
        'form_type': form.formType,
        'route': route,
        'reference_no': _blankToNull(referenceNo),
        'filed_on': filedOn,
      });
    });
    await _afterChange();
  }

  /// Records that a form has been submitted. Callers check R1 and R2 first.
  Future<void> markSubmitted(String formId) async {
    final eventId = newId();
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.update(db.forms)..where((t) => t.id.equals(formId))).write(
        FormsCompanion(
          currentStatus: const Value(FormStatus.submitted),
          updatedAt: Value(now),
          pending: const Value(true),
        ),
      );
      await db
          .into(db.formEvents)
          .insert(
            FormEventsCompanion.insert(
              id: eventId,
              formId: formId,
              status: FormStatus.submitted,
              changedAt: now,
              byMe: const Value(true),
              pending: const Value(true),
            ),
          );
      await _enqueue('form_event', eventId, {
        'form_id': formId,
        'status': FormStatus.submitted,
        'client_ts': now.toIso8601String(),
      });
    });
    await _afterChange();
  }

  Future<String> _startForm(
    String voterId,
    String formType,
    DateTime now,
  ) async {
    final formId = newId();
    final eventId = newId();
    await db
        .into(db.forms)
        .insert(
          FormsCompanion.insert(
            id: formId,
            voterId: voterId,
            formType: formType,
            byMe: true,
            currentStatus: FormStatus.filled,
            updatedAt: now,
            pending: const Value(true),
          ),
        );
    await db
        .into(db.formEvents)
        .insert(
          FormEventsCompanion.insert(
            id: eventId,
            formId: formId,
            status: FormStatus.filled,
            changedAt: now,
            byMe: const Value(true),
            pending: const Value(true),
          ),
        );
    await _enqueue('form', formId, {
      'voter_id': voterId,
      'form_type': formType,
      'route': null,
      'reference_no': null,
      'filed_on': null,
    });
    await _enqueue('form_event', eventId, {
      'form_id': formId,
      'status': FormStatus.filled,
      'client_ts': now.toIso8601String(),
    });
    return formId;
  }

  /// Adds an outbox item. Items are never merged: an item may already be on
  /// its way to the server, and changing it then would lose the change when
  /// the server confirms the copy it received. Repeats are cheap, because the
  /// server treats each one as an idempotent upsert.
  Future<void> _enqueue(
    String entity,
    String uuid,
    Map<String, dynamic> payload,
  ) async {
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            uuid: uuid,
            entity: entity,
            payload: jsonEncode(payload),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> _afterChange() async {
    await reload();
    onLocalChange?.call();
  }

  // ---------------------------------------------------------------------------
  // Sync support
  // ---------------------------------------------------------------------------

  /// Up to [limit] outbox items waiting to be sent, oldest first.
  Future<List<OutboxEntry>> pendingBatch({int limit = 50}) async {
    final rows =
        await (db.select(db.outbox)
              ..where((t) => t.state.equals('pending'))
              ..orderBy([(t) => OrderingTerm(expression: t.seq)])
              ..limit(limit))
            .get();
    return [
      for (final o in rows)
        OutboxEntry(
          seq: o.seq,
          uuid: o.uuid,
          entity: o.entity,
          payload: OutboxEntry.decodePayload(o.payload),
          createdAt: o.createdAt,
          rejected: false,
        ),
    ];
  }

  /// Applies the server's answer for each sent item, in the same order.
  Future<void> applyPushResults(
    List<OutboxEntry> sent,
    List<({bool ok, String? code, String? messageHi})> results,
  ) async {
    await db.transaction(() async {
      for (var i = 0; i < sent.length && i < results.length; i++) {
        final item = sent[i];
        final result = results[i];
        if (result.ok) {
          await (db.delete(
            db.outbox,
          )..where((t) => t.seq.equals(item.seq))).go();
          await _settle(item.entity, item.uuid);
        } else {
          await (db.update(
            db.outbox,
          )..where((t) => t.seq.equals(item.seq))).write(
            OutboxCompanion(
              state: const Value('rejected'),
              errorCode: Value(result.code),
              errorHi: Value(result.messageHi),
              attempts: Value(1),
            ),
          );
        }
      }
    });
    await reload();
  }

  /// Marks a row as matching the server once nothing about it is waiting.
  Future<void> _settle(String entity, String uuid) async {
    final stillWaiting = await (db.select(
      db.outbox,
    )..where((t) => t.uuid.equals(uuid))).get();
    if (stillWaiting.isNotEmpty) return;
    switch (entity) {
      case 'voter':
        await (db.update(db.voters)..where((t) => t.id.equals(uuid))).write(
          const VotersCompanion(pending: Value(false)),
        );
      case 'visit':
        await (db.update(db.visits)..where((t) => t.id.equals(uuid))).write(
          const VisitsCompanion(pending: Value(false)),
        );
      case 'form':
        await (db.update(db.forms)..where((t) => t.id.equals(uuid))).write(
          const FormsCompanion(pending: Value(false)),
        );
      case 'form_event':
        await (db.update(db.formEvents)..where((t) => t.id.equals(uuid))).write(
          const FormEventsCompanion(pending: Value(false)),
        );
    }
  }

  /// Sends a rejected item again (after the reason has been fixed).
  Future<void> retryRejected(int seq) async {
    await (db.update(db.outbox)..where((t) => t.seq.equals(seq))).write(
      const OutboxCompanion(
        state: Value('pending'),
        errorCode: Value(null),
        errorHi: Value(null),
      ),
    );
    await _afterChange();
  }

  /// Drops a rejected item. The next sync replaces the local row with the
  /// server's version, or removes it if the server never had it.
  Future<void> discardRejected(int seq) async {
    final row = await (db.select(
      db.outbox,
    )..where((t) => t.seq.equals(seq))).getSingleOrNull();
    if (row == null) return;
    await (db.delete(db.outbox)..where((t) => t.seq.equals(seq))).go();
    await _settle(row.entity, row.uuid);
    await reload();
  }

  /// Replaces the local copy with the server's snapshot, keeping every row
  /// that still has changes waiting to be sent.
  Future<void> applySnapshot(
    Map<String, dynamic> snap, {
    required String userId,
  }) async {
    List<Map<String, dynamic>> rows(String key) => [
      for (final r in (snap[key] as List? ?? const []))
        Map<String, dynamic>.from(r as Map),
    ];

    await db.transaction(() async {
      final pendingVoters = await _pendingIds(
        db.voters,
        db.voters.id,
        db.voters.pending,
      );
      final pendingVisits = await _pendingIds(
        db.visits,
        db.visits.id,
        db.visits.pending,
      );
      final pendingForms = await _pendingIds(
        db.forms,
        db.forms.id,
        db.forms.pending,
      );
      final pendingEvents = await _pendingIds(
        db.formEvents,
        db.formEvents.id,
        db.formEvents.pending,
      );

      await db.delete(db.booths).go();
      await db.delete(db.families).go();
      await (db.delete(db.voters)..where((t) => t.pending.equals(false))).go();
      await (db.delete(
        db.visitVoters,
      )..where((t) => t.visitId.isNotIn(pendingVisits))).go();
      await (db.delete(db.visits)..where((t) => t.pending.equals(false))).go();
      await (db.delete(db.forms)..where((t) => t.pending.equals(false))).go();
      await (db.delete(
        db.formEvents,
      )..where((t) => t.pending.equals(false))).go();

      await db.batch((b) {
        b.insertAll(db.booths, [
          for (final r in rows('booths'))
            BoothsCompanion.insert(
              partNo: Value(r['part_no'] as int),
              stationHi: Value(
                r['station_hi'] as String? ?? r['name_hi'] as String?,
              ),
            ),
        ]);
        b.insertAll(db.families, [
          for (final r in rows('families'))
            FamiliesCompanion.insert(
              id: r['id'] as String,
              code: r['code'] as String,
              partNo: r['part_no'] as int,
              sectionNo: Value(r['section_no'] as int?),
              houseNo: Value(r['house_no'] as String?),
              headNameHi: Value(r['head_name_hi'] as String?),
              priority: r['priority'] as int,
              needsReview: Value(r['needs_review'] as bool? ?? false),
            ),
        ]);
        b.insertAll(db.voters, mode: InsertMode.insertOrReplace, [
          for (final r in rows('voters'))
            VotersCompanion.insert(
              id: r['id'] as String,
              familyId: r['family_id'] as String,
              epic: Value(r['epic'] as String?),
              nameHi: r['name_hi'] as String,
              relationType: Value(r['relation_type'] as String?),
              relativeNameHi: Value(r['relative_name_hi'] as String?),
              age: Value(r['age'] as int?),
              gender: Value(r['gender'] as String?),
              sourceList: r['source_list'] as String,
              asddReason: Value(r['asdd_reason'] as String?),
              matchConfidence: Value(r['match_confidence'] as String?),
              alreadyOnRoll: Value(r['already_on_roll'] as bool? ?? false),
            ),
        ]);
        b.insertAll(db.visits, mode: InsertMode.insertOrReplace, [
          for (final r in rows('visits'))
            VisitsCompanion.insert(
              id: r['id'] as String,
              familyId: r['family_id'] as String,
              byMe: r['by_me'] as bool? ?? false,
              visitedAt: DateTime.parse(r['visited_at'] as String),
              outcome: r['outcome'] as String,
              revisitOn: Value(r['revisit_on'] as String?),
              remarks: Value(r['remarks'] as String?),
            ),
        ]);
        b.insertAll(db.visitVoters, mode: InsertMode.insertOrReplace, [
          for (final r in rows('visit_voters'))
            VisitVotersCompanion.insert(
              visitId: r['visit_id'] as String,
              voterId: r['voter_id'] as String,
              voterOutcome: r['voter_outcome'] as String,
              docsSeen: Value(
                ((r['docs_seen'] as List?) ?? const []).join(','),
              ),
            ),
        ]);
        b.insertAll(db.forms, mode: InsertMode.insertOrIgnore, [
          for (final r in rows('forms'))
            if (!pendingForms.contains(r['id']))
              FormsCompanion.insert(
                id: r['id'] as String,
                voterId: r['voter_id'] as String,
                formType: r['form_type'] as String,
                route: Value(r['route'] as String?),
                referenceNo: Value(r['reference_no'] as String?),
                filedOn: Value(r['filed_on'] as String?),
                byMe: r['by_me'] as bool? ?? false,
                currentStatus: r['current_status'] as String,
                updatedAt: DateTime.parse(r['updated_at'] as String),
              ),
        ]);
        b.insertAll(db.formEvents, mode: InsertMode.insertOrReplace, [
          for (final r in rows('form_events'))
            if (!pendingEvents.contains(r['id']))
              FormEventsCompanion.insert(
                id: r['id'] as String,
                formId: r['form_id'] as String,
                status: r['status'] as String,
                changedAt: DateTime.parse(r['changed_at'] as String),
              ),
        ]);
      });

      // Rows the server now has are no longer pending, unless the outbox
      // still holds a change for them.
      final waiting = {
        for (final o in await db.select(db.outbox).get()) o.uuid,
      };
      final serverVoters = {for (final r in rows('voters')) r['id'] as String};
      final serverVisits = {for (final r in rows('visits')) r['id'] as String};
      for (final id in pendingVoters.where(
        (id) => serverVoters.contains(id) && !waiting.contains(id),
      )) {
        await (db.update(db.voters)..where((t) => t.id.equals(id))).write(
          const VotersCompanion(pending: Value(false)),
        );
      }
      for (final id in pendingVisits.where(
        (id) => serverVisits.contains(id) && !waiting.contains(id),
      )) {
        await (db.update(db.visits)..where((t) => t.id.equals(id))).write(
          const VisitsCompanion(pending: Value(false)),
        );
      }

      final serverTime =
          snap['server_time'] as String? ??
          DateTime.now().toUtc().toIso8601String();
      final quota = snap['quota'] as Map?;
      await _putMeta(_settingsKey, jsonEncode(snap['settings']));
      await _putMeta(_lastSyncKey, DateTime.now().toUtc().toIso8601String());
      await _putMeta(_ownerKey, userId);
      if (quota != null) {
        await _putMeta(
          _quotaKey,
          jsonEncode({
            'day': Ist.day(DateTime.parse(serverTime)),
            'today': quota['today'],
            'total': quota['total'],
          }),
        );
      }
    });
    await reload();
  }

  Future<Set<String>> _pendingIds(
    TableInfo table,
    GeneratedColumn<String> id,
    GeneratedColumn<bool> pending,
  ) async {
    final query = db.selectOnly(table)
      ..addColumns([id])
      ..where(pending.equals(true));
    return {for (final row in await query.get()) row.read(id)!};
  }

  Future<void> _putMeta(String key, String value) => db
      .into(db.meta)
      .insertOnConflictUpdate(MetaCompanion.insert(key: key, value: value));

  /// Clears the phone if a different user signs in on it.
  Future<void> claimFor(String userId) async {
    final owner = await (db.select(
      db.meta,
    )..where((t) => t.key.equals(_ownerKey))).getSingleOrNull();
    if (owner != null && owner.value != userId) await db.wipe();
    await reload();
  }

  Future<void> wipe() async {
    await db.wipe();
    await reload();
  }

  /// The most actionable member outcome stands for the whole visit.
  static String _familyOutcome(Iterable<String> outcomes) {
    const order = [
      Outcome.eligible,
      Outcome.movedIn,
      Outcome.correction,
      Outcome.shifted,
      Outcome.dead,
      Outcome.alreadyOnRoll,
    ];
    for (final o in order) {
      if (outcomes.contains(o)) return o;
    }
    return Outcome.notMet;
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
