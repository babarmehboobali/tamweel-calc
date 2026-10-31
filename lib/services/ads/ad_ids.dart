import 'package:flutter/foundation.dart';

// iOS uses its OWN AdMob app + units (never reuse the Android IDs).
// The iOS app ID itself lives in ios/Flutter/Release.xcconfig (GAD_APPLICATION_ID).

/// Debug builds (or --dart-define=USE_TEST_ADS=true) always use Google's sample
/// units so test taps never hit the real AdMob account. Release uses real units.
class AdIds {
  static const testApp = 'ca-app-pub-3940256099942544~3347511713';
  static const testBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const testAppOpen = 'ca-app-pub-3940256099942544/9257395921';

  static const realApp = 'ca-app-pub-1235513372019694~1877492677';
  static const realBanner = 'ca-app-pub-1235513372019694/7360919492';
  static const realInterstitial = 'ca-app-pub-1235513372019694/5298909118';
  static const realRewarded = 'ca-app-pub-1235513372019694/3904890215';
  static const realAppOpen = 'ca-app-pub-1235513372019694/6047837826';

  // Google sample iOS units
  static const testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const testAppOpenIos = 'ca-app-pub-3940256099942544/5575463023';

  // TODO(AdMob iOS): paste your iOS ad unit IDs here (AdMob > Apps > Tamweel iOS > Ad units).
  // While empty, iOS release builds fall back to Google's test units (no revenue, no policy risk).
  static const realBannerIos = ''; // IOS_BANNER_PLACEHOLDER
  static const realInterstitialIos = ''; // IOS_INTERSTITIAL_PLACEHOLDER
  static const realRewardedIos = ''; // IOS_REWARDED_PLACEHOLDER
  static const realAppOpenIos = ''; // IOS_APPOPEN_PLACEHOLDER

  static bool get isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static String _pick(String testA, String realA, String testI, String realI) {
    if (isIos) return (useTest || realI.isEmpty) ? testI : realI;
    return useTest ? testA : realA;
  }

  static bool get useTest => kDebugMode || const bool.fromEnvironment('USE_TEST_ADS');

  static String get banner => _pick(testBanner, realBanner, testBannerIos, realBannerIos);
  static String get interstitial => _pick(testInterstitial, realInterstitial, testInterstitialIos, realInterstitialIos);
  static String get rewarded => _pick(testRewarded, realRewarded, testRewardedIos, realRewardedIos);
  static String get appOpen => _pick(testAppOpen, realAppOpen, testAppOpenIos, realAppOpenIos);
}
