import 'package:flutter/material.dart';
import '../data/rates_repository.dart';
import '../data/rates_models.dart';

class RatesState extends ChangeNotifier {
  final RatesRepository _repo = RatesRepository();
  RatesData? data;
  String source = 'bundled';
  String? lastUpdated;
  bool loading = false;
  String? error;

  RatesState() {
    load();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _repo.load();
      source = _repo.source;
      lastUpdated = _repo.lastUpdated;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
    refresh();
  }

  Future<void> refresh() async {
    try {
      await _repo.refresh();
      data = _repo.current;
      source = _repo.source;
      lastUpdated = _repo.lastUpdated;
      notifyListeners();
    } catch (_) {}
  }

  String get ratesUpdatedLabel => lastUpdated == null ? '' : 'Rates updated $lastUpdated';
}
