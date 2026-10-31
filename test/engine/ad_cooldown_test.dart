import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('interstitial respects first session, every-3rd action and 120s cooldown', () {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 1, 1, 12);
    final ads = AdService(clock: () => now)..hasInterstitialForTest = true;
    expect(ads.canShowInterstitial(), isFalse); // first session
    ads.markSessionUsed();
    expect(ads.canShowInterstitial(), isFalse); // 1
    expect(ads.canShowInterstitial(), isFalse); // 2
    expect(ads.canShowInterstitial(), isTrue); // 3
    ads.recordInterstitialShown();
    now = now.add(const Duration(seconds: 30));
    for (var i = 0; i < 3; i++) {
      expect(ads.canShowInterstitial(), isFalse); // inside cooldown
    }
    now = now.add(const Duration(seconds: 91));
    expect(ads.canShowInterstitial(), isFalse);
    expect(ads.canShowInterstitial(), isFalse);
    expect(ads.canShowInterstitial(), isTrue);
  });
}
