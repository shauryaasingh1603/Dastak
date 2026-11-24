// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $BoothsTable extends Booths with TableInfo<$BoothsTable, BoothRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoothsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _partNoMeta = const VerificationMeta('partNo');
  @override
  late final GeneratedColumn<int> partNo = GeneratedColumn<int>(
    'part_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stationHiMeta = const VerificationMeta(
    'stationHi',
  );
  @override
  late final GeneratedColumn<String> stationHi = GeneratedColumn<String>(
    'station_hi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [partNo, stationHi];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booths';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoothRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('part_no')) {
      context.handle(
        _partNoMeta,
        partNo.isAcceptableOrUnknown(data['part_no']!, _partNoMeta),
      );
    }
    if (data.containsKey('station_hi')) {
      context.handle(
        _stationHiMeta,
        stationHi.isAcceptableOrUnknown(data['station_hi']!, _stationHiMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {partNo};
  @override
  BoothRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoothRow(
      partNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_no'],
      )!,
      stationHi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_hi'],
      ),
    );
  }

  @override
  $BoothsTable createAlias(String alias) {
    return $BoothsTable(attachedDatabase, alias);
  }
}

class BoothRow extends DataClass implements Insertable<BoothRow> {
  final int partNo;
  final String? stationHi;
  const BoothRow({required this.partNo, this.stationHi});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['part_no'] = Variable<int>(partNo);
    if (!nullToAbsent || stationHi != null) {
      map['station_hi'] = Variable<String>(stationHi);
    }
    return map;
  }

  BoothsCompanion toCompanion(bool nullToAbsent) {
    return BoothsCompanion(
      partNo: Value(partNo),
      stationHi: stationHi == null && nullToAbsent
          ? const Value.absent()
          : Value(stationHi),
    );
  }

  factory BoothRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoothRow(
      partNo: serializer.fromJson<int>(json['partNo']),
      stationHi: serializer.fromJson<String?>(json['stationHi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'partNo': serializer.toJson<int>(partNo),
      'stationHi': serializer.toJson<String?>(stationHi),
    };
  }

  BoothRow copyWith({
    int? partNo,
    Value<String?> stationHi = const Value.absent(),
  }) => BoothRow(
    partNo: partNo ?? this.partNo,
    stationHi: stationHi.present ? stationHi.value : this.stationHi,
  );
  BoothRow copyWithCompanion(BoothsCompanion data) {
    return BoothRow(
      partNo: data.partNo.present ? data.partNo.value : this.partNo,
      stationHi: data.stationHi.present ? data.stationHi.value : this.stationHi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoothRow(')
          ..write('partNo: $partNo, ')
          ..write('stationHi: $stationHi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(partNo, stationHi);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoothRow &&
          other.partNo == this.partNo &&
          other.stationHi == this.stationHi);
}

class BoothsCompanion extends UpdateCompanion<BoothRow> {
  final Value<int> partNo;
  final Value<String?> stationHi;
  const BoothsCompanion({
    this.partNo = const Value.absent(),
    this.stationHi = const Value.absent(),
  });
  BoothsCompanion.insert({
    this.partNo = const Value.absent(),
    this.stationHi = const Value.absent(),
  });
  static Insertable<BoothRow> custom({
    Expression<int>? partNo,
    Expression<String>? stationHi,
  }) {
    return RawValuesInsertable({
      if (partNo != null) 'part_no': partNo,
      if (stationHi != null) 'station_hi': stationHi,
    });
  }

  BoothsCompanion copyWith({Value<int>? partNo, Value<String?>? stationHi}) {
    return BoothsCompanion(
      partNo: partNo ?? this.partNo,
      stationHi: stationHi ?? this.stationHi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (partNo.present) {
      map['part_no'] = Variable<int>(partNo.value);
    }
    if (stationHi.present) {
      map['station_hi'] = Variable<String>(stationHi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoothsCompanion(')
          ..write('partNo: $partNo, ')
          ..write('stationHi: $stationHi')
          ..write(')'))
        .toString();
  }
}

class $FamiliesTable extends Families
    with TableInfo<$FamiliesTable, FamilyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partNoMeta = const VerificationMeta('partNo');
  @override
  late final GeneratedColumn<int> partNo = GeneratedColumn<int>(
    'part_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionNoMeta = const VerificationMeta(
    'sectionNo',
  );
  @override
  late final GeneratedColumn<int> sectionNo = GeneratedColumn<int>(
    'section_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _houseNoMeta = const VerificationMeta(
    'houseNo',
  );
  @override
  late final GeneratedColumn<String> houseNo = GeneratedColumn<String>(
    'house_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headNameHiMeta = const VerificationMeta(
    'headNameHi',
  );
  @override
  late final GeneratedColumn<String> headNameHi = GeneratedColumn<String>(
    'head_name_hi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    partNo,
    sectionNo,
    houseNo,
    headNameHi,
    priority,
    needsReview,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'families';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('part_no')) {
      context.handle(
        _partNoMeta,
        partNo.isAcceptableOrUnknown(data['part_no']!, _partNoMeta),
      );
    } else if (isInserting) {
      context.missing(_partNoMeta);
    }
    if (data.containsKey('section_no')) {
      context.handle(
        _sectionNoMeta,
        sectionNo.isAcceptableOrUnknown(data['section_no']!, _sectionNoMeta),
      );
    }
    if (data.containsKey('house_no')) {
      context.handle(
        _houseNoMeta,
        houseNo.isAcceptableOrUnknown(data['house_no']!, _houseNoMeta),
      );
    }
    if (data.containsKey('head_name_hi')) {
      context.handle(
        _headNameHiMeta,
        headNameHi.isAcceptableOrUnknown(
          data['head_name_hi']!,
          _headNameHiMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      partNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_no'],
      )!,
      sectionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_no'],
      ),
      houseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_no'],
      ),
      headNameHi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}head_name_hi'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $FamiliesTable createAlias(String alias) {
    return $FamiliesTable(attachedDatabase, alias);
  }
}

class FamilyRow extends DataClass implements Insertable<FamilyRow> {
  final String id;
  final String code;
  final int partNo;
  final int? sectionNo;
  final String? houseNo;
  final String? headNameHi;
  final int priority;
  final bool needsReview;
  final bool pending;
  const FamilyRow({
    required this.id,
    required this.code,
    required this.partNo,
    this.sectionNo,
    this.houseNo,
    this.headNameHi,
    required this.priority,
    required this.needsReview,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['part_no'] = Variable<int>(partNo);
    if (!nullToAbsent || sectionNo != null) {
      map['section_no'] = Variable<int>(sectionNo);
    }
    if (!nullToAbsent || houseNo != null) {
      map['house_no'] = Variable<String>(houseNo);
    }
    if (!nullToAbsent || headNameHi != null) {
      map['head_name_hi'] = Variable<String>(headNameHi);
    }
    map['priority'] = Variable<int>(priority);
    map['needs_review'] = Variable<bool>(needsReview);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  FamiliesCompanion toCompanion(bool nullToAbsent) {
    return FamiliesCompanion(
      id: Value(id),
      code: Value(code),
      partNo: Value(partNo),
      sectionNo: sectionNo == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionNo),
      houseNo: houseNo == null && nullToAbsent
          ? const Value.absent()
          : Value(houseNo),
      headNameHi: headNameHi == null && nullToAbsent
          ? const Value.absent()
          : Value(headNameHi),
      priority: Value(priority),
      needsReview: Value(needsReview),
      pending: Value(pending),
    );
  }

  factory FamilyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      partNo: serializer.fromJson<int>(json['partNo']),
      sectionNo: serializer.fromJson<int?>(json['sectionNo']),
      houseNo: serializer.fromJson<String?>(json['houseNo']),
      headNameHi: serializer.fromJson<String?>(json['headNameHi']),
      priority: serializer.fromJson<int>(json['priority']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'partNo': serializer.toJson<int>(partNo),
      'sectionNo': serializer.toJson<int?>(sectionNo),
      'houseNo': serializer.toJson<String?>(houseNo),
      'headNameHi': serializer.toJson<String?>(headNameHi),
      'priority': serializer.toJson<int>(priority),
      'needsReview': serializer.toJson<bool>(needsReview),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  FamilyRow copyWith({
    String? id,
    String? code,
    int? partNo,
    Value<int?> sectionNo = const Value.absent(),
    Value<String?> houseNo = const Value.absent(),
    Value<String?> headNameHi = const Value.absent(),
    int? priority,
    bool? needsReview,
    bool? pending,
  }) => FamilyRow(
    id: id ?? this.id,
    code: code ?? this.code,
    partNo: partNo ?? this.partNo,
    sectionNo: sectionNo.present ? sectionNo.value : this.sectionNo,
    houseNo: houseNo.present ? houseNo.value : this.houseNo,
    headNameHi: headNameHi.present ? headNameHi.value : this.headNameHi,
    priority: priority ?? this.priority,
    needsReview: needsReview ?? this.needsReview,
    pending: pending ?? this.pending,
  );
  FamilyRow copyWithCompanion(FamiliesCompanion data) {
    return FamilyRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      partNo: data.partNo.present ? data.partNo.value : this.partNo,
      sectionNo: data.sectionNo.present ? data.sectionNo.value : this.sectionNo,
      houseNo: data.houseNo.present ? data.houseNo.value : this.houseNo,
      headNameHi: data.headNameHi.present
          ? data.headNameHi.value
          : this.headNameHi,
      priority: data.priority.present ? data.priority.value : this.priority,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('partNo: $partNo, ')
          ..write('sectionNo: $sectionNo, ')
          ..write('houseNo: $houseNo, ')
          ..write('headNameHi: $headNameHi, ')
          ..write('priority: $priority, ')
          ..write('needsReview: $needsReview, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    partNo,
    sectionNo,
    houseNo,
    headNameHi,
    priority,
    needsReview,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.partNo == this.partNo &&
          other.sectionNo == this.sectionNo &&
          other.houseNo == this.houseNo &&
          other.headNameHi == this.headNameHi &&
          other.priority == this.priority &&
          other.needsReview == this.needsReview &&
          other.pending == this.pending);
}

class FamiliesCompanion extends UpdateCompanion<FamilyRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<int> partNo;
  final Value<int?> sectionNo;
  final Value<String?> houseNo;
  final Value<String?> headNameHi;
  final Value<int> priority;
  final Value<bool> needsReview;
  final Value<bool> pending;
  final Value<int> rowid;
  const FamiliesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.partNo = const Value.absent(),
    this.sectionNo = const Value.absent(),
    this.houseNo = const Value.absent(),
    this.headNameHi = const Value.absent(),
    this.priority = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamiliesCompanion.insert({
    required String id,
    required String code,
    required int partNo,
    this.sectionNo = const Value.absent(),
    this.houseNo = const Value.absent(),
    this.headNameHi = const Value.absent(),
    required int priority,
    this.needsReview = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       partNo = Value(partNo),
       priority = Value(priority);
  static Insertable<FamilyRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<int>? partNo,
    Expression<int>? sectionNo,
    Expression<String>? houseNo,
    Expression<String>? headNameHi,
    Expression<int>? priority,
    Expression<bool>? needsReview,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (partNo != null) 'part_no': partNo,
      if (sectionNo != null) 'section_no': sectionNo,
      if (houseNo != null) 'house_no': houseNo,
      if (headNameHi != null) 'head_name_hi': headNameHi,
      if (priority != null) 'priority': priority,
      if (needsReview != null) 'needs_review': needsReview,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamiliesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<int>? partNo,
    Value<int?>? sectionNo,
    Value<String?>? houseNo,
    Value<String?>? headNameHi,
    Value<int>? priority,
    Value<bool>? needsReview,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return FamiliesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      partNo: partNo ?? this.partNo,
      sectionNo: sectionNo ?? this.sectionNo,
      houseNo: houseNo ?? this.houseNo,
      headNameHi: headNameHi ?? this.headNameHi,
      priority: priority ?? this.priority,
      needsReview: needsReview ?? this.needsReview,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (partNo.present) {
      map['part_no'] = Variable<int>(partNo.value);
    }
    if (sectionNo.present) {
      map['section_no'] = Variable<int>(sectionNo.value);
    }
    if (houseNo.present) {
      map['house_no'] = Variable<String>(houseNo.value);
    }
    if (headNameHi.present) {
      map['head_name_hi'] = Variable<String>(headNameHi.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamiliesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('partNo: $partNo, ')
          ..write('sectionNo: $sectionNo, ')
          ..write('houseNo: $houseNo, ')
          ..write('headNameHi: $headNameHi, ')
          ..write('priority: $priority, ')
          ..write('needsReview: $needsReview, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VotersTable extends Voters with TableInfo<$VotersTable, VoterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VotersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _epicMeta = const VerificationMeta('epic');
  @override
  late final GeneratedColumn<String> epic = GeneratedColumn<String>(
    'epic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameHiMeta = const VerificationMeta('nameHi');
  @override
  late final GeneratedColumn<String> nameHi = GeneratedColumn<String>(
    'name_hi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relativeNameHiMeta = const VerificationMeta(
    'relativeNameHi',
  );
  @override
  late final GeneratedColumn<String> relativeNameHi = GeneratedColumn<String>(
    'relative_name_hi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceListMeta = const VerificationMeta(
    'sourceList',
  );
  @override
  late final GeneratedColumn<String> sourceList = GeneratedColumn<String>(
    'source_list',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asddReasonMeta = const VerificationMeta(
    'asddReason',
  );
  @override
  late final GeneratedColumn<String> asddReason = GeneratedColumn<String>(
    'asdd_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchConfidenceMeta = const VerificationMeta(
    'matchConfidence',
  );
  @override
  late final GeneratedColumn<String> matchConfidence = GeneratedColumn<String>(
    'match_confidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldPartNoMeta = const VerificationMeta(
    'oldPartNo',
  );
  @override
  late final GeneratedColumn<int> oldPartNo = GeneratedColumn<int>(
    'old_part_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldSerialMeta = const VerificationMeta(
    'oldSerial',
  );
  @override
  late final GeneratedColumn<int> oldSerial = GeneratedColumn<int>(
    'old_serial',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alreadyOnRollMeta = const VerificationMeta(
    'alreadyOnRoll',
  );
  @override
  late final GeneratedColumn<bool> alreadyOnRoll = GeneratedColumn<bool>(
    'already_on_roll',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("already_on_roll" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closest2026Meta = const VerificationMeta(
    'closest2026',
  );
  @override
  late final GeneratedColumn<String> closest2026 = GeneratedColumn<String>(
    'closest2026',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newReasonMeta = const VerificationMeta(
    'newReason',
  );
  @override
  late final GeneratedColumn<String> newReason = GeneratedColumn<String>(
    'new_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newReasonNoteMeta = const VerificationMeta(
    'newReasonNote',
  );
  @override
  late final GeneratedColumn<String> newReasonNote = GeneratedColumn<String>(
    'new_reason_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _draftPartMeta = const VerificationMeta(
    'draftPart',
  );
  @override
  late final GeneratedColumn<int> draftPart = GeneratedColumn<int>(
    'draft_part',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _draftSectionMeta = const VerificationMeta(
    'draftSection',
  );
  @override
  late final GeneratedColumn<String> draftSection = GeneratedColumn<String>(
    'draft_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    epic,
    nameHi,
    relationType,
    relativeNameHi,
    age,
    gender,
    sourceList,
    asddReason,
    matchConfidence,
    oldPartNo,
    oldSerial,
    alreadyOnRoll,
    category,
    closest2026,
    newReason,
    newReasonNote,
    draftPart,
    draftSection,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voters';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('epic')) {
      context.handle(
        _epicMeta,
        epic.isAcceptableOrUnknown(data['epic']!, _epicMeta),
      );
    }
    if (data.containsKey('name_hi')) {
      context.handle(
        _nameHiMeta,
        nameHi.isAcceptableOrUnknown(data['name_hi']!, _nameHiMeta),
      );
    } else if (isInserting) {
      context.missing(_nameHiMeta);
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    }
    if (data.containsKey('relative_name_hi')) {
      context.handle(
        _relativeNameHiMeta,
        relativeNameHi.isAcceptableOrUnknown(
          data['relative_name_hi']!,
          _relativeNameHiMeta,
        ),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('source_list')) {
      context.handle(
        _sourceListMeta,
        sourceList.isAcceptableOrUnknown(data['source_list']!, _sourceListMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceListMeta);
    }
    if (data.containsKey('asdd_reason')) {
      context.handle(
        _asddReasonMeta,
        asddReason.isAcceptableOrUnknown(data['asdd_reason']!, _asddReasonMeta),
      );
    }
    if (data.containsKey('match_confidence')) {
      context.handle(
        _matchConfidenceMeta,
        matchConfidence.isAcceptableOrUnknown(
          data['match_confidence']!,
          _matchConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('old_part_no')) {
      context.handle(
        _oldPartNoMeta,
        oldPartNo.isAcceptableOrUnknown(data['old_part_no']!, _oldPartNoMeta),
      );
    }
    if (data.containsKey('old_serial')) {
      context.handle(
        _oldSerialMeta,
        oldSerial.isAcceptableOrUnknown(data['old_serial']!, _oldSerialMeta),
      );
    }
    if (data.containsKey('already_on_roll')) {
      context.handle(
        _alreadyOnRollMeta,
        alreadyOnRoll.isAcceptableOrUnknown(
          data['already_on_roll']!,
          _alreadyOnRollMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('closest2026')) {
      context.handle(
        _closest2026Meta,
        closest2026.isAcceptableOrUnknown(
          data['closest2026']!,
          _closest2026Meta,
        ),
      );
    }
    if (data.containsKey('new_reason')) {
      context.handle(
        _newReasonMeta,
        newReason.isAcceptableOrUnknown(data['new_reason']!, _newReasonMeta),
      );
    }
    if (data.containsKey('new_reason_note')) {
      context.handle(
        _newReasonNoteMeta,
        newReasonNote.isAcceptableOrUnknown(
          data['new_reason_note']!,
          _newReasonNoteMeta,
        ),
      );
    }
    if (data.containsKey('draft_part')) {
      context.handle(
        _draftPartMeta,
        draftPart.isAcceptableOrUnknown(data['draft_part']!, _draftPartMeta),
      );
    }
    if (data.containsKey('draft_section')) {
      context.handle(
        _draftSectionMeta,
        draftSection.isAcceptableOrUnknown(
          data['draft_section']!,
          _draftSectionMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      epic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epic'],
      ),
      nameHi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_hi'],
      )!,
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      ),
      relativeNameHi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_name_hi'],
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      sourceList: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_list'],
      )!,
      asddReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asdd_reason'],
      ),
      matchConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_confidence'],
      ),
      oldPartNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_part_no'],
      ),
      oldSerial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_serial'],
      ),
      alreadyOnRoll: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}already_on_roll'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      closest2026: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closest2026'],
      ),
      newReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_reason'],
      ),
      newReasonNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_reason_note'],
      ),
      draftPart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draft_part'],
      ),
      draftSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_section'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $VotersTable createAlias(String alias) {
    return $VotersTable(attachedDatabase, alias);
  }
}

class VoterRow extends DataClass implements Insertable<VoterRow> {
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
  final String? newReason;
  final String? newReasonNote;
  final int? draftPart;
  final String? draftSection;
  final bool pending;
  const VoterRow({
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
    required this.alreadyOnRoll,
    this.category,
    this.closest2026,
    this.newReason,
    this.newReasonNote,
    this.draftPart,
    this.draftSection,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    if (!nullToAbsent || epic != null) {
      map['epic'] = Variable<String>(epic);
    }
    map['name_hi'] = Variable<String>(nameHi);
    if (!nullToAbsent || relationType != null) {
      map['relation_type'] = Variable<String>(relationType);
    }
    if (!nullToAbsent || relativeNameHi != null) {
      map['relative_name_hi'] = Variable<String>(relativeNameHi);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    map['source_list'] = Variable<String>(sourceList);
    if (!nullToAbsent || asddReason != null) {
      map['asdd_reason'] = Variable<String>(asddReason);
    }
    if (!nullToAbsent || matchConfidence != null) {
      map['match_confidence'] = Variable<String>(matchConfidence);
    }
    if (!nullToAbsent || oldPartNo != null) {
      map['old_part_no'] = Variable<int>(oldPartNo);
    }
    if (!nullToAbsent || oldSerial != null) {
      map['old_serial'] = Variable<int>(oldSerial);
    }
    map['already_on_roll'] = Variable<bool>(alreadyOnRoll);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || closest2026 != null) {
      map['closest2026'] = Variable<String>(closest2026);
    }
    if (!nullToAbsent || newReason != null) {
      map['new_reason'] = Variable<String>(newReason);
    }
    if (!nullToAbsent || newReasonNote != null) {
      map['new_reason_note'] = Variable<String>(newReasonNote);
    }
    if (!nullToAbsent || draftPart != null) {
      map['draft_part'] = Variable<int>(draftPart);
    }
    if (!nullToAbsent || draftSection != null) {
      map['draft_section'] = Variable<String>(draftSection);
    }
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  VotersCompanion toCompanion(bool nullToAbsent) {
    return VotersCompanion(
      id: Value(id),
      familyId: Value(familyId),
      epic: epic == null && nullToAbsent ? const Value.absent() : Value(epic),
      nameHi: Value(nameHi),
      relationType: relationType == null && nullToAbsent
          ? const Value.absent()
          : Value(relationType),
      relativeNameHi: relativeNameHi == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeNameHi),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      sourceList: Value(sourceList),
      asddReason: asddReason == null && nullToAbsent
          ? const Value.absent()
          : Value(asddReason),
      matchConfidence: matchConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(matchConfidence),
      oldPartNo: oldPartNo == null && nullToAbsent
          ? const Value.absent()
          : Value(oldPartNo),
      oldSerial: oldSerial == null && nullToAbsent
          ? const Value.absent()
          : Value(oldSerial),
      alreadyOnRoll: Value(alreadyOnRoll),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      closest2026: closest2026 == null && nullToAbsent
          ? const Value.absent()
          : Value(closest2026),
      newReason: newReason == null && nullToAbsent
          ? const Value.absent()
          : Value(newReason),
      newReasonNote: newReasonNote == null && nullToAbsent
          ? const Value.absent()
          : Value(newReasonNote),
      draftPart: draftPart == null && nullToAbsent
          ? const Value.absent()
          : Value(draftPart),
      draftSection: draftSection == null && nullToAbsent
          ? const Value.absent()
          : Value(draftSection),
      pending: Value(pending),
    );
  }

  factory VoterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoterRow(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      epic: serializer.fromJson<String?>(json['epic']),
      nameHi: serializer.fromJson<String>(json['nameHi']),
      relationType: serializer.fromJson<String?>(json['relationType']),
      relativeNameHi: serializer.fromJson<String?>(json['relativeNameHi']),
      age: serializer.fromJson<int?>(json['age']),
      gender: serializer.fromJson<String?>(json['gender']),
      sourceList: serializer.fromJson<String>(json['sourceList']),
      asddReason: serializer.fromJson<String?>(json['asddReason']),
      matchConfidence: serializer.fromJson<String?>(json['matchConfidence']),
      oldPartNo: serializer.fromJson<int?>(json['oldPartNo']),
      oldSerial: serializer.fromJson<int?>(json['oldSerial']),
      alreadyOnRoll: serializer.fromJson<bool>(json['alreadyOnRoll']),
      category: serializer.fromJson<String?>(json['category']),
      closest2026: serializer.fromJson<String?>(json['closest2026']),
      newReason: serializer.fromJson<String?>(json['newReason']),
      newReasonNote: serializer.fromJson<String?>(json['newReasonNote']),
      draftPart: serializer.fromJson<int?>(json['draftPart']),
      draftSection: serializer.fromJson<String?>(json['draftSection']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'epic': serializer.toJson<String?>(epic),
      'nameHi': serializer.toJson<String>(nameHi),
      'relationType': serializer.toJson<String?>(relationType),
      'relativeNameHi': serializer.toJson<String?>(relativeNameHi),
      'age': serializer.toJson<int?>(age),
      'gender': serializer.toJson<String?>(gender),
      'sourceList': serializer.toJson<String>(sourceList),
      'asddReason': serializer.toJson<String?>(asddReason),
      'matchConfidence': serializer.toJson<String?>(matchConfidence),
      'oldPartNo': serializer.toJson<int?>(oldPartNo),
      'oldSerial': serializer.toJson<int?>(oldSerial),
      'alreadyOnRoll': serializer.toJson<bool>(alreadyOnRoll),
      'category': serializer.toJson<String?>(category),
      'closest2026': serializer.toJson<String?>(closest2026),
      'newReason': serializer.toJson<String?>(newReason),
      'newReasonNote': serializer.toJson<String?>(newReasonNote),
      'draftPart': serializer.toJson<int?>(draftPart),
      'draftSection': serializer.toJson<String?>(draftSection),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  VoterRow copyWith({
    String? id,
    String? familyId,
    Value<String?> epic = const Value.absent(),
    String? nameHi,
    Value<String?> relationType = const Value.absent(),
    Value<String?> relativeNameHi = const Value.absent(),
    Value<int?> age = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    String? sourceList,
    Value<String?> asddReason = const Value.absent(),
    Value<String?> matchConfidence = const Value.absent(),
    Value<int?> oldPartNo = const Value.absent(),
    Value<int?> oldSerial = const Value.absent(),
    bool? alreadyOnRoll,
    Value<String?> category = const Value.absent(),
    Value<String?> closest2026 = const Value.absent(),
    Value<String?> newReason = const Value.absent(),
    Value<String?> newReasonNote = const Value.absent(),
    Value<int?> draftPart = const Value.absent(),
    Value<String?> draftSection = const Value.absent(),
    bool? pending,
  }) => VoterRow(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    epic: epic.present ? epic.value : this.epic,
    nameHi: nameHi ?? this.nameHi,
    relationType: relationType.present ? relationType.value : this.relationType,
    relativeNameHi: relativeNameHi.present
        ? relativeNameHi.value
        : this.relativeNameHi,
    age: age.present ? age.value : this.age,
    gender: gender.present ? gender.value : this.gender,
    sourceList: sourceList ?? this.sourceList,
    asddReason: asddReason.present ? asddReason.value : this.asddReason,
    matchConfidence: matchConfidence.present
        ? matchConfidence.value
        : this.matchConfidence,
    oldPartNo: oldPartNo.present ? oldPartNo.value : this.oldPartNo,
    oldSerial: oldSerial.present ? oldSerial.value : this.oldSerial,
    alreadyOnRoll: alreadyOnRoll ?? this.alreadyOnRoll,
    category: category.present ? category.value : this.category,
    closest2026: closest2026.present ? closest2026.value : this.closest2026,
    newReason: newReason.present ? newReason.value : this.newReason,
    newReasonNote: newReasonNote.present
        ? newReasonNote.value
        : this.newReasonNote,
    draftPart: draftPart.present ? draftPart.value : this.draftPart,
    draftSection: draftSection.present ? draftSection.value : this.draftSection,
    pending: pending ?? this.pending,
  );
  VoterRow copyWithCompanion(VotersCompanion data) {
    return VoterRow(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      epic: data.epic.present ? data.epic.value : this.epic,
      nameHi: data.nameHi.present ? data.nameHi.value : this.nameHi,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      relativeNameHi: data.relativeNameHi.present
          ? data.relativeNameHi.value
          : this.relativeNameHi,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      sourceList: data.sourceList.present
          ? data.sourceList.value
          : this.sourceList,
      asddReason: data.asddReason.present
          ? data.asddReason.value
          : this.asddReason,
      matchConfidence: data.matchConfidence.present
          ? data.matchConfidence.value
          : this.matchConfidence,
      oldPartNo: data.oldPartNo.present ? data.oldPartNo.value : this.oldPartNo,
      oldSerial: data.oldSerial.present ? data.oldSerial.value : this.oldSerial,
      alreadyOnRoll: data.alreadyOnRoll.present
          ? data.alreadyOnRoll.value
          : this.alreadyOnRoll,
      category: data.category.present ? data.category.value : this.category,
      closest2026: data.closest2026.present
          ? data.closest2026.value
          : this.closest2026,
      newReason: data.newReason.present ? data.newReason.value : this.newReason,
      newReasonNote: data.newReasonNote.present
          ? data.newReasonNote.value
          : this.newReasonNote,
      draftPart: data.draftPart.present ? data.draftPart.value : this.draftPart,
      draftSection: data.draftSection.present
          ? data.draftSection.value
          : this.draftSection,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoterRow(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('epic: $epic, ')
          ..write('nameHi: $nameHi, ')
          ..write('relationType: $relationType, ')
          ..write('relativeNameHi: $relativeNameHi, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('sourceList: $sourceList, ')
          ..write('asddReason: $asddReason, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('oldPartNo: $oldPartNo, ')
          ..write('oldSerial: $oldSerial, ')
          ..write('alreadyOnRoll: $alreadyOnRoll, ')
          ..write('category: $category, ')
          ..write('closest2026: $closest2026, ')
          ..write('newReason: $newReason, ')
          ..write('newReasonNote: $newReasonNote, ')
          ..write('draftPart: $draftPart, ')
          ..write('draftSection: $draftSection, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    familyId,
    epic,
    nameHi,
    relationType,
    relativeNameHi,
    age,
    gender,
    sourceList,
    asddReason,
    matchConfidence,
    oldPartNo,
    oldSerial,
    alreadyOnRoll,
    category,
    closest2026,
    newReason,
    newReasonNote,
    draftPart,
    draftSection,
    pending,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoterRow &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.epic == this.epic &&
          other.nameHi == this.nameHi &&
          other.relationType == this.relationType &&
          other.relativeNameHi == this.relativeNameHi &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.sourceList == this.sourceList &&
          other.asddReason == this.asddReason &&
          other.matchConfidence == this.matchConfidence &&
          other.oldPartNo == this.oldPartNo &&
          other.oldSerial == this.oldSerial &&
          other.alreadyOnRoll == this.alreadyOnRoll &&
          other.category == this.category &&
          other.closest2026 == this.closest2026 &&
          other.newReason == this.newReason &&
          other.newReasonNote == this.newReasonNote &&
          other.draftPart == this.draftPart &&
          other.draftSection == this.draftSection &&
          other.pending == this.pending);
}

class VotersCompanion extends UpdateCompanion<VoterRow> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<String?> epic;
  final Value<String> nameHi;
  final Value<String?> relationType;
  final Value<String?> relativeNameHi;
  final Value<int?> age;
  final Value<String?> gender;
  final Value<String> sourceList;
  final Value<String?> asddReason;
  final Value<String?> matchConfidence;
  final Value<int?> oldPartNo;
  final Value<int?> oldSerial;
  final Value<bool> alreadyOnRoll;
  final Value<String?> category;
  final Value<String?> closest2026;
  final Value<String?> newReason;
  final Value<String?> newReasonNote;
  final Value<int?> draftPart;
  final Value<String?> draftSection;
  final Value<bool> pending;
  final Value<int> rowid;
  const VotersCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.epic = const Value.absent(),
    this.nameHi = const Value.absent(),
    this.relationType = const Value.absent(),
    this.relativeNameHi = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.sourceList = const Value.absent(),
    this.asddReason = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.oldPartNo = const Value.absent(),
    this.oldSerial = const Value.absent(),
    this.alreadyOnRoll = const Value.absent(),
    this.category = const Value.absent(),
    this.closest2026 = const Value.absent(),
    this.newReason = const Value.absent(),
    this.newReasonNote = const Value.absent(),
    this.draftPart = const Value.absent(),
    this.draftSection = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VotersCompanion.insert({
    required String id,
    required String familyId,
    this.epic = const Value.absent(),
    required String nameHi,
    this.relationType = const Value.absent(),
    this.relativeNameHi = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    required String sourceList,
    this.asddReason = const Value.absent(),
    this.matchConfidence = const Value.absent(),
    this.oldPartNo = const Value.absent(),
    this.oldSerial = const Value.absent(),
    this.alreadyOnRoll = const Value.absent(),
    this.category = const Value.absent(),
    this.closest2026 = const Value.absent(),
    this.newReason = const Value.absent(),
    this.newReasonNote = const Value.absent(),
    this.draftPart = const Value.absent(),
    this.draftSection = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       nameHi = Value(nameHi),
       sourceList = Value(sourceList);
  static Insertable<VoterRow> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? epic,
    Expression<String>? nameHi,
    Expression<String>? relationType,
    Expression<String>? relativeNameHi,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<String>? sourceList,
    Expression<String>? asddReason,
    Expression<String>? matchConfidence,
    Expression<int>? oldPartNo,
    Expression<int>? oldSerial,
    Expression<bool>? alreadyOnRoll,
    Expression<String>? category,
    Expression<String>? closest2026,
    Expression<String>? newReason,
    Expression<String>? newReasonNote,
    Expression<int>? draftPart,
    Expression<String>? draftSection,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (epic != null) 'epic': epic,
      if (nameHi != null) 'name_hi': nameHi,
      if (relationType != null) 'relation_type': relationType,
      if (relativeNameHi != null) 'relative_name_hi': relativeNameHi,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (sourceList != null) 'source_list': sourceList,
      if (asddReason != null) 'asdd_reason': asddReason,
      if (matchConfidence != null) 'match_confidence': matchConfidence,
      if (oldPartNo != null) 'old_part_no': oldPartNo,
      if (oldSerial != null) 'old_serial': oldSerial,
      if (alreadyOnRoll != null) 'already_on_roll': alreadyOnRoll,
      if (category != null) 'category': category,
      if (closest2026 != null) 'closest2026': closest2026,
      if (newReason != null) 'new_reason': newReason,
      if (newReasonNote != null) 'new_reason_note': newReasonNote,
      if (draftPart != null) 'draft_part': draftPart,
      if (draftSection != null) 'draft_section': draftSection,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VotersCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<String?>? epic,
    Value<String>? nameHi,
    Value<String?>? relationType,
    Value<String?>? relativeNameHi,
    Value<int?>? age,
    Value<String?>? gender,
    Value<String>? sourceList,
    Value<String?>? asddReason,
    Value<String?>? matchConfidence,
    Value<int?>? oldPartNo,
    Value<int?>? oldSerial,
    Value<bool>? alreadyOnRoll,
    Value<String?>? category,
    Value<String?>? closest2026,
    Value<String?>? newReason,
    Value<String?>? newReasonNote,
    Value<int?>? draftPart,
    Value<String?>? draftSection,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return VotersCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      epic: epic ?? this.epic,
      nameHi: nameHi ?? this.nameHi,
      relationType: relationType ?? this.relationType,
      relativeNameHi: relativeNameHi ?? this.relativeNameHi,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      sourceList: sourceList ?? this.sourceList,
      asddReason: asddReason ?? this.asddReason,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      oldPartNo: oldPartNo ?? this.oldPartNo,
      oldSerial: oldSerial ?? this.oldSerial,
      alreadyOnRoll: alreadyOnRoll ?? this.alreadyOnRoll,
      category: category ?? this.category,
      closest2026: closest2026 ?? this.closest2026,
      newReason: newReason ?? this.newReason,
      newReasonNote: newReasonNote ?? this.newReasonNote,
      draftPart: draftPart ?? this.draftPart,
      draftSection: draftSection ?? this.draftSection,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (epic.present) {
      map['epic'] = Variable<String>(epic.value);
    }
    if (nameHi.present) {
      map['name_hi'] = Variable<String>(nameHi.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (relativeNameHi.present) {
      map['relative_name_hi'] = Variable<String>(relativeNameHi.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (sourceList.present) {
      map['source_list'] = Variable<String>(sourceList.value);
    }
    if (asddReason.present) {
      map['asdd_reason'] = Variable<String>(asddReason.value);
    }
    if (matchConfidence.present) {
      map['match_confidence'] = Variable<String>(matchConfidence.value);
    }
    if (oldPartNo.present) {
      map['old_part_no'] = Variable<int>(oldPartNo.value);
    }
    if (oldSerial.present) {
      map['old_serial'] = Variable<int>(oldSerial.value);
    }
    if (alreadyOnRoll.present) {
      map['already_on_roll'] = Variable<bool>(alreadyOnRoll.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (closest2026.present) {
      map['closest2026'] = Variable<String>(closest2026.value);
    }
    if (newReason.present) {
      map['new_reason'] = Variable<String>(newReason.value);
    }
    if (newReasonNote.present) {
      map['new_reason_note'] = Variable<String>(newReasonNote.value);
    }
    if (draftPart.present) {
      map['draft_part'] = Variable<int>(draftPart.value);
    }
    if (draftSection.present) {
      map['draft_section'] = Variable<String>(draftSection.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VotersCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('epic: $epic, ')
          ..write('nameHi: $nameHi, ')
          ..write('relationType: $relationType, ')
          ..write('relativeNameHi: $relativeNameHi, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('sourceList: $sourceList, ')
          ..write('asddReason: $asddReason, ')
          ..write('matchConfidence: $matchConfidence, ')
          ..write('oldPartNo: $oldPartNo, ')
          ..write('oldSerial: $oldSerial, ')
          ..write('alreadyOnRoll: $alreadyOnRoll, ')
          ..write('category: $category, ')
          ..write('closest2026: $closest2026, ')
          ..write('newReason: $newReason, ')
          ..write('newReasonNote: $newReasonNote, ')
          ..write('draftPart: $draftPart, ')
          ..write('draftSection: $draftSection, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, VisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byMeMeta = const VerificationMeta('byMe');
  @override
  late final GeneratedColumn<bool> byMe = GeneratedColumn<bool>(
    'by_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("by_me" IN (0, 1))',
    ),
  );
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisitOnMeta = const VerificationMeta(
    'revisitOn',
  );
  @override
  late final GeneratedColumn<String> revisitOn = GeneratedColumn<String>(
    'revisit_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    byMe,
    visitedAt,
    outcome,
    revisitOn,
    remarks,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('by_me')) {
      context.handle(
        _byMeMeta,
        byMe.isAcceptableOrUnknown(data['by_me']!, _byMeMeta),
      );
    } else if (isInserting) {
      context.missing(_byMeMeta);
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_visitedAtMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('revisit_on')) {
      context.handle(
        _revisitOnMeta,
        revisitOn.isAcceptableOrUnknown(data['revisit_on']!, _revisitOnMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      byMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}by_me'],
      )!,
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      revisitOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revisit_on'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class VisitRow extends DataClass implements Insertable<VisitRow> {
  final String id;
  final String familyId;
  final bool byMe;
  final DateTime visitedAt;
  final String outcome;
  final String? revisitOn;
  final String? remarks;
  final bool pending;
  const VisitRow({
    required this.id,
    required this.familyId,
    required this.byMe,
    required this.visitedAt,
    required this.outcome,
    this.revisitOn,
    this.remarks,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['by_me'] = Variable<bool>(byMe);
    map['visited_at'] = Variable<DateTime>(visitedAt);
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || revisitOn != null) {
      map['revisit_on'] = Variable<String>(revisitOn);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      familyId: Value(familyId),
      byMe: Value(byMe),
      visitedAt: Value(visitedAt),
      outcome: Value(outcome),
      revisitOn: revisitOn == null && nullToAbsent
          ? const Value.absent()
          : Value(revisitOn),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      pending: Value(pending),
    );
  }

  factory VisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitRow(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      byMe: serializer.fromJson<bool>(json['byMe']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
      outcome: serializer.fromJson<String>(json['outcome']),
      revisitOn: serializer.fromJson<String?>(json['revisitOn']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'byMe': serializer.toJson<bool>(byMe),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
      'outcome': serializer.toJson<String>(outcome),
      'revisitOn': serializer.toJson<String?>(revisitOn),
      'remarks': serializer.toJson<String?>(remarks),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  VisitRow copyWith({
    String? id,
    String? familyId,
    bool? byMe,
    DateTime? visitedAt,
    String? outcome,
    Value<String?> revisitOn = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    bool? pending,
  }) => VisitRow(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    byMe: byMe ?? this.byMe,
    visitedAt: visitedAt ?? this.visitedAt,
    outcome: outcome ?? this.outcome,
    revisitOn: revisitOn.present ? revisitOn.value : this.revisitOn,
    remarks: remarks.present ? remarks.value : this.remarks,
    pending: pending ?? this.pending,
  );
  VisitRow copyWithCompanion(VisitsCompanion data) {
    return VisitRow(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      byMe: data.byMe.present ? data.byMe.value : this.byMe,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      revisitOn: data.revisitOn.present ? data.revisitOn.value : this.revisitOn,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitRow(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('byMe: $byMe, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('outcome: $outcome, ')
          ..write('revisitOn: $revisitOn, ')
          ..write('remarks: $remarks, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    byMe,
    visitedAt,
    outcome,
    revisitOn,
    remarks,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitRow &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.byMe == this.byMe &&
          other.visitedAt == this.visitedAt &&
          other.outcome == this.outcome &&
          other.revisitOn == this.revisitOn &&
          other.remarks == this.remarks &&
          other.pending == this.pending);
}

class VisitsCompanion extends UpdateCompanion<VisitRow> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<bool> byMe;
  final Value<DateTime> visitedAt;
  final Value<String> outcome;
  final Value<String?> revisitOn;
  final Value<String?> remarks;
  final Value<bool> pending;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.byMe = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.revisitOn = const Value.absent(),
    this.remarks = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String familyId,
    required bool byMe,
    required DateTime visitedAt,
    required String outcome,
    this.revisitOn = const Value.absent(),
    this.remarks = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       byMe = Value(byMe),
       visitedAt = Value(visitedAt),
       outcome = Value(outcome);
  static Insertable<VisitRow> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<bool>? byMe,
    Expression<DateTime>? visitedAt,
    Expression<String>? outcome,
    Expression<String>? revisitOn,
    Expression<String>? remarks,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (byMe != null) 'by_me': byMe,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (outcome != null) 'outcome': outcome,
      if (revisitOn != null) 'revisit_on': revisitOn,
      if (remarks != null) 'remarks': remarks,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<bool>? byMe,
    Value<DateTime>? visitedAt,
    Value<String>? outcome,
    Value<String?>? revisitOn,
    Value<String?>? remarks,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      byMe: byMe ?? this.byMe,
      visitedAt: visitedAt ?? this.visitedAt,
      outcome: outcome ?? this.outcome,
      revisitOn: revisitOn ?? this.revisitOn,
      remarks: remarks ?? this.remarks,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (byMe.present) {
      map['by_me'] = Variable<bool>(byMe.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (revisitOn.present) {
      map['revisit_on'] = Variable<String>(revisitOn.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('byMe: $byMe, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('outcome: $outcome, ')
          ..write('revisitOn: $revisitOn, ')
          ..write('remarks: $remarks, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitVotersTable extends VisitVoters
    with TableInfo<$VisitVotersTable, VisitVoterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitVotersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voterIdMeta = const VerificationMeta(
    'voterId',
  );
  @override
  late final GeneratedColumn<String> voterId = GeneratedColumn<String>(
    'voter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voterOutcomeMeta = const VerificationMeta(
    'voterOutcome',
  );
  @override
  late final GeneratedColumn<String> voterOutcome = GeneratedColumn<String>(
    'voter_outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _docsSeenMeta = const VerificationMeta(
    'docsSeen',
  );
  @override
  late final GeneratedColumn<String> docsSeen = GeneratedColumn<String>(
    'docs_seen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    visitId,
    voterId,
    voterOutcome,
    docsSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_voters';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitVoterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('voter_id')) {
      context.handle(
        _voterIdMeta,
        voterId.isAcceptableOrUnknown(data['voter_id']!, _voterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voterIdMeta);
    }
    if (data.containsKey('voter_outcome')) {
      context.handle(
        _voterOutcomeMeta,
        voterOutcome.isAcceptableOrUnknown(
          data['voter_outcome']!,
          _voterOutcomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voterOutcomeMeta);
    }
    if (data.containsKey('docs_seen')) {
      context.handle(
        _docsSeenMeta,
        docsSeen.isAcceptableOrUnknown(data['docs_seen']!, _docsSeenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {visitId, voterId};
  @override
  VisitVoterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitVoterRow(
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      voterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voter_id'],
      )!,
      voterOutcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voter_outcome'],
      )!,
      docsSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}docs_seen'],
      )!,
    );
  }

  @override
  $VisitVotersTable createAlias(String alias) {
    return $VisitVotersTable(attachedDatabase, alias);
  }
}

class VisitVoterRow extends DataClass implements Insertable<VisitVoterRow> {
  final String visitId;
  final String voterId;
  final String voterOutcome;
  final String docsSeen;
  const VisitVoterRow({
    required this.visitId,
    required this.voterId,
    required this.voterOutcome,
    required this.docsSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['visit_id'] = Variable<String>(visitId);
    map['voter_id'] = Variable<String>(voterId);
    map['voter_outcome'] = Variable<String>(voterOutcome);
    map['docs_seen'] = Variable<String>(docsSeen);
    return map;
  }

  VisitVotersCompanion toCompanion(bool nullToAbsent) {
    return VisitVotersCompanion(
      visitId: Value(visitId),
      voterId: Value(voterId),
      voterOutcome: Value(voterOutcome),
      docsSeen: Value(docsSeen),
    );
  }

  factory VisitVoterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitVoterRow(
      visitId: serializer.fromJson<String>(json['visitId']),
      voterId: serializer.fromJson<String>(json['voterId']),
      voterOutcome: serializer.fromJson<String>(json['voterOutcome']),
      docsSeen: serializer.fromJson<String>(json['docsSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'visitId': serializer.toJson<String>(visitId),
      'voterId': serializer.toJson<String>(voterId),
      'voterOutcome': serializer.toJson<String>(voterOutcome),
      'docsSeen': serializer.toJson<String>(docsSeen),
    };
  }

  VisitVoterRow copyWith({
    String? visitId,
    String? voterId,
    String? voterOutcome,
    String? docsSeen,
  }) => VisitVoterRow(
    visitId: visitId ?? this.visitId,
    voterId: voterId ?? this.voterId,
    voterOutcome: voterOutcome ?? this.voterOutcome,
    docsSeen: docsSeen ?? this.docsSeen,
  );
  VisitVoterRow copyWithCompanion(VisitVotersCompanion data) {
    return VisitVoterRow(
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      voterId: data.voterId.present ? data.voterId.value : this.voterId,
      voterOutcome: data.voterOutcome.present
          ? data.voterOutcome.value
          : this.voterOutcome,
      docsSeen: data.docsSeen.present ? data.docsSeen.value : this.docsSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitVoterRow(')
          ..write('visitId: $visitId, ')
          ..write('voterId: $voterId, ')
          ..write('voterOutcome: $voterOutcome, ')
          ..write('docsSeen: $docsSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(visitId, voterId, voterOutcome, docsSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitVoterRow &&
          other.visitId == this.visitId &&
          other.voterId == this.voterId &&
          other.voterOutcome == this.voterOutcome &&
          other.docsSeen == this.docsSeen);
}

class VisitVotersCompanion extends UpdateCompanion<VisitVoterRow> {
  final Value<String> visitId;
  final Value<String> voterId;
  final Value<String> voterOutcome;
  final Value<String> docsSeen;
  final Value<int> rowid;
  const VisitVotersCompanion({
    this.visitId = const Value.absent(),
    this.voterId = const Value.absent(),
    this.voterOutcome = const Value.absent(),
    this.docsSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitVotersCompanion.insert({
    required String visitId,
    required String voterId,
    required String voterOutcome,
    this.docsSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : visitId = Value(visitId),
       voterId = Value(voterId),
       voterOutcome = Value(voterOutcome);
  static Insertable<VisitVoterRow> custom({
    Expression<String>? visitId,
    Expression<String>? voterId,
    Expression<String>? voterOutcome,
    Expression<String>? docsSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (visitId != null) 'visit_id': visitId,
      if (voterId != null) 'voter_id': voterId,
      if (voterOutcome != null) 'voter_outcome': voterOutcome,
      if (docsSeen != null) 'docs_seen': docsSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitVotersCompanion copyWith({
    Value<String>? visitId,
    Value<String>? voterId,
    Value<String>? voterOutcome,
    Value<String>? docsSeen,
    Value<int>? rowid,
  }) {
    return VisitVotersCompanion(
      visitId: visitId ?? this.visitId,
      voterId: voterId ?? this.voterId,
      voterOutcome: voterOutcome ?? this.voterOutcome,
      docsSeen: docsSeen ?? this.docsSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (voterId.present) {
      map['voter_id'] = Variable<String>(voterId.value);
    }
    if (voterOutcome.present) {
      map['voter_outcome'] = Variable<String>(voterOutcome.value);
    }
    if (docsSeen.present) {
      map['docs_seen'] = Variable<String>(docsSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitVotersCompanion(')
          ..write('visitId: $visitId, ')
          ..write('voterId: $voterId, ')
          ..write('voterOutcome: $voterOutcome, ')
          ..write('docsSeen: $docsSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormsTable extends Forms with TableInfo<$FormsTable, FormRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voterIdMeta = const VerificationMeta(
    'voterId',
  );
  @override
  late final GeneratedColumn<String> voterId = GeneratedColumn<String>(
    'voter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formTypeMeta = const VerificationMeta(
    'formType',
  );
  @override
  late final GeneratedColumn<String> formType = GeneratedColumn<String>(
    'form_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filedOnMeta = const VerificationMeta(
    'filedOn',
  );
  @override
  late final GeneratedColumn<String> filedOn = GeneratedColumn<String>(
    'filed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byMeMeta = const VerificationMeta('byMe');
  @override
  late final GeneratedColumn<bool> byMe = GeneratedColumn<bool>(
    'by_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("by_me" IN (0, 1))',
    ),
  );
  static const VerificationMeta _currentStatusMeta = const VerificationMeta(
    'currentStatus',
  );
  @override
  late final GeneratedColumn<String> currentStatus = GeneratedColumn<String>(
    'current_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasPhotoMeta = const VerificationMeta(
    'hasPhoto',
  );
  @override
  late final GeneratedColumn<bool> hasPhoto = GeneratedColumn<bool>(
    'has_photo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_photo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    voterId,
    formType,
    route,
    referenceNo,
    filedOn,
    byMe,
    currentStatus,
    updatedAt,
    hasPhoto,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forms';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('voter_id')) {
      context.handle(
        _voterIdMeta,
        voterId.isAcceptableOrUnknown(data['voter_id']!, _voterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voterIdMeta);
    }
    if (data.containsKey('form_type')) {
      context.handle(
        _formTypeMeta,
        formType.isAcceptableOrUnknown(data['form_type']!, _formTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_formTypeMeta);
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    }
    if (data.containsKey('filed_on')) {
      context.handle(
        _filedOnMeta,
        filedOn.isAcceptableOrUnknown(data['filed_on']!, _filedOnMeta),
      );
    }
    if (data.containsKey('by_me')) {
      context.handle(
        _byMeMeta,
        byMe.isAcceptableOrUnknown(data['by_me']!, _byMeMeta),
      );
    } else if (isInserting) {
      context.missing(_byMeMeta);
    }
    if (data.containsKey('current_status')) {
      context.handle(
        _currentStatusMeta,
        currentStatus.isAcceptableOrUnknown(
          data['current_status']!,
          _currentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentStatusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('has_photo')) {
      context.handle(
        _hasPhotoMeta,
        hasPhoto.isAcceptableOrUnknown(data['has_photo']!, _hasPhotoMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FormRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      voterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voter_id'],
      )!,
      formType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_type'],
      )!,
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      ),
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      ),
      filedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filed_on'],
      ),
      byMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}by_me'],
      )!,
      currentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      hasPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_photo'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $FormsTable createAlias(String alias) {
    return $FormsTable(attachedDatabase, alias);
  }
}

class FormRow extends DataClass implements Insertable<FormRow> {
  final String id;
  final String voterId;
  final String formType;
  final String? route;
  final String? referenceNo;
  final String? filedOn;
  final bool byMe;
  final String currentStatus;
  final DateTime updatedAt;
  final bool hasPhoto;
  final bool pending;
  const FormRow({
    required this.id,
    required this.voterId,
    required this.formType,
    this.route,
    this.referenceNo,
    this.filedOn,
    required this.byMe,
    required this.currentStatus,
    required this.updatedAt,
    required this.hasPhoto,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['voter_id'] = Variable<String>(voterId);
    map['form_type'] = Variable<String>(formType);
    if (!nullToAbsent || route != null) {
      map['route'] = Variable<String>(route);
    }
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || filedOn != null) {
      map['filed_on'] = Variable<String>(filedOn);
    }
    map['by_me'] = Variable<bool>(byMe);
    map['current_status'] = Variable<String>(currentStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['has_photo'] = Variable<bool>(hasPhoto);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  FormsCompanion toCompanion(bool nullToAbsent) {
    return FormsCompanion(
      id: Value(id),
      voterId: Value(voterId),
      formType: Value(formType),
      route: route == null && nullToAbsent
          ? const Value.absent()
          : Value(route),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      filedOn: filedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(filedOn),
      byMe: Value(byMe),
      currentStatus: Value(currentStatus),
      updatedAt: Value(updatedAt),
      hasPhoto: Value(hasPhoto),
      pending: Value(pending),
    );
  }

  factory FormRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormRow(
      id: serializer.fromJson<String>(json['id']),
      voterId: serializer.fromJson<String>(json['voterId']),
      formType: serializer.fromJson<String>(json['formType']),
      route: serializer.fromJson<String?>(json['route']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      filedOn: serializer.fromJson<String?>(json['filedOn']),
      byMe: serializer.fromJson<bool>(json['byMe']),
      currentStatus: serializer.fromJson<String>(json['currentStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      hasPhoto: serializer.fromJson<bool>(json['hasPhoto']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'voterId': serializer.toJson<String>(voterId),
      'formType': serializer.toJson<String>(formType),
      'route': serializer.toJson<String?>(route),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'filedOn': serializer.toJson<String?>(filedOn),
      'byMe': serializer.toJson<bool>(byMe),
      'currentStatus': serializer.toJson<String>(currentStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'hasPhoto': serializer.toJson<bool>(hasPhoto),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  FormRow copyWith({
    String? id,
    String? voterId,
    String? formType,
    Value<String?> route = const Value.absent(),
    Value<String?> referenceNo = const Value.absent(),
    Value<String?> filedOn = const Value.absent(),
    bool? byMe,
    String? currentStatus,
    DateTime? updatedAt,
    bool? hasPhoto,
    bool? pending,
  }) => FormRow(
    id: id ?? this.id,
    voterId: voterId ?? this.voterId,
    formType: formType ?? this.formType,
    route: route.present ? route.value : this.route,
    referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
    filedOn: filedOn.present ? filedOn.value : this.filedOn,
    byMe: byMe ?? this.byMe,
    currentStatus: currentStatus ?? this.currentStatus,
    updatedAt: updatedAt ?? this.updatedAt,
    hasPhoto: hasPhoto ?? this.hasPhoto,
    pending: pending ?? this.pending,
  );
  FormRow copyWithCompanion(FormsCompanion data) {
    return FormRow(
      id: data.id.present ? data.id.value : this.id,
      voterId: data.voterId.present ? data.voterId.value : this.voterId,
      formType: data.formType.present ? data.formType.value : this.formType,
      route: data.route.present ? data.route.value : this.route,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      filedOn: data.filedOn.present ? data.filedOn.value : this.filedOn,
      byMe: data.byMe.present ? data.byMe.value : this.byMe,
      currentStatus: data.currentStatus.present
          ? data.currentStatus.value
          : this.currentStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hasPhoto: data.hasPhoto.present ? data.hasPhoto.value : this.hasPhoto,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormRow(')
          ..write('id: $id, ')
          ..write('voterId: $voterId, ')
          ..write('formType: $formType, ')
          ..write('route: $route, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('filedOn: $filedOn, ')
          ..write('byMe: $byMe, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hasPhoto: $hasPhoto, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    voterId,
    formType,
    route,
    referenceNo,
    filedOn,
    byMe,
    currentStatus,
    updatedAt,
    hasPhoto,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormRow &&
          other.id == this.id &&
          other.voterId == this.voterId &&
          other.formType == this.formType &&
          other.route == this.route &&
          other.referenceNo == this.referenceNo &&
          other.filedOn == this.filedOn &&
          other.byMe == this.byMe &&
          other.currentStatus == this.currentStatus &&
          other.updatedAt == this.updatedAt &&
          other.hasPhoto == this.hasPhoto &&
          other.pending == this.pending);
}

class FormsCompanion extends UpdateCompanion<FormRow> {
  final Value<String> id;
  final Value<String> voterId;
  final Value<String> formType;
  final Value<String?> route;
  final Value<String?> referenceNo;
  final Value<String?> filedOn;
  final Value<bool> byMe;
  final Value<String> currentStatus;
  final Value<DateTime> updatedAt;
  final Value<bool> hasPhoto;
  final Value<bool> pending;
  final Value<int> rowid;
  const FormsCompanion({
    this.id = const Value.absent(),
    this.voterId = const Value.absent(),
    this.formType = const Value.absent(),
    this.route = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.filedOn = const Value.absent(),
    this.byMe = const Value.absent(),
    this.currentStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hasPhoto = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormsCompanion.insert({
    required String id,
    required String voterId,
    required String formType,
    this.route = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.filedOn = const Value.absent(),
    required bool byMe,
    required String currentStatus,
    required DateTime updatedAt,
    this.hasPhoto = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       voterId = Value(voterId),
       formType = Value(formType),
       byMe = Value(byMe),
       currentStatus = Value(currentStatus),
       updatedAt = Value(updatedAt);
  static Insertable<FormRow> custom({
    Expression<String>? id,
    Expression<String>? voterId,
    Expression<String>? formType,
    Expression<String>? route,
    Expression<String>? referenceNo,
    Expression<String>? filedOn,
    Expression<bool>? byMe,
    Expression<String>? currentStatus,
    Expression<DateTime>? updatedAt,
    Expression<bool>? hasPhoto,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voterId != null) 'voter_id': voterId,
      if (formType != null) 'form_type': formType,
      if (route != null) 'route': route,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (filedOn != null) 'filed_on': filedOn,
      if (byMe != null) 'by_me': byMe,
      if (currentStatus != null) 'current_status': currentStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hasPhoto != null) 'has_photo': hasPhoto,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormsCompanion copyWith({
    Value<String>? id,
    Value<String>? voterId,
    Value<String>? formType,
    Value<String?>? route,
    Value<String?>? referenceNo,
    Value<String?>? filedOn,
    Value<bool>? byMe,
    Value<String>? currentStatus,
    Value<DateTime>? updatedAt,
    Value<bool>? hasPhoto,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return FormsCompanion(
      id: id ?? this.id,
      voterId: voterId ?? this.voterId,
      formType: formType ?? this.formType,
      route: route ?? this.route,
      referenceNo: referenceNo ?? this.referenceNo,
      filedOn: filedOn ?? this.filedOn,
      byMe: byMe ?? this.byMe,
      currentStatus: currentStatus ?? this.currentStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (voterId.present) {
      map['voter_id'] = Variable<String>(voterId.value);
    }
    if (formType.present) {
      map['form_type'] = Variable<String>(formType.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (filedOn.present) {
      map['filed_on'] = Variable<String>(filedOn.value);
    }
    if (byMe.present) {
      map['by_me'] = Variable<bool>(byMe.value);
    }
    if (currentStatus.present) {
      map['current_status'] = Variable<String>(currentStatus.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (hasPhoto.present) {
      map['has_photo'] = Variable<bool>(hasPhoto.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormsCompanion(')
          ..write('id: $id, ')
          ..write('voterId: $voterId, ')
          ..write('formType: $formType, ')
          ..write('route: $route, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('filedOn: $filedOn, ')
          ..write('byMe: $byMe, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hasPhoto: $hasPhoto, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormEventsTable extends FormEvents
    with TableInfo<$FormEventsTable, FormEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formIdMeta = const VerificationMeta('formId');
  @override
  late final GeneratedColumn<String> formId = GeneratedColumn<String>(
    'form_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byMeMeta = const VerificationMeta('byMe');
  @override
  late final GeneratedColumn<bool> byMe = GeneratedColumn<bool>(
    'by_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("by_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    formId,
    status,
    changedAt,
    byMe,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'form_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('form_id')) {
      context.handle(
        _formIdMeta,
        formId.isAcceptableOrUnknown(data['form_id']!, _formIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    if (data.containsKey('by_me')) {
      context.handle(
        _byMeMeta,
        byMe.isAcceptableOrUnknown(data['by_me']!, _byMeMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FormEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      formId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      byMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}by_me'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $FormEventsTable createAlias(String alias) {
    return $FormEventsTable(attachedDatabase, alias);
  }
}

class FormEventRow extends DataClass implements Insertable<FormEventRow> {
  final String id;
  final String formId;
  final String status;
  final DateTime changedAt;
  final bool byMe;
  final bool pending;
  const FormEventRow({
    required this.id,
    required this.formId,
    required this.status,
    required this.changedAt,
    required this.byMe,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['form_id'] = Variable<String>(formId);
    map['status'] = Variable<String>(status);
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['by_me'] = Variable<bool>(byMe);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  FormEventsCompanion toCompanion(bool nullToAbsent) {
    return FormEventsCompanion(
      id: Value(id),
      formId: Value(formId),
      status: Value(status),
      changedAt: Value(changedAt),
      byMe: Value(byMe),
      pending: Value(pending),
    );
  }

  factory FormEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormEventRow(
      id: serializer.fromJson<String>(json['id']),
      formId: serializer.fromJson<String>(json['formId']),
      status: serializer.fromJson<String>(json['status']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      byMe: serializer.fromJson<bool>(json['byMe']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'formId': serializer.toJson<String>(formId),
      'status': serializer.toJson<String>(status),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'byMe': serializer.toJson<bool>(byMe),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  FormEventRow copyWith({
    String? id,
    String? formId,
    String? status,
    DateTime? changedAt,
    bool? byMe,
    bool? pending,
  }) => FormEventRow(
    id: id ?? this.id,
    formId: formId ?? this.formId,
    status: status ?? this.status,
    changedAt: changedAt ?? this.changedAt,
    byMe: byMe ?? this.byMe,
    pending: pending ?? this.pending,
  );
  FormEventRow copyWithCompanion(FormEventsCompanion data) {
    return FormEventRow(
      id: data.id.present ? data.id.value : this.id,
      formId: data.formId.present ? data.formId.value : this.formId,
      status: data.status.present ? data.status.value : this.status,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      byMe: data.byMe.present ? data.byMe.value : this.byMe,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormEventRow(')
          ..write('id: $id, ')
          ..write('formId: $formId, ')
          ..write('status: $status, ')
          ..write('changedAt: $changedAt, ')
          ..write('byMe: $byMe, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, formId, status, changedAt, byMe, pending);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormEventRow &&
          other.id == this.id &&
          other.formId == this.formId &&
          other.status == this.status &&
          other.changedAt == this.changedAt &&
          other.byMe == this.byMe &&
          other.pending == this.pending);
}

class FormEventsCompanion extends UpdateCompanion<FormEventRow> {
  final Value<String> id;
  final Value<String> formId;
  final Value<String> status;
  final Value<DateTime> changedAt;
  final Value<bool> byMe;
  final Value<bool> pending;
  final Value<int> rowid;
  const FormEventsCompanion({
    this.id = const Value.absent(),
    this.formId = const Value.absent(),
    this.status = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.byMe = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormEventsCompanion.insert({
    required String id,
    required String formId,
    required String status,
    required DateTime changedAt,
    this.byMe = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       formId = Value(formId),
       status = Value(status),
       changedAt = Value(changedAt);
  static Insertable<FormEventRow> custom({
    Expression<String>? id,
    Expression<String>? formId,
    Expression<String>? status,
    Expression<DateTime>? changedAt,
    Expression<bool>? byMe,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formId != null) 'form_id': formId,
      if (status != null) 'status': status,
      if (changedAt != null) 'changed_at': changedAt,
      if (byMe != null) 'by_me': byMe,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? formId,
    Value<String>? status,
    Value<DateTime>? changedAt,
    Value<bool>? byMe,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return FormEventsCompanion(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      status: status ?? this.status,
      changedAt: changedAt ?? this.changedAt,
      byMe: byMe ?? this.byMe,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (formId.present) {
      map['form_id'] = Variable<String>(formId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (byMe.present) {
      map['by_me'] = Variable<bool>(byMe.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormEventsCompanion(')
          ..write('id: $id, ')
          ..write('formId: $formId, ')
          ..write('status: $status, ')
          ..write('changedAt: $changedAt, ')
          ..write('byMe: $byMe, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormPhotosTable extends FormPhotos
    with TableInfo<$FormPhotosTable, FormPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _formIdMeta = const VerificationMeta('formId');
  @override
  late final GeneratedColumn<String> formId = GeneratedColumn<String>(
    'form_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [formId, bytes, takenAt, uploaded];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'form_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormPhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('form_id')) {
      context.handle(
        _formIdMeta,
        formId.isAcceptableOrUnknown(data['form_id']!, _formIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formIdMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {formId};
  @override
  FormPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormPhotoRow(
      formId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
    );
  }

  @override
  $FormPhotosTable createAlias(String alias) {
    return $FormPhotosTable(attachedDatabase, alias);
  }
}

class FormPhotoRow extends DataClass implements Insertable<FormPhotoRow> {
  final String formId;
  final Uint8List bytes;
  final DateTime takenAt;
  final bool uploaded;
  const FormPhotoRow({
    required this.formId,
    required this.bytes,
    required this.takenAt,
    required this.uploaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['form_id'] = Variable<String>(formId);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['uploaded'] = Variable<bool>(uploaded);
    return map;
  }

  FormPhotosCompanion toCompanion(bool nullToAbsent) {
    return FormPhotosCompanion(
      formId: Value(formId),
      bytes: Value(bytes),
      takenAt: Value(takenAt),
      uploaded: Value(uploaded),
    );
  }

  factory FormPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormPhotoRow(
      formId: serializer.fromJson<String>(json['formId']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'formId': serializer.toJson<String>(formId),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'uploaded': serializer.toJson<bool>(uploaded),
    };
  }

  FormPhotoRow copyWith({
    String? formId,
    Uint8List? bytes,
    DateTime? takenAt,
    bool? uploaded,
  }) => FormPhotoRow(
    formId: formId ?? this.formId,
    bytes: bytes ?? this.bytes,
    takenAt: takenAt ?? this.takenAt,
    uploaded: uploaded ?? this.uploaded,
  );
  FormPhotoRow copyWithCompanion(FormPhotosCompanion data) {
    return FormPhotoRow(
      formId: data.formId.present ? data.formId.value : this.formId,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormPhotoRow(')
          ..write('formId: $formId, ')
          ..write('bytes: $bytes, ')
          ..write('takenAt: $takenAt, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(formId, $driftBlobEquality.hash(bytes), takenAt, uploaded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormPhotoRow &&
          other.formId == this.formId &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.takenAt == this.takenAt &&
          other.uploaded == this.uploaded);
}

class FormPhotosCompanion extends UpdateCompanion<FormPhotoRow> {
  final Value<String> formId;
  final Value<Uint8List> bytes;
  final Value<DateTime> takenAt;
  final Value<bool> uploaded;
  final Value<int> rowid;
  const FormPhotosCompanion({
    this.formId = const Value.absent(),
    this.bytes = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormPhotosCompanion.insert({
    required String formId,
    required Uint8List bytes,
    required DateTime takenAt,
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : formId = Value(formId),
       bytes = Value(bytes),
       takenAt = Value(takenAt);
  static Insertable<FormPhotoRow> custom({
    Expression<String>? formId,
    Expression<Uint8List>? bytes,
    Expression<DateTime>? takenAt,
    Expression<bool>? uploaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (formId != null) 'form_id': formId,
      if (bytes != null) 'bytes': bytes,
      if (takenAt != null) 'taken_at': takenAt,
      if (uploaded != null) 'uploaded': uploaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormPhotosCompanion copyWith({
    Value<String>? formId,
    Value<Uint8List>? bytes,
    Value<DateTime>? takenAt,
    Value<bool>? uploaded,
    Value<int>? rowid,
  }) {
    return FormPhotosCompanion(
      formId: formId ?? this.formId,
      bytes: bytes ?? this.bytes,
      takenAt: takenAt ?? this.takenAt,
      uploaded: uploaded ?? this.uploaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (formId.present) {
      map['form_id'] = Variable<String>(formId.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormPhotosCompanion(')
          ..write('formId: $formId, ')
          ..write('bytes: $bytes, ')
          ..write('takenAt: $takenAt, ')
          ..write('uploaded: $uploaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorHiMeta = const VerificationMeta(
    'errorHi',
  );
  @override
  late final GeneratedColumn<String> errorHi = GeneratedColumn<String>(
    'error_hi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    uuid,
    entity,
    payload,
    createdAt,
    attempts,
    state,
    errorCode,
    errorHi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('error_hi')) {
      context.handle(
        _errorHiMeta,
        errorHi.isAcceptableOrUnknown(data['error_hi']!, _errorHiMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      errorHi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_hi'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int seq;
  final String uuid;
  final String entity;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String state;
  final String? errorCode;
  final String? errorHi;
  const OutboxRow({
    required this.seq,
    required this.uuid,
    required this.entity,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    required this.state,
    this.errorCode,
    this.errorHi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['uuid'] = Variable<String>(uuid);
    map['entity'] = Variable<String>(entity);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorHi != null) {
      map['error_hi'] = Variable<String>(errorHi);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      uuid: Value(uuid),
      entity: Value(entity),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      state: Value(state),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorHi: errorHi == null && nullToAbsent
          ? const Value.absent()
          : Value(errorHi),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      uuid: serializer.fromJson<String>(json['uuid']),
      entity: serializer.fromJson<String>(json['entity']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      state: serializer.fromJson<String>(json['state']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorHi: serializer.fromJson<String?>(json['errorHi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'uuid': serializer.toJson<String>(uuid),
      'entity': serializer.toJson<String>(entity),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'state': serializer.toJson<String>(state),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorHi': serializer.toJson<String?>(errorHi),
    };
  }

  OutboxRow copyWith({
    int? seq,
    String? uuid,
    String? entity,
    String? payload,
    DateTime? createdAt,
    int? attempts,
    String? state,
    Value<String?> errorCode = const Value.absent(),
    Value<String?> errorHi = const Value.absent(),
  }) => OutboxRow(
    seq: seq ?? this.seq,
    uuid: uuid ?? this.uuid,
    entity: entity ?? this.entity,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    state: state ?? this.state,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    errorHi: errorHi.present ? errorHi.value : this.errorHi,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      entity: data.entity.present ? data.entity.value : this.entity,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      state: data.state.present ? data.state.value : this.state,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorHi: data.errorHi.present ? data.errorHi.value : this.errorHi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('seq: $seq, ')
          ..write('uuid: $uuid, ')
          ..write('entity: $entity, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorHi: $errorHi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    uuid,
    entity,
    payload,
    createdAt,
    attempts,
    state,
    errorCode,
    errorHi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.seq == this.seq &&
          other.uuid == this.uuid &&
          other.entity == this.entity &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.state == this.state &&
          other.errorCode == this.errorCode &&
          other.errorHi == this.errorHi);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> seq;
  final Value<String> uuid;
  final Value<String> entity;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String> state;
  final Value<String?> errorCode;
  final Value<String?> errorHi;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.uuid = const Value.absent(),
    this.entity = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorHi = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String uuid,
    required String entity,
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorHi = const Value.absent(),
  }) : uuid = Value(uuid),
       entity = Value(entity),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? seq,
    Expression<String>? uuid,
    Expression<String>? entity,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? state,
    Expression<String>? errorCode,
    Expression<String>? errorHi,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (uuid != null) 'uuid': uuid,
      if (entity != null) 'entity': entity,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (state != null) 'state': state,
      if (errorCode != null) 'error_code': errorCode,
      if (errorHi != null) 'error_hi': errorHi,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? uuid,
    Value<String>? entity,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String>? state,
    Value<String?>? errorCode,
    Value<String?>? errorHi,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      uuid: uuid ?? this.uuid,
      entity: entity ?? this.entity,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      state: state ?? this.state,
      errorCode: errorCode ?? this.errorCode,
      errorHi: errorHi ?? this.errorHi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorHi.present) {
      map['error_hi'] = Variable<String>(errorHi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('uuid: $uuid, ')
          ..write('entity: $entity, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorHi: $errorHi')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) =>
      MetaRow(key: key ?? this.key, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $BoothsTable booths = $BoothsTable(this);
  late final $FamiliesTable families = $FamiliesTable(this);
  late final $VotersTable voters = $VotersTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $VisitVotersTable visitVoters = $VisitVotersTable(this);
  late final $FormsTable forms = $FormsTable(this);
  late final $FormEventsTable formEvents = $FormEventsTable(this);
  late final $FormPhotosTable formPhotos = $FormPhotosTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $MetaTable meta = $MetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    booths,
    families,
    voters,
    visits,
    visitVoters,
    forms,
    formEvents,
    formPhotos,
    outbox,
    meta,
  ];
}

typedef $$BoothsTableCreateCompanionBuilder = BoothsCompanion Function({
  Value<int> partNo,
  Value<String?> stationHi,
});
typedef $$BoothsTableUpdateCompanionBuilder = BoothsCompanion Function({
  Value<int> partNo,
  Value<String?> stationHi,
});

class $$BoothsTableFilterComposer extends Composer<_$LocalDb, $BoothsTable> {
  $$BoothsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get partNo => $composableBuilder(
    column: $table.partNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationHi => $composableBuilder(
    column: $table.stationHi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoothsTableOrderingComposer extends Composer<_$LocalDb, $BoothsTable> {
  $$BoothsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get partNo => $composableBuilder(
    column: $table.partNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationHi => $composableBuilder(
    column: $table.stationHi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoothsTableAnnotationComposer
    extends Composer<_$LocalDb, $BoothsTable> {
  $$BoothsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get partNo =>
      $composableBuilder(column: $table.partNo, builder: (column) => column);

  GeneratedColumn<String> get stationHi =>
      $composableBuilder(column: $table.stationHi, builder: (column) => column);
}

class $$BoothsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $BoothsTable,
          BoothRow,
          $$BoothsTableFilterComposer,
          $$BoothsTableOrderingComposer,
          $$BoothsTableAnnotationComposer,
          $$BoothsTableCreateCompanionBuilder,
          $$BoothsTableUpdateCompanionBuilder,
          (BoothRow, BaseReferences<_$LocalDb, $BoothsTable, BoothRow>),
          BoothRow,
          PrefetchHooks Function()
        > {
  $$BoothsTableTableManager(_$LocalDb db, $BoothsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoothsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoothsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoothsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> partNo = const Value.absent(),
            Value<String?> stationHi = const Value.absent(),
          }) => BoothsCompanion(partNo: partNo, stationHi: stationHi),
          createCompanionCallback: ({
            Value<int> partNo = const Value.absent(),
            Value<String?> stationHi = const Value.absent(),
          }) => BoothsCompanion.insert(partNo: partNo, stationHi: stationHi),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BoothsTable, BoothRow>(table),
                  BaseReferences<_$LocalDb, $BoothsTable, BoothRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoothsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $BoothsTable,
      BoothRow,
      $$BoothsTableFilterComposer,
      $$BoothsTableOrderingComposer,
      $$BoothsTableAnnotationComposer,
      $$BoothsTableCreateCompanionBuilder,
      $$BoothsTableUpdateCompanionBuilder,
      (BoothRow, BaseReferences<_$LocalDb, $BoothsTable, BoothRow>),
      BoothRow,
      PrefetchHooks Function()
    >;
typedef $$FamiliesTableCreateCompanionBuilder = FamiliesCompanion Function({
  required String id,
  required String code,
  required int partNo,
  Value<int?> sectionNo,
  Value<String?> houseNo,
  Value<String?> headNameHi,
  required int priority,
  Value<bool> needsReview,
  Value<bool> pending,
  Value<int> rowid,
});
typedef $$FamiliesTableUpdateCompanionBuilder = FamiliesCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<int> partNo,
  Value<int?> sectionNo,
  Value<String?> houseNo,
  Value<String?> headNameHi,
  Value<int> priority,
  Value<bool> needsReview,
  Value<bool> pending,
  Value<int> rowid,
});

class $$FamiliesTableFilterComposer
    extends Composer<_$LocalDb, $FamiliesTable> {
  $$FamiliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partNo => $composableBuilder(
    column: $table.partNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionNo => $composableBuilder(
    column: $table.sectionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseNo => $composableBuilder(
    column: $table.houseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headNameHi => $composableBuilder(
    column: $table.headNameHi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamiliesTableOrderingComposer
    extends Composer<_$LocalDb, $FamiliesTable> {
  $$FamiliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partNo => $composableBuilder(
    column: $table.partNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionNo => $composableBuilder(
    column: $table.sectionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseNo => $composableBuilder(
    column: $table.houseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headNameHi => $composableBuilder(
    column: $table.headNameHi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamiliesTableAnnotationComposer
    extends Composer<_$LocalDb, $FamiliesTable> {
  $$FamiliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get partNo =>
      $composableBuilder(column: $table.partNo, builder: (column) => column);

  GeneratedColumn<int> get sectionNo =>
      $composableBuilder(column: $table.sectionNo, builder: (column) => column);

  GeneratedColumn<String> get houseNo =>
      $composableBuilder(column: $table.houseNo, builder: (column) => column);

  GeneratedColumn<String> get headNameHi => $composableBuilder(
    column: $table.headNameHi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$FamiliesTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $FamiliesTable,
          FamilyRow,
          $$FamiliesTableFilterComposer,
          $$FamiliesTableOrderingComposer,
          $$FamiliesTableAnnotationComposer,
          $$FamiliesTableCreateCompanionBuilder,
          $$FamiliesTableUpdateCompanionBuilder,
          (FamilyRow, BaseReferences<_$LocalDb, $FamiliesTable, FamilyRow>),
          FamilyRow,
          PrefetchHooks Function()
        > {
  $$FamiliesTableTableManager(_$LocalDb db, $FamiliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamiliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamiliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamiliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> partNo = const Value.absent(),
                Value<int?> sectionNo = const Value.absent(),
                Value<String?> houseNo = const Value.absent(),
                Value<String?> headNameHi = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamiliesCompanion(
                id: id,
                code: code,
                partNo: partNo,
                sectionNo: sectionNo,
                houseNo: houseNo,
                headNameHi: headNameHi,
                priority: priority,
                needsReview: needsReview,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required int partNo,
                Value<int?> sectionNo = const Value.absent(),
                Value<String?> houseNo = const Value.absent(),
                Value<String?> headNameHi = const Value.absent(),
                required int priority,
                Value<bool> needsReview = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamiliesCompanion.insert(
                id: id,
                code: code,
                partNo: partNo,
                sectionNo: sectionNo,
                houseNo: houseNo,
                headNameHi: headNameHi,
                priority: priority,
                needsReview: needsReview,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FamiliesTable, FamilyRow>(table),
                  BaseReferences<_$LocalDb, $FamiliesTable, FamilyRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamiliesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $FamiliesTable,
      FamilyRow,
      $$FamiliesTableFilterComposer,
      $$FamiliesTableOrderingComposer,
      $$FamiliesTableAnnotationComposer,
      $$FamiliesTableCreateCompanionBuilder,
      $$FamiliesTableUpdateCompanionBuilder,
      (FamilyRow, BaseReferences<_$LocalDb, $FamiliesTable, FamilyRow>),
      FamilyRow,
      PrefetchHooks Function()
    >;
typedef $$VotersTableCreateCompanionBuilder = VotersCompanion Function({
  required String id,
  required String familyId,
  Value<String?> epic,
  required String nameHi,
  Value<String?> relationType,
  Value<String?> relativeNameHi,
  Value<int?> age,
  Value<String?> gender,
  required String sourceList,
  Value<String?> asddReason,
  Value<String?> matchConfidence,
  Value<int?> oldPartNo,
  Value<int?> oldSerial,
  Value<bool> alreadyOnRoll,
  Value<String?> category,
  Value<String?> closest2026,
  Value<String?> newReason,
  Value<String?> newReasonNote,
  Value<int?> draftPart,
  Value<String?> draftSection,
  Value<bool> pending,
  Value<int> rowid,
});
typedef $$VotersTableUpdateCompanionBuilder = VotersCompanion Function({
  Value<String> id,
  Value<String> familyId,
  Value<String?> epic,
  Value<String> nameHi,
  Value<String?> relationType,
  Value<String?> relativeNameHi,
  Value<int?> age,
  Value<String?> gender,
  Value<String> sourceList,
  Value<String?> asddReason,
  Value<String?> matchConfidence,
  Value<int?> oldPartNo,
  Value<int?> oldSerial,
  Value<bool> alreadyOnRoll,
  Value<String?> category,
  Value<String?> closest2026,
  Value<String?> newReason,
  Value<String?> newReasonNote,
  Value<int?> draftPart,
  Value<String?> draftSection,
  Value<bool> pending,
  Value<int> rowid,
});

class $$VotersTableFilterComposer extends Composer<_$LocalDb, $VotersTable> {
  $$VotersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epic => $composableBuilder(
    column: $table.epic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameHi => $composableBuilder(
    column: $table.nameHi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeNameHi => $composableBuilder(
    column: $table.relativeNameHi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceList => $composableBuilder(
    column: $table.sourceList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asddReason => $composableBuilder(
    column: $table.asddReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oldPartNo => $composableBuilder(
    column: $table.oldPartNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oldSerial => $composableBuilder(
    column: $table.oldSerial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alreadyOnRoll => $composableBuilder(
    column: $table.alreadyOnRoll,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closest2026 => $composableBuilder(
    column: $table.closest2026,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newReason => $composableBuilder(
    column: $table.newReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newReasonNote => $composableBuilder(
    column: $table.newReasonNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get draftPart => $composableBuilder(
    column: $table.draftPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftSection => $composableBuilder(
    column: $table.draftSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VotersTableOrderingComposer extends Composer<_$LocalDb, $VotersTable> {
  $$VotersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epic => $composableBuilder(
    column: $table.epic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameHi => $composableBuilder(
    column: $table.nameHi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeNameHi => $composableBuilder(
    column: $table.relativeNameHi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceList => $composableBuilder(
    column: $table.sourceList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asddReason => $composableBuilder(
    column: $table.asddReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oldPartNo => $composableBuilder(
    column: $table.oldPartNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oldSerial => $composableBuilder(
    column: $table.oldSerial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alreadyOnRoll => $composableBuilder(
    column: $table.alreadyOnRoll,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closest2026 => $composableBuilder(
    column: $table.closest2026,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newReason => $composableBuilder(
    column: $table.newReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newReasonNote => $composableBuilder(
    column: $table.newReasonNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get draftPart => $composableBuilder(
    column: $table.draftPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftSection => $composableBuilder(
    column: $table.draftSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VotersTableAnnotationComposer
    extends Composer<_$LocalDb, $VotersTable> {
  $$VotersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get epic =>
      $composableBuilder(column: $table.epic, builder: (column) => column);

  GeneratedColumn<String> get nameHi =>
      $composableBuilder(column: $table.nameHi, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativeNameHi => $composableBuilder(
    column: $table.relativeNameHi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get sourceList => $composableBuilder(
    column: $table.sourceList,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asddReason => $composableBuilder(
    column: $table.asddReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchConfidence => $composableBuilder(
    column: $table.matchConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oldPartNo =>
      $composableBuilder(column: $table.oldPartNo, builder: (column) => column);

  GeneratedColumn<int> get oldSerial =>
      $composableBuilder(column: $table.oldSerial, builder: (column) => column);

  GeneratedColumn<bool> get alreadyOnRoll => $composableBuilder(
    column: $table.alreadyOnRoll,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get closest2026 => $composableBuilder(
    column: $table.closest2026,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newReason =>
      $composableBuilder(column: $table.newReason, builder: (column) => column);

  GeneratedColumn<String> get newReasonNote => $composableBuilder(
    column: $table.newReasonNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get draftPart =>
      $composableBuilder(column: $table.draftPart, builder: (column) => column);

  GeneratedColumn<String> get draftSection => $composableBuilder(
    column: $table.draftSection,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$VotersTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $VotersTable,
          VoterRow,
          $$VotersTableFilterComposer,
          $$VotersTableOrderingComposer,
          $$VotersTableAnnotationComposer,
          $$VotersTableCreateCompanionBuilder,
          $$VotersTableUpdateCompanionBuilder,
          (VoterRow, BaseReferences<_$LocalDb, $VotersTable, VoterRow>),
          VoterRow,
          PrefetchHooks Function()
        > {
  $$VotersTableTableManager(_$LocalDb db, $VotersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VotersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VotersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VotersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String?> epic = const Value.absent(),
                Value<String> nameHi = const Value.absent(),
                Value<String?> relationType = const Value.absent(),
                Value<String?> relativeNameHi = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String> sourceList = const Value.absent(),
                Value<String?> asddReason = const Value.absent(),
                Value<String?> matchConfidence = const Value.absent(),
                Value<int?> oldPartNo = const Value.absent(),
                Value<int?> oldSerial = const Value.absent(),
                Value<bool> alreadyOnRoll = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> closest2026 = const Value.absent(),
                Value<String?> newReason = const Value.absent(),
                Value<String?> newReasonNote = const Value.absent(),
                Value<int?> draftPart = const Value.absent(),
                Value<String?> draftSection = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VotersCompanion(
                id: id,
                familyId: familyId,
                epic: epic,
                nameHi: nameHi,
                relationType: relationType,
                relativeNameHi: relativeNameHi,
                age: age,
                gender: gender,
                sourceList: sourceList,
                asddReason: asddReason,
                matchConfidence: matchConfidence,
                oldPartNo: oldPartNo,
                oldSerial: oldSerial,
                alreadyOnRoll: alreadyOnRoll,
                category: category,
                closest2026: closest2026,
                newReason: newReason,
                newReasonNote: newReasonNote,
                draftPart: draftPart,
                draftSection: draftSection,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                Value<String?> epic = const Value.absent(),
                required String nameHi,
                Value<String?> relationType = const Value.absent(),
                Value<String?> relativeNameHi = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                required String sourceList,
                Value<String?> asddReason = const Value.absent(),
                Value<String?> matchConfidence = const Value.absent(),
                Value<int?> oldPartNo = const Value.absent(),
                Value<int?> oldSerial = const Value.absent(),
                Value<bool> alreadyOnRoll = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> closest2026 = const Value.absent(),
                Value<String?> newReason = const Value.absent(),
                Value<String?> newReasonNote = const Value.absent(),
                Value<int?> draftPart = const Value.absent(),
                Value<String?> draftSection = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VotersCompanion.insert(
                id: id,
                familyId: familyId,
                epic: epic,
                nameHi: nameHi,
                relationType: relationType,
                relativeNameHi: relativeNameHi,
                age: age,
                gender: gender,
                sourceList: sourceList,
                asddReason: asddReason,
                matchConfidence: matchConfidence,
                oldPartNo: oldPartNo,
                oldSerial: oldSerial,
                alreadyOnRoll: alreadyOnRoll,
                category: category,
                closest2026: closest2026,
                newReason: newReason,
                newReasonNote: newReasonNote,
                draftPart: draftPart,
                draftSection: draftSection,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VotersTable, VoterRow>(table),
                  BaseReferences<_$LocalDb, $VotersTable, VoterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VotersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $VotersTable,
      VoterRow,
      $$VotersTableFilterComposer,
      $$VotersTableOrderingComposer,
      $$VotersTableAnnotationComposer,
      $$VotersTableCreateCompanionBuilder,
      $$VotersTableUpdateCompanionBuilder,
      (VoterRow, BaseReferences<_$LocalDb, $VotersTable, VoterRow>),
      VoterRow,
      PrefetchHooks Function()
    >;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({
  required String id,
  required String familyId,
  required bool byMe,
  required DateTime visitedAt,
  required String outcome,
  Value<String?> revisitOn,
  Value<String?> remarks,
  Value<bool> pending,
  Value<int> rowid,
});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({
  Value<String> id,
  Value<String> familyId,
  Value<bool> byMe,
  Value<DateTime> visitedAt,
  Value<String> outcome,
  Value<String?> revisitOn,
  Value<String?> remarks,
  Value<bool> pending,
  Value<int> rowid,
});

class $$VisitsTableFilterComposer extends Composer<_$LocalDb, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get byMe => $composableBuilder(
    column: $table.byMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revisitOn => $composableBuilder(
    column: $table.revisitOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsTableOrderingComposer extends Composer<_$LocalDb, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get byMe => $composableBuilder(
    column: $table.byMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revisitOn => $composableBuilder(
    column: $table.revisitOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$LocalDb, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<bool> get byMe =>
      $composableBuilder(column: $table.byMe, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get revisitOn =>
      $composableBuilder(column: $table.revisitOn, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $VisitsTable,
          VisitRow,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (VisitRow, BaseReferences<_$LocalDb, $VisitsTable, VisitRow>),
          VisitRow,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$LocalDb db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<bool> byMe = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String?> revisitOn = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                familyId: familyId,
                byMe: byMe,
                visitedAt: visitedAt,
                outcome: outcome,
                revisitOn: revisitOn,
                remarks: remarks,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required bool byMe,
                required DateTime visitedAt,
                required String outcome,
                Value<String?> revisitOn = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                id: id,
                familyId: familyId,
                byMe: byMe,
                visitedAt: visitedAt,
                outcome: outcome,
                revisitOn: revisitOn,
                remarks: remarks,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, VisitRow>(table),
                  BaseReferences<_$LocalDb, $VisitsTable, VisitRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $VisitsTable,
      VisitRow,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (VisitRow, BaseReferences<_$LocalDb, $VisitsTable, VisitRow>),
      VisitRow,
      PrefetchHooks Function()
    >;
typedef $$VisitVotersTableCreateCompanionBuilder =
    VisitVotersCompanion Function({
      required String visitId,
      required String voterId,
      required String voterOutcome,
      Value<String> docsSeen,
      Value<int> rowid,
    });
typedef $$VisitVotersTableUpdateCompanionBuilder =
    VisitVotersCompanion Function({
      Value<String> visitId,
      Value<String> voterId,
      Value<String> voterOutcome,
      Value<String> docsSeen,
      Value<int> rowid,
    });

class $$VisitVotersTableFilterComposer
    extends Composer<_$LocalDb, $VisitVotersTable> {
  $$VisitVotersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voterId => $composableBuilder(
    column: $table.voterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voterOutcome => $composableBuilder(
    column: $table.voterOutcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docsSeen => $composableBuilder(
    column: $table.docsSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitVotersTableOrderingComposer
    extends Composer<_$LocalDb, $VisitVotersTable> {
  $$VisitVotersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voterId => $composableBuilder(
    column: $table.voterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voterOutcome => $composableBuilder(
    column: $table.voterOutcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docsSeen => $composableBuilder(
    column: $table.docsSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitVotersTableAnnotationComposer
    extends Composer<_$LocalDb, $VisitVotersTable> {
  $$VisitVotersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get voterId =>
      $composableBuilder(column: $table.voterId, builder: (column) => column);

  GeneratedColumn<String> get voterOutcome => $composableBuilder(
    column: $table.voterOutcome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docsSeen =>
      $composableBuilder(column: $table.docsSeen, builder: (column) => column);
}

class $$VisitVotersTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $VisitVotersTable,
          VisitVoterRow,
          $$VisitVotersTableFilterComposer,
          $$VisitVotersTableOrderingComposer,
          $$VisitVotersTableAnnotationComposer,
          $$VisitVotersTableCreateCompanionBuilder,
          $$VisitVotersTableUpdateCompanionBuilder,
          (
            VisitVoterRow,
            BaseReferences<_$LocalDb, $VisitVotersTable, VisitVoterRow>,
          ),
          VisitVoterRow,
          PrefetchHooks Function()
        > {
  $$VisitVotersTableTableManager(_$LocalDb db, $VisitVotersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitVotersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitVotersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitVotersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> visitId = const Value.absent(),
                Value<String> voterId = const Value.absent(),
                Value<String> voterOutcome = const Value.absent(),
                Value<String> docsSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitVotersCompanion(
                visitId: visitId,
                voterId: voterId,
                voterOutcome: voterOutcome,
                docsSeen: docsSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String visitId,
                required String voterId,
                required String voterOutcome,
                Value<String> docsSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitVotersCompanion.insert(
                visitId: visitId,
                voterId: voterId,
                voterOutcome: voterOutcome,
                docsSeen: docsSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitVotersTable, VisitVoterRow>(table),
                  BaseReferences<_$LocalDb, $VisitVotersTable, VisitVoterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitVotersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $VisitVotersTable,
      VisitVoterRow,
      $$VisitVotersTableFilterComposer,
      $$VisitVotersTableOrderingComposer,
      $$VisitVotersTableAnnotationComposer,
      $$VisitVotersTableCreateCompanionBuilder,
      $$VisitVotersTableUpdateCompanionBuilder,
      (
        VisitVoterRow,
        BaseReferences<_$LocalDb, $VisitVotersTable, VisitVoterRow>,
      ),
      VisitVoterRow,
      PrefetchHooks Function()
    >;
typedef $$FormsTableCreateCompanionBuilder = FormsCompanion Function({
  required String id,
  required String voterId,
  required String formType,
  Value<String?> route,
  Value<String?> referenceNo,
  Value<String?> filedOn,
  required bool byMe,
  required String currentStatus,
  required DateTime updatedAt,
  Value<bool> hasPhoto,
  Value<bool> pending,
  Value<int> rowid,
});
typedef $$FormsTableUpdateCompanionBuilder = FormsCompanion Function({
  Value<String> id,
  Value<String> voterId,
  Value<String> formType,
  Value<String?> route,
  Value<String?> referenceNo,
  Value<String?> filedOn,
  Value<bool> byMe,
  Value<String> currentStatus,
  Value<DateTime> updatedAt,
  Value<bool> hasPhoto,
  Value<bool> pending,
  Value<int> rowid,
});

class $$FormsTableFilterComposer extends Composer<_$LocalDb, $FormsTable> {
  $$FormsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voterId => $composableBuilder(
    column: $table.voterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filedOn => $composableBuilder(
    column: $table.filedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get byMe => $composableBuilder(
    column: $table.byMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPhoto => $composableBuilder(
    column: $table.hasPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormsTableOrderingComposer extends Composer<_$LocalDb, $FormsTable> {
  $$FormsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voterId => $composableBuilder(
    column: $table.voterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filedOn => $composableBuilder(
    column: $table.filedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get byMe => $composableBuilder(
    column: $table.byMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPhoto => $composableBuilder(
    column: $table.hasPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormsTableAnnotationComposer extends Composer<_$LocalDb, $FormsTable> {
  $$FormsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get voterId =>
      $composableBuilder(column: $table.voterId, builder: (column) => column);

  GeneratedColumn<String> get formType =>
      $composableBuilder(column: $table.formType, builder: (column) => column);

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filedOn =>
      $composableBuilder(column: $table.filedOn, builder: (column) => column);

  GeneratedColumn<bool> get byMe =>
      $composableBuilder(column: $table.byMe, builder: (column) => column);

  GeneratedColumn<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get hasPhoto =>
      $composableBuilder(column: $table.hasPhoto, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$FormsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $FormsTable,
          FormRow,
          $$FormsTableFilterComposer,
          $$FormsTableOrderingComposer,
          $$FormsTableAnnotationComposer,
          $$FormsTableCreateCompanionBuilder,
          $$FormsTableUpdateCompanionBuilder,
          (FormRow, BaseReferences<_$LocalDb, $FormsTable, FormRow>),
          FormRow,
          PrefetchHooks Function()
        > {
  $$FormsTableTableManager(_$LocalDb db, $FormsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> voterId = const Value.absent(),
                Value<String> formType = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<String?> filedOn = const Value.absent(),
                Value<bool> byMe = const Value.absent(),
                Value<String> currentStatus = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> hasPhoto = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormsCompanion(
                id: id,
                voterId: voterId,
                formType: formType,
                route: route,
                referenceNo: referenceNo,
                filedOn: filedOn,
                byMe: byMe,
                currentStatus: currentStatus,
                updatedAt: updatedAt,
                hasPhoto: hasPhoto,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String voterId,
                required String formType,
                Value<String?> route = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<String?> filedOn = const Value.absent(),
                required bool byMe,
                required String currentStatus,
                required DateTime updatedAt,
                Value<bool> hasPhoto = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormsCompanion.insert(
                id: id,
                voterId: voterId,
                formType: formType,
                route: route,
                referenceNo: referenceNo,
                filedOn: filedOn,
                byMe: byMe,
                currentStatus: currentStatus,
                updatedAt: updatedAt,
                hasPhoto: hasPhoto,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FormsTable, FormRow>(table),
                  BaseReferences<_$LocalDb, $FormsTable, FormRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $FormsTable,
      FormRow,
      $$FormsTableFilterComposer,
      $$FormsTableOrderingComposer,
      $$FormsTableAnnotationComposer,
      $$FormsTableCreateCompanionBuilder,
      $$FormsTableUpdateCompanionBuilder,
      (FormRow, BaseReferences<_$LocalDb, $FormsTable, FormRow>),
      FormRow,
      PrefetchHooks Function()
    >;
typedef $$FormEventsTableCreateCompanionBuilder = FormEventsCompanion Function({
  required String id,
  required String formId,
  required String status,
  required DateTime changedAt,
  Value<bool> byMe,
  Value<bool> pending,
  Value<int> rowid,
});
typedef $$FormEventsTableUpdateCompanionBuilder = FormEventsCompanion Function({
  Value<String> id,
  Value<String> formId,
  Value<String> status,
  Value<DateTime> changedAt,
  Value<bool> byMe,
  Value<bool> pending,
  Value<int> rowid,
});

class $$FormEventsTableFilterComposer
    extends Composer<_$LocalDb, $FormEventsTable> {
  $$FormEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formId => $composableBuilder(
    column: $table.formId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get byMe => $composableBuilder(
    column: $table.byMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormEventsTableOrderingComposer
    extends Composer<_$LocalDb, $FormEventsTable> {
  $$FormEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formId => $composableBuilder(
    column: $table.formId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get byMe => $composableBuilder(
    column: $table.byMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormEventsTableAnnotationComposer
    extends Composer<_$LocalDb, $FormEventsTable> {
  $$FormEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formId =>
      $composableBuilder(column: $table.formId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<bool> get byMe =>
      $composableBuilder(column: $table.byMe, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$FormEventsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $FormEventsTable,
          FormEventRow,
          $$FormEventsTableFilterComposer,
          $$FormEventsTableOrderingComposer,
          $$FormEventsTableAnnotationComposer,
          $$FormEventsTableCreateCompanionBuilder,
          $$FormEventsTableUpdateCompanionBuilder,
          (
            FormEventRow,
            BaseReferences<_$LocalDb, $FormEventsTable, FormEventRow>,
          ),
          FormEventRow,
          PrefetchHooks Function()
        > {
  $$FormEventsTableTableManager(_$LocalDb db, $FormEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> formId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<bool> byMe = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormEventsCompanion(
                id: id,
                formId: formId,
                status: status,
                changedAt: changedAt,
                byMe: byMe,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String formId,
                required String status,
                required DateTime changedAt,
                Value<bool> byMe = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormEventsCompanion.insert(
                id: id,
                formId: formId,
                status: status,
                changedAt: changedAt,
                byMe: byMe,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FormEventsTable, FormEventRow>(table),
                  BaseReferences<_$LocalDb, $FormEventsTable, FormEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $FormEventsTable,
      FormEventRow,
      $$FormEventsTableFilterComposer,
      $$FormEventsTableOrderingComposer,
      $$FormEventsTableAnnotationComposer,
      $$FormEventsTableCreateCompanionBuilder,
      $$FormEventsTableUpdateCompanionBuilder,
      (FormEventRow, BaseReferences<_$LocalDb, $FormEventsTable, FormEventRow>),
      FormEventRow,
      PrefetchHooks Function()
    >;
typedef $$FormPhotosTableCreateCompanionBuilder = FormPhotosCompanion Function({
  required String formId,
  required Uint8List bytes,
  required DateTime takenAt,
  Value<bool> uploaded,
  Value<int> rowid,
});
typedef $$FormPhotosTableUpdateCompanionBuilder = FormPhotosCompanion Function({
  Value<String> formId,
  Value<Uint8List> bytes,
  Value<DateTime> takenAt,
  Value<bool> uploaded,
  Value<int> rowid,
});

class $$FormPhotosTableFilterComposer
    extends Composer<_$LocalDb, $FormPhotosTable> {
  $$FormPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get formId => $composableBuilder(
    column: $table.formId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormPhotosTableOrderingComposer
    extends Composer<_$LocalDb, $FormPhotosTable> {
  $$FormPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get formId => $composableBuilder(
    column: $table.formId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormPhotosTableAnnotationComposer
    extends Composer<_$LocalDb, $FormPhotosTable> {
  $$FormPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get formId =>
      $composableBuilder(column: $table.formId, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);
}

class $$FormPhotosTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $FormPhotosTable,
          FormPhotoRow,
          $$FormPhotosTableFilterComposer,
          $$FormPhotosTableOrderingComposer,
          $$FormPhotosTableAnnotationComposer,
          $$FormPhotosTableCreateCompanionBuilder,
          $$FormPhotosTableUpdateCompanionBuilder,
          (
            FormPhotoRow,
            BaseReferences<_$LocalDb, $FormPhotosTable, FormPhotoRow>,
          ),
          FormPhotoRow,
          PrefetchHooks Function()
        > {
  $$FormPhotosTableTableManager(_$LocalDb db, $FormPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> formId = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormPhotosCompanion(
                formId: formId,
                bytes: bytes,
                takenAt: takenAt,
                uploaded: uploaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String formId,
                required Uint8List bytes,
                required DateTime takenAt,
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormPhotosCompanion.insert(
                formId: formId,
                bytes: bytes,
                takenAt: takenAt,
                uploaded: uploaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FormPhotosTable, FormPhotoRow>(table),
                  BaseReferences<_$LocalDb, $FormPhotosTable, FormPhotoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $FormPhotosTable,
      FormPhotoRow,
      $$FormPhotosTableFilterComposer,
      $$FormPhotosTableOrderingComposer,
      $$FormPhotosTableAnnotationComposer,
      $$FormPhotosTableCreateCompanionBuilder,
      $$FormPhotosTableUpdateCompanionBuilder,
      (FormPhotoRow, BaseReferences<_$LocalDb, $FormPhotosTable, FormPhotoRow>),
      FormPhotoRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String uuid,
  required String entity,
  required String payload,
  required DateTime createdAt,
  Value<int> attempts,
  Value<String> state,
  Value<String?> errorCode,
  Value<String?> errorHi,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> uuid,
  Value<String> entity,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String> state,
  Value<String?> errorCode,
  Value<String?> errorHi,
});

class $$OutboxTableFilterComposer extends Composer<_$LocalDb, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorHi => $composableBuilder(
    column: $table.errorHi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer extends Composer<_$LocalDb, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorHi => $composableBuilder(
    column: $table.errorHi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$LocalDb, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorHi =>
      $composableBuilder(column: $table.errorHi, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$LocalDb, $OutboxTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$LocalDb db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorHi = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                uuid: uuid,
                entity: entity,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                state: state,
                errorCode: errorCode,
                errorHi: errorHi,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String uuid,
                required String entity,
                required String payload,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorHi = const Value.absent(),
              }) => OutboxCompanion.insert(
                seq: seq,
                uuid: uuid,
                entity: entity,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                state: state,
                errorCode: errorCode,
                errorHi: errorHi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$LocalDb, $OutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$LocalDb, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$LocalDb, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableOrderingComposer extends Composer<_$LocalDb, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableAnnotationComposer extends Composer<_$LocalDb, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $MetaTable,
          MetaRow,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$LocalDb, $MetaTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$LocalDb db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaRow>(table),
                  BaseReferences<_$LocalDb, $MetaTable, MetaRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $MetaTable,
      MetaRow,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$LocalDb, $MetaTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$BoothsTableTableManager get booths =>
      $$BoothsTableTableManager(_db, _db.booths);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db, _db.families);
  $$VotersTableTableManager get voters =>
      $$VotersTableTableManager(_db, _db.voters);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$VisitVotersTableTableManager get visitVoters =>
      $$VisitVotersTableTableManager(_db, _db.visitVoters);
  $$FormsTableTableManager get forms =>
      $$FormsTableTableManager(_db, _db.forms);
  $$FormEventsTableTableManager get formEvents =>
      $$FormEventsTableTableManager(_db, _db.formEvents);
  $$FormPhotosTableTableManager get formPhotos =>
      $$FormPhotosTableTableManager(_db, _db.formPhotos);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
