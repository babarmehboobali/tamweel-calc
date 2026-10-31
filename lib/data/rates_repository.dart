import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'rates_models.dart';

class RatesRepository {
  static const String remoteUrl = 'https://raw.githubusercontent.com/your-org/tamweel-rates/main/banks.json';
  static const String cacheKey = 'banks_cache_v2';
  static const String metaKey = 'banks_meta_v2';

  RatesData? current;
  String source = 'bundled';
  String? lastUpdated;
  String? version;

  Future<RatesData> load() async {
    // 1. Try cache
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final meta = prefs.getString(metaKey);
    if (cached != null && meta != null) {
      try {
        final data = RatesData.fromJson(jsonDecode(cached));
        final m = jsonDecode(meta);
        source = 'cache';
        lastUpdated = m['lastUpdated'];
        version = m['version'];
        current = data;
        return data;
      } catch (_) {}
    }

    // 2. Bundled fallback
    final raw = await rootBundle.loadString('assets/banks.json');
    final data = RatesData.fromJson(jsonDecode(raw));
    source = 'bundled';
    lastUpdated = data.updatedAt;
    version = data.schemaVersion.toString();
    current = data;
    return data;
  }

  Future<void> refresh() async {
    try {
      final res = await http.get(Uri.parse(remoteUrl)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = RatesData.fromJson(json);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, res.body);
        await prefs.setString(metaKey, jsonEncode({
          'version': data.schemaVersion,
          'lastUpdated': data.updatedAt,
          'fetchedAt': DateTime.now().toIso8601String(),
        }));
        current = data;
        source = 'remote';
        lastUpdated = data.updatedAt;
        version = data.schemaVersion.toString();
      }
    } catch (_) {
      // keep existing
    }
  }
}
