import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../services/ads/consent_service.dart';
import 'ad_ids.dart';

class AdaptiveBanner extends StatefulWidget {
  const AdaptiveBanner({super.key});

  @override
  State<AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends State<AdaptiveBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  double? _lastWidth;
  ConsentService? _consent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_consent == null) {
      _consent = context.read<ConsentService>();
      _consent!.adsReady.addListener(_maybeLoad);
    }
    _maybeLoad();
  }

  /// Loads only after consent is resolved and the SDK is initialized (fixes first-launch blank banner).
  void _maybeLoad() {
    if (!mounted) return;
    final width = MediaQuery.of(context).size.width;
    final c = _consent!;
    if (_lastWidth != width && c.canRequestAds && c.adsReady.value && AdIds.banner.isNotEmpty) {
      _lastWidth = width;
      _load(width.truncate());
    }
  }

  Future<void> _load(int width) async {
    _ad?.dispose();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    setState(() => _loaded = false);
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _loaded = true); },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (identical(_ad, ad)) _ad = null;
          _lastWidth = null; // allow a retry on next rebuild/size change
          if (mounted) setState(() => _loaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _consent?.adsReady.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox(height: 50);
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _loaded ? _ad!.size.height.toDouble() : 50,
      child: _loaded ? AdWidget(ad: _ad!) : const SizedBox.shrink(),
    );
  }
}
