import 'package:flutter/material.dart';
import '../data/prefs_store.dart';
import '../core/engine/regulations.dart';
import '../core/utils/formatters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final PrefsStore _prefs = PrefsStore();
  bool hasSeenOnboarding = false;
  Locale? locale;
  ThemeMode themeMode = ThemeMode.system;
  bool islamicMode = false;
  double? customDbrCap;
  Country selectedCountry = Country.ksa;
  bool arabicDigits = false;

  AppState() {
    _load();
  }

  Future<void> _load() async {
    hasSeenOnboarding = await _prefs.hasSeenOnboarding();
    final code = await _prefs.getLocale();
    if (code != null) locale = Locale(code);
    final theme = await _prefs.getThemeMode();
    if (theme != null) themeMode = theme;
    selectedCountry = await _prefs.getCountry() ?? Country.ksa;
    islamicMode = await _prefs.getIslamicMode();
    arabicDigits = (await SharedPreferences.getInstance()).getBool('arabic_digits') ?? false;
    Formatters.arabicDigits = arabicDigits;
    notifyListeners();
  }

  Future<void> completeOnboarding({required Country country, required Locale? loc}) async {
    hasSeenOnboarding = true;
    selectedCountry = country;
    locale = loc;
    await _prefs.setOnboardingSeen();
    await _prefs.setCountry(country);
    if (loc != null) await _prefs.setLocale(loc.languageCode);
    notifyListeners();
  }

  void setLocale(Locale? l) {
    locale = l;
    if (l != null) _prefs.setLocale(l.languageCode);
    notifyListeners();
  }

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    _prefs.setThemeMode(m);
    notifyListeners();
  }

  void setIslamicMode(bool v) {
    islamicMode = v;
    _prefs.setIslamicMode(v);
    notifyListeners();
  }

  Future<void> setArabicDigits(bool v) async {
    arabicDigits = v;
    Formatters.arabicDigits = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('arabic_digits', v);
  }

  void setCustomDbr(double? v) {
    customDbrCap = v;
    notifyListeners();
  }

  void setCountry(Country c) {
    selectedCountry = c;
    _prefs.setCountry(c);
    notifyListeners();
  }
}
