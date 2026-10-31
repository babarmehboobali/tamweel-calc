import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/engine/regulations.dart';
import '../core/models/loan_inputs.dart';

Map<String, dynamic> inputsToMap(LoanInputs i) => {
      'country': i.country.name, 'loanType': i.loanType.name, 'status': i.employmentStatus.name,
      'basic': i.basicSalary, 'housing': i.housingAllowance, 'other': i.otherAllowances,
      'emis': i.existingEmis, 'cards': i.cardLimits, 'rate': i.annualRate, 'tenor': i.tenorMonths,
      'customDbr': i.customDbrCap,
    };

LoanInputs inputsFromMap(Map<String, dynamic> j) => LoanInputs(
      country: Country.values.firstWhere((e) => e.name == j['country'], orElse: () => Country.general),
      loanType: LoanType.values.firstWhere((e) => e.name == j['loanType'], orElse: () => LoanType.personal),
      employmentStatus: EmploymentStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => EmploymentStatus.employed),
      basicSalary: (j['basic'] as num? ?? 0).toDouble(),
      housingAllowance: (j['housing'] as num? ?? 0).toDouble(),
      otherAllowances: (j['other'] as num? ?? 0).toDouble(),
      existingEmis: (j['emis'] as num? ?? 0).toDouble(),
      cardLimits: (j['cards'] as num? ?? 0).toDouble(),
      annualRate: (j['rate'] as num? ?? 0).toDouble(),
      tenorMonths: (j['tenor'] as num? ?? 60).toInt(),
      customDbrCap: (j['customDbr'] as num?)?.toDouble(),
    );

class SavedCalc {
  final String id;
  final String name;
  final DateTime date;
  final LoanInputs inputs;
  final Map<String, String> results;
  SavedCalc({required this.id, required this.name, required this.date, required this.inputs, required this.results});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'date': date.toIso8601String(), 'inputs': inputsToMap(inputs), 'results': results};
  static SavedCalc fromJson(Map<String, dynamic> j) => SavedCalc(
        id: j['id'], name: j['name'], date: DateTime.parse(j['date']),
        inputs: inputsFromMap(Map<String, dynamic>.from(j['inputs'])),
        results: Map<String, String>.from(j['results'] ?? {}),
      );
}

class HistoryStore {
  static const _key = 'saved_calcs';

  static Future<List<SavedCalc>> list() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null) return [];
    try {
      return (jsonDecode(s) as List).map((e) => SavedCalc.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(List<SavedCalc> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> save(SavedCalc c) async {
    final items = await list();
    items.insert(0, c);
    await _write(items.take(100).toList());
  }

  static Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((e) => e.id == id);
    await _write(items);
  }

  /// Clears history, per-country inputs, last inputs and general-mode settings.
  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    for (final k in p.getKeys().toList()) {
      if (k == _key || k.startsWith('inputs_') || k.startsWith('gen_') || k == 'last_inputs') await p.remove(k);
    }
  }
}
