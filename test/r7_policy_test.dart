import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';
import 'package:tamweel_calc/services/export/csv_export.dart';
import 'package:tamweel_calc/core/engine/amortization.dart';
import 'package:tamweel_calc/core/utils/formatters.dart';

void main() {
  test('no interstitial within 60s after a result screen; 120s cooldown kept', () {
    var now = DateTime(2026, 1, 1, 12);
    final ads = AdService(clock: () => now)..hasInterstitialForTest = true..markSessionUsed();
    ads.markResultViewed();
    for (var i = 0; i < 6; i++) {
      expect(ads.canShowInterstitial(), isFalse);
    }
    expect(ads.canShowInterstitial(fromResultScreen: true), isFalse);
    now = now.add(const Duration(seconds: 61));
    var shown = false;
    for (var i = 0; i < 3; i++) {
      shown = shown || ads.canShowInterstitial();
    }
    expect(shown, isTrue);
    ads.recordInterstitialShown();
    now = now.add(const Duration(seconds: 89));
    for (var i = 0; i < 6; i++) {
      expect(ads.canShowInterstitial(), isFalse);
    }
  });

  test('CSV schedule has BOM, header, dated rows', () {
    final csv = CsvExport.scheduleCsv(AmortizationEngine.schedule(12000, 12, 12), start: DateTime(2026, 1, 31));
    final lines = csv.split('\r\n')..removeLast();
    expect(lines.first, '\uFEFFMonth,Date,Instalment,Principal,Profit,Balance');
    expect(lines.length, 13);
    expect(lines[1], '1,2026-01-31,1066.19,946.19,120.00,11053.81');
    expect(lines[2].split(',')[1], '2026-02-28');
  });

  test('digit setting', () {
    Formatters.arabicDigits = true;
    expect(Formatters.number(1234, isArabic: true), '١,٢٣٤');
    expect(Formatters.number(1234), '1,234');
    Formatters.arabicDigits = false;
    expect(Formatters.number(1234, isArabic: true), '1,234');
  });
}
