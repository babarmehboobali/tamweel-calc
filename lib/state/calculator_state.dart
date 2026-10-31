import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/engine/general_mode.dart';
import '../core/models/country.dart';
import 'dart:convert';
import '../data/history_store.dart';
import '../core/engine/regulations.dart';
import '../core/models/loan_inputs.dart';
import '../core/engine/eligibility.dart';
import '../data/prefs_store.dart';

class CalculatorState extends ChangeNotifier {
  final PrefsStore _prefs = PrefsStore();
  /// Bumped when inputs are replaced externally (country switch / reopen) so screens refill their fields.
  int revision = 0;
  LoanInputs inputs = const LoanInputs(
    country: Country.ksa,
    loanType: LoanType.personal,
    employmentStatus: EmploymentStatus.employed,
    basicSalary: 10000,
    housingAllowance: 3000,
    otherAllowances: 2000,
    existingEmis: 1000,
    cardLimits: 0,
    annualRate: 6.0,
    tenorMonths: 60,
  );
  Timer? _debounce;

  CalculatorState() {
    _load();
  }

  Future<void> _load() async {
    final saved = await _prefs.getLastInputs();
    try {
      final p = await SharedPreferences.getInstance();
      GeneralSettings.currency = p.getString('gen_currency') ?? GeneralSettings.currency;
      GeneralSettings.dbrCap = p.getDouble('gen_dbr') ?? GeneralSettings.dbrCap;
      GeneralSettings.flatRate = p.getBool('gen_flat') ?? false;
      GeneralSettings.adminFeePct = p.getDouble('gen_fee_pct') ?? 0;
      GeneralSettings.adminFeeFixed = p.getDouble('gen_fee_fixed') ?? 0;
      GeneralSettings.salaryMultiple = p.getDouble('gen_multiple');
      GeneralSettings.enteredRate = p.getDouble('gen_rate');
    } catch (_) {}
    if (saved != null) {
      inputs = saved;
    } else {
      inputs = inputs.copyWith(country: defaultCountryForRegion(PlatformDispatcher.instance.locale.countryCode));
    }
    revision++;
    recompute();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void update(LoanInputs i) {
    inputs = i;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _prefs.setLastInputs(i);
      notifyListeners();
    });
  }

  void setCountry(Country c) {
    final rules = RegulationRules.forCountry(c);
    var months = inputs.tenorMonths;
    if (inputs.loanType == LoanType.mortgage) {
      months = months.clamp(12, rules.maxMortgageTenorMonths);
    } else {
      months = months.clamp(12, rules.maxConsumerTenorMonths);
    }
    _switchCountry(c, months);
  }

  void setLoanType(LoanType t) {
    final rules = RegulationRules.forCountry(inputs.country);
    var months = inputs.tenorMonths;
    if (t == LoanType.mortgage) {
      months = months.clamp(12, rules.maxMortgageTenorMonths);
      if (months < 120) months = 240;
    } else {
      months = months.clamp(12, rules.maxConsumerTenorMonths);
    }
    update(inputs.copyWith(loanType: t, tenorMonths: months));
  }

  EligibilityResult? result;
  double? _customDbr;
  DbrBase? _bankDbrBase;

  void updateAndRecalc({double? basic, double? housing, double? other, double? existingEmis, double? cardLimits,
      double? annualRate, int? tenorMonths, double? customDbr, DbrBase? bankDbrBase}) {
    _customDbr = customDbr;
    _bankDbrBase = bankDbrBase;
    inputs = inputs.copyWith(
      basicSalary: basic ?? 0, housingAllowance: housing ?? 0, otherAllowances: other ?? 0,
      existingEmis: existingEmis ?? 0, cardLimits: cardLimits ?? 0, annualRate: annualRate ?? 0,
      tenorMonths: tenorMonths ?? inputs.tenorMonths);
    recompute();
    update(inputs);
    notifyListeners();
  }

  void recompute() {
    result = EligibilityEngine.calculate(
      rules: RegulationRules.forCountry(inputs.country), loanType: inputs.loanType,
      status: inputs.employmentStatus, basic: inputs.basicSalary, housing: inputs.housingAllowance,
      other: inputs.otherAllowances, existingEmis: inputs.existingEmis, cardLimits: inputs.cardLimits,
      annualRate: inputs.annualRate, tenorMonths: inputs.tenorMonths,
      customDbrCap: _customDbr, bankDbrBase: _bankDbrBase);
  }

  Future<void> saveGeneral() async {
    recompute();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('gen_currency', GeneralSettings.currency);
    await p.setDouble('gen_dbr', GeneralSettings.dbrCap);
    await p.setBool('gen_flat', GeneralSettings.flatRate);
    await p.setDouble('gen_fee_pct', GeneralSettings.adminFeePct);
    await p.setDouble('gen_fee_fixed', GeneralSettings.adminFeeFixed);
    if (GeneralSettings.salaryMultiple != null) { await p.setDouble('gen_multiple', GeneralSettings.salaryMultiple!); } else { await p.remove('gen_multiple'); }
    if (GeneralSettings.enteredRate != null) await p.setDouble('gen_rate', GeneralSettings.enteredRate!);
  }

  /// Persist inputs for the current country, then restore the target country's last inputs if any.
  Future<void> _switchCountry(Country c, int months) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('inputs_${inputs.country.name}', jsonEncode(inputsToMap(inputs)));
    final s = p.getString('inputs_${c.name}');
    LoanInputs next = inputs.copyWith(country: c, tenorMonths: months);
    if (s != null) {
      try { next = inputsFromMap(jsonDecode(s)).copyWith(country: c); } catch (_) {}
    }
    inputs = next;
    revision++;
    recompute();
    update(inputs);
    notifyListeners();
  }

  /// Replace inputs (e.g. reopening a saved calculation).
  void restore(LoanInputs i) {
    inputs = i;
    revision++;
    recompute();
    update(i);
    notifyListeners();
  }
}
