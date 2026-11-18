import 'dart:convert';

/// Fixed codes, stored as on the server. The app shows Hindi labels.
abstract final class Outcome {
  static const eligible = 'ELIGIBLE';
  static const correction = 'CORRECTION';
  static const movedIn = 'MOVED_IN';
  static const shifted = 'SHIFTED';
  static const dead = 'DEAD';
  static const notMet = 'NOT_MET';
  static const alreadyOnRoll = 'ALREADY_ON_ROLL';

  static const all = [
    eligible,
    correction,
    movedIn,
    shifted,
    dead,
    notMet,
    alreadyOnRoll,
  ];

  /// Outcomes that lead to a claim form (spec section 6, visit flow step 4).
  static bool needsForm(String outcome) =>
      outcome == eligible || outcome == movedIn;
}

abstract final class FormStatus {
  static const filled = 'FILLED';
  static const submitted = 'SUBMITTED';
  static const inEroList = 'IN_ERO_LIST';
  static const accepted = 'ACCEPTED';
  static const rejected = 'REJECTED';
  static const hearing = 'HEARING';

  static const all = [
    filled,
    submitted,
    inEroList,
    accepted,
    rejected,
    hearing,
  ];

  static bool isOpen(String status) => status != accepted && status != rejected;
}

abstract final class SubmitRoute {
  static const bla2 = 'BLA2';
  static const self = 'SELF';
  static const online = 'ONLINE';
  static const all = [bla2, self, online];
}

abstract final class Doc {
  static const all = [
    'AADHAAR',
    'BIRTH_CERT',
    'HIGHSCHOOL',
    'RATION',
    'ELECTRICITY',
    'OTHER',
  ];
}

enum FamilyStatus { pending, done, revisit }

class Booth {
  const Booth({required this.partNo, this.stationHi});
  final int partNo;
  final String? stationHi;
}

class Family {
  const Family({
    required this.id,
    required this.code,
    required this.partNo,
    this.sectionNo,
    this.houseNo,
    this.headNameHi,
    required this.priority,
    this.needsReview = false,
  });

  final String id;
  final String code;
  final int partNo;
  final int? sectionNo;
  final String? houseNo;
  final String? headNameHi;

  /// 1 is the most urgent, 4 the least.
  final int priority;
  final bool needsReview;

  bool get isHighPriority => priority == 1;
}

class Voter {
  const Voter({
    required this.id,
    required this.familyId,
    this.epic,
    required this.nameHi,
    this.relationType,
    this.relativeNameHi,
    this.age,
    this.gender,
    required this.sourceList,
    this.asddReason,
    this.matchConfidence,
    this.alreadyOnRoll = false,
    this.pending = false,
  });

  final String id;
  final String familyId;
  final String? epic;
  final String nameHi;
  final String? relationType;
  final String? relativeNameHi;
  final int? age;
  final String? gender;
  final String sourceList;
  final String? asddReason;
  final String? matchConfidence;
  final bool alreadyOnRoll;
  final bool pending;

  bool get isNew => sourceList == 'NEW';
}

class VisitMember {
  const VisitMember({
    required this.voterId,
    required this.outcome,
    this.docs = const [],
  });
  final String voterId;
  final String outcome;
  final List<String> docs;
}

class Visit {
  const Visit({
    required this.id,
    required this.familyId,
    required this.byMe,
    required this.visitedAt,
    required this.outcome,
    this.revisitOn,
    this.remarks,
    this.pending = false,
    this.members = const [],
  });

  final String id;
  final String familyId;
  final bool byMe;
  final DateTime visitedAt;
  final String outcome;
  final String? revisitOn;
  final String? remarks;
  final bool pending;
  final List<VisitMember> members;
}

class ClaimForm {
  const ClaimForm({
    required this.id,
    required this.voterId,
    required this.formType,
    this.route,
    this.referenceNo,
    this.filedOn,
    required this.byMe,
    required this.status,
    required this.updatedAt,
    this.pending = false,
  });

  final String id;
  final String voterId;
  final String formType;
  final String? route;
  final String? referenceNo;
  final String? filedOn;
  final bool byMe;
  final String status;
  final DateTime updatedAt;
  final bool pending;

  bool get isOpen => FormStatus.isOpen(status);
}

class FormEvent {
  const FormEvent({
    required this.id,
    required this.formId,
    required this.status,
    required this.changedAt,
    this.byMe = false,
    this.pending = false,
  });

  final String id;
  final String formId;
  final String status;
  final DateTime changedAt;
  final bool byMe;
  final bool pending;
}

class CampaignSettings {
  const CampaignSettings({
    required this.visitsOpenFrom,
    required this.claimsCloseAt,
    required this.statusCloseAt,
    this.dailyFamilyTarget = 30,
    this.bla2DailyLimit = 10,
    this.bla2TotalLimit = 30,
  });

  /// The spec's dates, used until the first sync brings the server's.
  static final defaults = CampaignSettings(
    visitsOpenFrom: '2026-11-20',
    claimsCloseAt: DateTime.parse('2026-12-16T23:59:59+05:30'),
    statusCloseAt: DateTime.parse('2027-01-04T23:59:59+05:30'),
  );

  final String visitsOpenFrom;
  final DateTime claimsCloseAt;
  final DateTime statusCloseAt;
  final int dailyFamilyTarget;
  final int bla2DailyLimit;
  final int bla2TotalLimit;

