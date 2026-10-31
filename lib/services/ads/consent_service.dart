import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class ConsentService {
  bool _canRequestAds = false;
  bool privacyOptionsRequired = false;
  bool _initialized = false;

  bool get canRequestAds => _canRequestAds;

  /// True once consent is resolved AND the Mobile Ads SDK is initialized.
  /// Banners listen to this so they load on the very first launch.
  final ValueNotifier<bool> adsReady = ValueNotifier(false);

  Future<bool> requestConsent() async {
    if (_initialized) return _canRequestAds;
    final completer = Completer<bool>();

    // Check previous session consent first
    final previous = await ConsentInformation.instance.canRequestAds();
    if (previous) {
      _canRequestAds = true;
      _initialized = true;
      completer.complete(true);
      return completer.future;
    }

    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await ConsentForm.loadAndShowConsentFormIfRequired((formError) {});
          }
          _canRequestAds = await ConsentInformation.instance.canRequestAds();
          privacyOptionsRequired = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() == PrivacyOptionsRequirementStatus.required;
        } catch (_) {
          _canRequestAds = false;
        }
        _initialized = true;
        if (!completer.isCompleted) completer.complete(_canRequestAds);
      },
      (error) {
        _canRequestAds = false;
        _initialized = true;
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    return completer.future;
  }

  /// iOS only: show Apple's App Tracking Transparency prompt (after UMP, before
  /// ads load). No-op on Android/web. Ads still serve (non-personalized) if denied.
  Future<void> requestTrackingAuthorization() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // Small delay: iOS ignores the request if the app is not yet active.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {}
  }

  Future<void> showPrivacyOptions() async {
    await ConsentForm.showPrivacyOptionsForm((_) {});
  }
}
