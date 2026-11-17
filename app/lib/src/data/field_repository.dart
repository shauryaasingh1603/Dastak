import 'package:supabase/supabase.dart';

import '../text.dart';

class BoothSummary {
  const BoothSummary({
    required this.partNo,
    required this.stationHi,
    required this.familyCount,
  });

  final int partNo;

  /// Polling station name, e.g. "प्राथमिक विद्यालय जफ़राबाद".
  final String? stationHi;
  final int familyCount;
}

class FamilyRow {
  const FamilyRow({
    required this.id,
    required this.code,
    required this.partNo,
    required this.sectionNo,
    required this.houseNo,
    required this.headNameHi,
    required this.priority,
  });

  final String id;
  final String code;
  final int partNo;
  final int? sectionNo;
  final String? houseNo;
  final String? headNameHi;

  /// 1 is the most urgent, 4 the least.
  final int priority;

  bool get isHighPriority => priority == 1;

  factory FamilyRow.fromJson(Map<String, dynamic> json) => FamilyRow(
    id: json['id'] as String,
    code: json['code'] as String,
    partNo: json['part_no'] as int,
    sectionNo: json['section_no'] as int?,
    houseNo: json['house_no'] as String?,
    headNameHi: json['head_name_hi'] as String?,
    priority: json['priority'] as int,
  );
}

/// Reads the signed-in user's work from the server. Row-level security limits
/// every query to their own booths, so no filter by user is needed for safety.
///
/// This reads online for now; the offline database replaces it next.
class FieldRepository {
  FieldRepository(this._client);

  final SupabaseClient _client;

  /// The booths the user works in, with how many families each has.
  Future<List<BoothSummary>> loadBooths(String userId) async {
    final today = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30))
        .toIso8601String()
        .substring(0, 10);

    final assignmentRows = await _client
        .from('assignments')
        .select('part_no, from_date, to_date');
    // Families can also be handed to a user one by one, outside their booths.
    final assignedRows = await _client
        .from('families')
        .select('part_no')
        .eq('assigned_user_id', userId)
        .limit(1000);

    final parts = <int>{
      for (final a in assignmentRows)
        if ((a['from_date'] as String).compareTo(today) <= 0 &&
            (a['to_date'] == null ||
                (a['to_date'] as String).compareTo(today) >= 0))
          a['part_no'] as int,
      for (final f in assignedRows) f['part_no'] as int,
    }.toList()..sort();
    if (parts.isEmpty) return const [];

    final boothRows = await _client
        .from('booths')
        .select('part_no, polling_station_hi')
        .inFilter('part_no', parts);
    final stations = {
      for (final b in boothRows)
        b['part_no'] as int: b['polling_station_hi'] as String?,
    };

    final counts = await Future.wait([
      for (final part in parts)
        _client
            .from('families')
            .count()
            .eq('part_no', part)
            .eq('is_hidden', false),
    ]);

    return [
      for (final (index, part) in parts.indexed)
        BoothSummary(
          partNo: part,
          stationHi: stations[part],
          familyCount: counts[index],
        ),
    ];
  }

  /// One booth's families, in walking order: section, then house number.
  Future<List<FamilyRow>> loadBoothFamilies(int partNo) async {
    final rows = await _client
        .from('families')
        .select(
          'id, code, part_no, section_no, house_no, head_name_hi, priority',
        )
        .eq('part_no', partNo)
        .eq('is_hidden', false)
        .limit(1000);
    final families = rows.map(FamilyRow.fromJson).toList()
      ..sort((a, b) {
        final bySection = (a.sectionNo ?? 1 << 30).compareTo(
          b.sectionNo ?? 1 << 30,
        );
        if (bySection != 0) return bySection;
        final byHouse = compareHouseNo(a.houseNo, b.houseNo);
        return byHouse != 0 ? byHouse : a.code.compareTo(b.code);
      });
    return families;
  }
}
