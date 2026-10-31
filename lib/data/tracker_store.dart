import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/engine/amortization.dart';
import '../core/engine/extra_calculators.dart';

class TrackedLoan {
  final String id;
  String name;
  double principal;
  double rate;
  int months;
  DateTime start; // first due date
  Set<int> paid; // instalment numbers (1-based)
  int reminderDays; // 0 = off

  TrackedLoan({required this.id, required this.name, required this.principal, required this.rate, required this.months,
      required this.start, Set<int>? paid, this.reminderDays = 3})
      : paid = paid ?? {};

  double get emi => AmortizationEngine.emi(principal, rate, months);
  List<AmortizationRow> get schedule => AmortizationEngine.schedule(principal, rate, months);
  DateTime due(int k) => dueDate(start, k - 1);
  double get progress => months == 0 ? 0 : paid.length / months;

  /// Remaining principal after the instalments marked paid (paid in order assumption: uses count).
  double get remainingBalance {
    final s = schedule;
    final c = paid.length.clamp(0, s.length);
    return c == 0 ? principal : s[c - 1].closing;
  }

  int? get nextUnpaid {
    for (var k = 1; k <= months; k++) {
      if (!paid.contains(k)) return k;
    }
    return null;
  }

  int get notificationId => id.hashCode & 0x7fffffff;

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'p': principal, 'r': rate, 'n': months,
        's': start.toIso8601String(), 'paid': paid.toList(), 'rd': reminderDays,
      };

  factory TrackedLoan.fromJson(Map<String, dynamic> j) => TrackedLoan(
        id: j['id'], name: j['name'], principal: (j['p'] as num).toDouble(), rate: (j['r'] as num).toDouble(),
        months: j['n'], start: DateTime.parse(j['s']), paid: (j['paid'] as List).cast<int>().toSet(), reminderDays: j['rd'] ?? 3);
}

class TrackerStore {
  static const _key = 'tracked_loans';
  Future<List<TrackedLoan>> list() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => TrackedLoan.fromJson(e)).toList();
  }

  Future<void> saveAll(List<TrackedLoan> loans) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(loans.map((e) => e.toJson()).toList()));
  }
}
