import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../data/prefs_store.dart';
import 'ad_ids.dart';

class AdService {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  DateTime? _lastInterstitial;
  int _actions = 0;
  bool _firstSession = true;
  final PrefsStore _prefs = PrefsStore();
  final DateTime Function() clock;
  AdService({DateTime Function()? clock}) : clock = clock ?? DateTime.now;

  @visibleForTesting
  bool hasInterstitialForTest = false;
  @visibleForTesting
  void recordInterstitialShown() => _lastInterstitial = clock();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded(); // preloaded only; no rewarded placement in the UI yet
    _loadAppOpen();
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.foreground) _maybeShowAppOpen();
    });
    final expiry = await _prefs.getAdFreeExpiry();
    if (expiry != null && DateTime.now().isBefore(expiry)) {
      // already ad-free
    }
  }

  void _loadInterstitial() {
    if (AdIds.interstitial.isEmpty) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  // ---- App open (shown only when returning to the app, never on cold start) ----
  AppOpenAd? _appOpen;
  DateTime? _appOpenLoadedAt;
  DateTime? _lastAppOpen;
  bool _fullScreenShowing = false;
  static const appOpenCooldownMinutes = 5;

  void _loadAppOpen() {
    if (AdIds.appOpen.isEmpty) return;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpen = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (_) => _appOpen = null,
      ),
    );
  }

  Future<void> _maybeShowAppOpen() async {
    if (_fullScreenShowing || _appOpen == null) {
      if (_appOpen == null) _loadAppOpen();
      return;
    }
    if (await isAdFree()) return;
    final now = clock();
    if (_appOpenLoadedAt != null && DateTime.now().difference(_appOpenLoadedAt!).inHours >= 4) {
      _appOpen!.dispose();
      _appOpen = null;
      _loadAppOpen();
      return;
    }
    if (_lastAppOpen != null && now.difference(_lastAppOpen!).inMinutes < appOpenCooldownMinutes) return;
    if (_lastInterstitial != null && now.difference(_lastInterstitial!).inSeconds < interstitialCooldownSeconds) return;
    _fullScreenShowing = true;
    _appOpen!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpen = null;
        _fullScreenShowing = false;
        _lastAppOpen = clock();
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _appOpen = null;
        _fullScreenShowing = false;
        _loadAppOpen();
      },
    );
    _appOpen!.show();
  }

  void _loadRewarded() {
    if (AdIds.rewarded.isEmpty) return;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  DateTime? _lastResultView;

  /// Called by every result screen. Interstitials are never shown on, or within
  /// [resultQuietSeconds] after, a result screen (R7 ads policy).
  void markResultViewed() => _lastResultView = clock();
  static const resultQuietSeconds = 60;
  static const interstitialCooldownSeconds = 120;

  bool canShowInterstitial({bool fromResultScreen = false}) {
    if (_firstSession || fromResultScreen) return false;
    final now = clock();
    if (_lastResultView != null && now.difference(_lastResultView!).inSeconds < resultQuietSeconds) return false;
    if (_lastInterstitial != null && now.difference(_lastInterstitial!).inSeconds < interstitialCooldownSeconds) return false;
    _actions++;
    return _actions % 3 == 0 && (_interstitial != null || hasInterstitialForTest);
  }

  void markSessionUsed() => _firstSession = false;

  void showInterstitial(VoidCallback onDone) {
    if (_interstitial == null) {
      onDone();
      return;
    }
    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _fullScreenShowing = false;
        _lastInterstitial = clock();
        _loadInterstitial();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _fullScreenShowing = false;
        onDone();
      },
    );
    _fullScreenShowing = true;
    _interstitial!.show();
  }

  Future<void> showRewarded({required VoidCallback onReward, required BuildContext context}) async {
    if (_rewarded == null) {
      await _grantAdFree();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad-free for 24h')));
      }
      onReward();
      return;
    }
    var earned = false;
    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _fullScreenShowing = false;
        _loadRewarded();
        if (earned) {
          _grantAdFree();
          onReward();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        _fullScreenShowing = false;
        _grantAdFree();
        onReward();
      },
    );
    _fullScreenShowing = true;
    await _rewarded!.show(onUserEarnedReward: (_, __) => earned = true);
  }

  Future<void> _grantAdFree() async {
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await _prefs.setAdFreeExpiry(expiry);
  }

  Future<bool> isAdFree() async {
    final expiry = await _prefs.getAdFreeExpiry();
    return expiry != null && DateTime.now().isBefore(expiry);
  }
}
