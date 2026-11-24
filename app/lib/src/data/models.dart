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

/// Who the household contact is, relative to the listed person.
abstract final class ContactRelation {
  static const all = [
    'FATHER',
    'MOTHER',
    'HUSBAND',
    'WIFE',
    'SON',
    'DAUGHTER',
    'SIBLING',
    'SELF',
    'OTHER',
  ];
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
    this.oldPartNo,
    this.oldSerial,
    this.alreadyOnRoll = false,
    this.category,
    this.closest2026,
    this.newReason,
    this.newReasonNote,
    this.draftPart,
    this.draftSection,
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
  final int? oldPartNo;
  final int? oldSerial;
  final bool alreadyOnRoll;
  final String? category;
  final String? closest2026;

  /// Added in the field: [NewReason] code and an optional note.
  final String? newReason;
  final String? newReasonNote;

  /// Part and section on the 2027 draft roll (published 17 Nov 2026).
  final int? draftPart;
  final String? draftSection;
  final bool pending;

  bool get isNew => sourceList == 'NEW';

  /// The workbook's category; worked out from the list and reason for rows
  /// saved before the server sent categories.
  String get categoryCode =>
      category ??
      (isNew
          ? VoterCategory.added
          : sourceList == 'POSS_DEL'
          ? 'POSS_${matchConfidence ?? 'MEDIUM'}'
          : asddReason ?? VoterCategory.shifted);
}

/// Why a volunteer added a voter who is not on the list.
abstract final class NewReason {
  static const turned18 = 'TURNED_18_THIS_YEAR';
  static const other = 'OTHER';
}

/// Why a person is on the list, as the campaign workbook groups them.
abstract final class VoterCategory {
  static const untraceable = 'UNTRACEABLE';
  static const shifted = 'SHIFTED';
  static const deceased = 'DECEASED';
  static const duplicate = 'DUPLICATE';
  static const alreadyBack = 'ALREADY_BACK';
  static const onDraftRoll = 'ON_DRAFT_ROLL';
  static const possHigh = 'POSS_HIGH';
  static const possMedium = 'POSS_MEDIUM';
  static const possLow = 'POSS_LOW';
  static const added = 'NEW';

  /// In the order the filter shows them.
  static const all = [
    untraceable,
    shifted,
    possHigh,
    possMedium,
    possLow,
    deceased,
    duplicate,
    alreadyBack,
    onDraftRoll,
    added,
  ];

  /// Already on a roll again: listed for reference, no visit needed.
  static bool noVisitNeeded(String code) =>
      code == alreadyBack || code == onDraftRoll;
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
    this.hasPhoto = false,
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

  /// The server has the applicant's face photo.
  final bool hasPhoto;
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
    this.dailyPeopleTarget = 45,
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

  /// People to cover a day; progress is counted in people.
  final int dailyPeopleTarget;
  final int bla2DailyLimit;
  final int bla2TotalLimit;

  factory CampaignSettings.fromJson(Map<String, dynamic> json) =>
      CampaignSettings(
        visitsOpenFrom: json['visits_open_from'] as String,
        claimsCloseAt: DateTime.parse(json['claims_close_at'] as String),
        statusCloseAt: DateTime.parse(json['status_close_at'] as String),
        dailyFamilyTarget: json['daily_family_target'] as int? ?? 30,
        dailyPeopleTarget: json['daily_people_target'] as int? ?? 45,
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
    this.localPhotos = const {},
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

  /// Forms with a face photo on this phone not yet confirmed by the server.
  final Set<String> localPhotos;

  /// A face photo was taken for the form (on this phone or on the server).
  bool formHasPhoto(String formId) =>
      localPhotos.contains(formId) || (form(formId)?.hasPhoto ?? false);

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

  /// Visits that recorded this person, newest first. A visit covers the
  /// people listed on it; an older visit with no people listed covers its
  /// whole record.
  List<Visit> visitsFor(String voterId) {
    final voter = _voterById[voterId];
    if (voter == null) return const [];
    return [
      for (final v in visitsOf(voter.familyId))
        if (v.members.isEmpty) v,
      for (final v in visits)
        if (v.members.any((m) => m.voterId == voterId)) v,
    ]..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
  }

  /// People recorded together with this person on a visit: the household
  /// as the volunteer confirmed it at the door, whatever the list said.
  List<Voter> householdOf(String voterId) {
    final ids = <String>{};
    for (final visit in visits) {
      if (!visit.members.any((m) => m.voterId == voterId)) continue;
      for (final m in visit.members) {
        if (m.voterId != voterId) ids.add(m.voterId);
      }
    }
    return [for (final id in ids) ?_voterById[id]]..sort(compareRollOrder);
  }

  /// Not visited yet, done, or to be visited again (nobody met, this person
  /// not met, or a revisit date set).
  FamilyStatus personStatus(String voterId) {
    final visits = visitsFor(voterId);
    if (visits.isEmpty) return FamilyStatus.pending;
    final last = visits.first;
    final mine = last.members.where((m) => m.voterId == voterId);
    final notMet =
        last.outcome == Outcome.notMet ||
        (mine.isNotEmpty && mine.first.outcome == Outcome.notMet);
    return notMet || last.revisitOn != null
        ? FamilyStatus.revisit
        : FamilyStatus.done;
  }

  /// Everyone listed in a booth, in 2025 roll order (the order a booth was
  /// walked when the roll was made).
  List<Voter> peopleInBooth(int partNo) {
    final people = [
      for (final v in voters)
        if (_familyById[v.familyId]?.partNo == partNo) v,
    ];
    people.sort(compareRollOrder);
    return people;
  }

  int compareRollOrder(Voter a, Voter b) {
    const last = 1 << 30;
    final byPart = (a.oldPartNo ?? last).compareTo(b.oldPartNo ?? last);
    if (byPart != 0) return byPart;
    final bySerial = (a.oldSerial ?? last).compareTo(b.oldSerial ?? last);
    if (bySerial != 0) return bySerial;
    return a.nameHi.compareTo(b.nameHi);
  }

  /// People who may live in the same house as [voterId]: others on the same
  /// record (e.g. added in the field), and listed people with the same house
  /// number close by on the 2025 roll. Only suggestions: the volunteer
  /// confirms at the door.
  List<Voter> sameHouseCandidates(String voterId) {
    final lead = _voterById[voterId];
    if (lead == null) return const [];
    final family = _familyById[lead.familyId];
    final house = _normHouse(family?.houseNo);
    final out = <Voter>[];
    for (final v in voters) {
      if (v.id == lead.id) continue;
      if (v.familyId == lead.familyId) {
        out.add(v);
        continue;
      }
      if (house.isEmpty || family == null) continue;
      final f = _familyById[v.familyId];
      if (f == null || f.partNo != family.partNo) continue;
      if (_normHouse(f.houseNo) != house) continue;
      if (v.oldPartNo != lead.oldPartNo) continue;
      final a = v.oldSerial, b = lead.oldSerial;
      if (a == null || b == null || (a - b).abs() > 10) continue;
      out.add(v);
    }
    out.sort(compareRollOrder);
    return out;
  }

  static String _normHouse(String? house) {
    var h = (house ?? '').replaceAll(RegExp(r'\s+'), '').toUpperCase();
    const hindiDigits = '०१२३४५६७८९';
    for (var i = 0; i < 10; i++) {
      h = h.replaceAll(hindiDigits[i], '$i');
    }
    return RegExp(r'^0*$').hasMatch(h) ? '' : h;
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
