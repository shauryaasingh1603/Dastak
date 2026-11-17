import 'package:supabase/supabase.dart';

class BoothSummary {
  const BoothSummary({
    required this.partNo,
    required this.nameHi,
    required this.familyCount,
  });
  final int partNo;
  final String nameHi;
  final int familyCount;
}

class FamilyRow {
  const FamilyRow({
    required this.id,
    required this.code,
    required this.partNo,
    required this.houseNo,
    required this.headNameHi,
    required this.priority,
  });

  final String id;
  final String code;
  final int partNo;
  final String? houseNo;
  final String? headNameHi;

  /// 1 is the most urgent, 4 the least.
  final int priority;

  bool get isHighPriority => priority == 1;

  factory FamilyRow.fromJson(Map<String, dynamic> json) => FamilyRow(
    id: json['id'] as String,
    code: json['code'] as String,
    partNo: json['part_no'] as int,
    houseNo: json['house_no'] as String?,
    headNameHi: json['head_name_hi'] as String?,
    priority: json['priority'] as int,
  );
}

class HomeData {
  const HomeData({required this.booths, required this.families});
  final List<BoothSummary> booths;
  final List<FamilyRow> families;
}

/// Reads the signed-in user's work from the server. Row-level security limits
/// every query to their own booths, so no filter by user is needed here.
///
/// This reads online for now; the offline database replaces it next.
class FieldRepository {
  FieldRepository(this._client);

  final SupabaseClient _client;

  Future<HomeData> loadHome() async {
    final familyRows = await _client
        .from('families')
        .select('id, code, part_no, house_no, head_name_hi, priority')
        .eq('is_hidden', false)
        .order('part_no')
        .order('priority')
        .order('code')
        .limit(1000);
    final families = familyRows.map(FamilyRow.fromJson).toList();

    final assignmentRows = await _client
        .from('assignments')
        .select('part_no, to_date');
    final today = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30))
        .toIso8601String()
        .substring(0, 10);
    final parts = <int>{
      for (final f in families) f.partNo,
      for (final a in assignmentRows)
        if (a['to_date'] == null ||
            (a['to_date'] as String).compareTo(today) >= 0)
          a['part_no'] as int,
    };

    final boothRows = parts.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _client
              .from('booths')
              .select('part_no, name_hi')
              .inFilter('part_no', parts.toList())
              .order('part_no');

    final counts = <int, int>{};
    for (final f in families) {
      counts[f.partNo] = (counts[f.partNo] ?? 0) + 1;
    }
    final booths = [
      for (final b in boothRows)
        BoothSummary(
          partNo: b['part_no'] as int,
          nameHi: b['name_hi'] as String,
          familyCount: counts[b['part_no']] ?? 0,
        ),
    ];
    return HomeData(booths: booths, families: families);
  }
}