  factory CampaignSettings.fromJson(Map<String, dynamic> json) =>
      CampaignSettings(
        visitsOpenFrom: json['visits_open_from'] as String,
        claimsCloseAt: DateTime.parse(json['claims_close_at'] as String),
        statusCloseAt: DateTime.parse(json['status_close_at'] as String),
        dailyFamilyTarget: json['daily_family_target'] as int? ?? 30,
        bla2DailyLimit: json['bla2_daily_limit'] as int? ?? 10,
        bla2TotalLimit: json['bla2_total_limit'] as int? ?? 30,
      );
}

/// BLA-2 submissions counted by the server at the last sync.
class Quota {
  const Quota({required this.day, required this.today, required this.total});
  final String day; // IST date the counts were taken
  final int today;
  final int total;
}

class OutboxEntry {
  const OutboxEntry({
    required this.seq,
    required this.uuid,
    required this.entity,
    required this.payload,
    required this.createdAt,
    required this.rejected,
    this.errorCode,
    this.errorHi,
  });

  final int seq;
  final String uuid;
  final String entity;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final bool rejected;
  final String? errorCode;
  final String? errorHi;

  Map<String, dynamic> toPushItem() => {
    'uuid': uuid,
    'entity': entity,
    'op': 'upsert',
    'client_ts': createdAt.toUtc().toIso8601String(),
    'data': payload,
  };

  static Map<String, dynamic> decodePayload(String source) =>
      Map<String, dynamic>.from(jsonDecode(source) as Map);
}

/// India Standard Time helpers. The campaign's days run on IST regardless of
/// the phone's time zone setting.
abstract final class Ist {
  static DateTime now() =>
      DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

  /// YYYY-MM-DD of [at] in IST.
  static String day(DateTime at) => at
      .toUtc()
      .add(const Duration(hours: 5, minutes: 30))
      .toIso8601String()
      .substring(0, 10);

  static String today() => day(DateTime.now());

  static String addDays(String day, int days) =>
      DateTime.parse('${day}T00:00:00Z')
          .add(Duration(days: days))
          .toIso8601String()
          .substring(0, 10);
}

/// Everything the screens show, built from the local database.
class FieldData {
  FieldData({
    required this.booths,
    required this.families,
    required this.voters,
    required this.visits,
    required this.forms,
    required this.events,
    required this.settings,
    required this.quota,
    required this.outbox,
    required this.lastSyncAt,
  }) {
    for (final v in voters) {
      (_votersByFamily[v.familyId] ??= []).add(v);
      _voterById[v.id] = v;
    }
    for (final f in families) {
      _familyById[f.id] = f;
    }
    for (final v in visits) {
      (_visitsByFamily[v.familyId] ??= []).add(v);
    }
    for (final list in _visitsByFamily.values) {
      list.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    }
    for (final f in forms) {
      (_formsByVoter[f.voterId] ??= []).add(f);
      _formById[f.id] = f;
    }
    for (final e in events) {
      (_eventsByForm[e.formId] ??= []).add(e);
    }
    for (final list in _eventsByForm.values) {
      list.sort((a, b) => a.changedAt.compareTo(b.changedAt));
    }
  }

  factory FieldData.empty() => FieldData(
    booths: const [],
    families: const [],
    voters: const [],
    visits: const [],
    forms: const [],
    events: const [],
    settings: CampaignSettings.defaults,
    quota: null,
    outbox: const [],
    lastSyncAt: null,
  );

  final List<Booth> booths;
  final List<Family> families;
  final List<Voter> voters;
  final List<Visit> visits;
  final List<ClaimForm> forms;
  final List<FormEvent> events;
  final CampaignSettings settings;
  final Quota? quota;
  final List<OutboxEntry> outbox;
  final DateTime? lastSyncAt;

  final _votersByFamily = <String, List<Voter>>{};
  final _voterById = <String, Voter>{};
  final _familyById = <String, Family>{};
  final _visitsByFamily = <String, List<Visit>>{};
  final _formsByVoter = <String, List<ClaimForm>>{};
  final _formById = <String, ClaimForm>{};
  final _eventsByForm = <String, List<FormEvent>>{};

  Family? family(String id) => _familyById[id];
  Voter? voter(String id) => _voterById[id];
  ClaimForm? form(String id) => _formById[id];
  List<Voter> votersOf(String familyId) =>
      _votersByFamily[familyId] ?? const [];

  /// Newest first.
  List<Visit> visitsOf(String familyId) =>
      _visitsByFamily[familyId] ?? const [];
  List<ClaimForm> formsOf(String voterId) => _formsByVoter[voterId] ?? const [];

  /// Oldest first.
  List<FormEvent> eventsOf(String formId) => _eventsByForm[formId] ?? const [];

  List<Family> familiesInBooth(int partNo) => [
    for (final f in families)
      if (f.partNo == partNo) f,
  ];

  FamilyStatus statusOf(String familyId) {
    final visits = visitsOf(familyId);
    if (visits.isEmpty) return FamilyStatus.pending;
    return visits.first.revisitOn != null
        ? FamilyStatus.revisit
        : FamilyStatus.done;
  }

  /// The voter already has an open form of this type (R6).
  bool hasOpenForm(String voterId, String formType) =>
      formsOf(voterId).any((f) => f.formType == formType && f.isOpen);

  int get pendingCount => outbox.where((e) => !e.rejected).length;
  int get rejectedCount => outbox.where((e) => e.rejected).length;
  bool get hasUnsent => outbox.isNotEmpty;

  /// The oldest change still waiting to be sent.
  DateTime? get oldestUnsentAt => outbox.isEmpty
      ? null
      : outbox.map((e) => e.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
}
