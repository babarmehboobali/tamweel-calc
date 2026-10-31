import 'package:flutter/material.dart' show ThemeMode;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/engine/regulations.dart';
import '../core/models/loan_inputs.dart';

class PrefsStore {
  static const _onboarding = 'onboarding_seen';
  static const _locale = 'locale';
  static const _theme = 'theme';
  static const _country = 'country';
  static const _islamic = 'islamic';
  static const _inputs = 'last_inputs';
  static const _adfree = 'adfree_expiry';

  Future<bool> hasSeenOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_onboarding) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_onboarding, true);
  }

  Future<String?> getLocale() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_locale);
  }

  Future<void> setLocale(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_locale, code);
  }

  Future<ThemeMode?> getThemeMode() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_theme);
    if (s == null) return null;
    return ThemeMode.values.firstWhere((e) => e.name == s, orElse: () => ThemeMode.system);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_theme, m.name);
  }

  Future<Country?> getCountry() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_country);
    if (s == null) return null;
    return Country.values.firstWhere((e) => e.name == s, orElse: () => Country.ksa);
  }

  Future<void> setCountry(Country c) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_country, c.name);
  }

  Future<bool> getIslamicMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_islamic) ?? false;
  }

  Future<void> setIslamicMode(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_islamic, v);
  }

  Future<LoanInputs?> getLastInputs() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_inputs);
    if (s == null) return null;
    try {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return LoanInputs(
        country: Country.values.firstWhere((e) => e.name == j['country']),
        loanType: LoanType.values.firstWhere((e) => e.name == j['loanType']),
        employmentStatus: EmploymentStatus.values.firstWhere((e) => e.name == j['status']),
        basicSalary: (j['basic'] as num).toDouble(),
        housingAllowance: (j['housing'] as num).toDouble(),
        otherAllowances: (j['other'] as num).toDouble(),
        existingEmis: (j['emis'] as num).toDouble(),
        cardLimits: (j['cards'] as num).toDouble(),
        annualRate: (j['rate'] as num).toDouble(),
        tenorMonths: j['tenor'] as int,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastInputs(LoanInputs i) async {
    final p = await SharedPreferences.getInstance();
    final j = {
      'country': i.country.name,
      'loanType': i.loanType.name,
      'status': i.employmentStatus.name,
      'basic': i.basicSalary,
      'housing': i.housingAllowance,
      'other': i.otherAllowances,
      'emis': i.existingEmis,
      'cards': i.cardLimits,
      'rate': i.annualRate,
      'tenor': i.tenorMonths,
    };
    await p.setString(_inputs, jsonEncode(j));
  }

  Future<DateTime?> getAdFreeExpiry() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_adfree);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> setAdFreeExpiry(DateTime d) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_adfree, d.toIso8601String());
  }
}
