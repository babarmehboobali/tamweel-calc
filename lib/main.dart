import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/ads/consent_service.dart';
import 'services/ads/ad_service.dart';
import 'state/app_state.dart';
import 'state/calculator_state.dart';
import 'state/rates_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final consentService = ConsentService();
  final adService = AdService();

  // Non-blocking: show UI immediately
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => CalculatorState()),
        ChangeNotifierProvider(create: (_) => RatesState()),
        Provider.value(value: consentService),
        Provider.value(value: adService),
      ],
      child: const TamweelApp(),
    ),
  );

  // Consent + ads init after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await consentService.requestConsent();
    await consentService.requestTrackingAuthorization(); // iOS ATT; no-op on Android
    if (consentService.canRequestAds) {
      await adService.initialize();
      consentService.adsReady.value = true;
    }
  });
}
