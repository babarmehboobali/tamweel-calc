import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/l10n/app_localizations.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';
import 'package:tamweel_calc/services/ads/consent_service.dart';
import 'package:tamweel_calc/state/app_state.dart';
import 'package:tamweel_calc/state/calculator_state.dart';
import 'package:tamweel_calc/state/rates_state.dart';
import 'package:tamweel_calc/ui/theme.dart';
import 'package:tamweel_calc/ui/screens/eligibility_screen.dart';
import 'package:tamweel_calc/ui/screens/emi_schedule_screen.dart';
import 'package:tamweel_calc/ui/screens/compare_loans_screen.dart';
import 'package:tamweel_calc/ui/screens/onboarding_screen.dart';
import 'package:tamweel_calc/ui/screens/settings_screen.dart';
import 'package:tamweel_calc/ui/screens/murabaha_screen.dart';
import 'package:tamweel_calc/ui/screens/home_shell_screen.dart';
import 'package:tamweel_calc/ui/screens/banks_screen.dart';

Future<void> loadFont(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) { l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync()))); }
  await l.load();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await loadFont('Cairo', ['assets/fonts/Cairo-Regular.ttf','assets/fonts/Cairo-SemiBold.ttf','assets/fonts/Cairo-Bold.ttf']);
    await loadFont('Roboto', ['assets/fonts/Cairo-Regular.ttf']);
    await loadFont('MaterialIcons', ['/opt/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });
  final screens = <String, Widget>{
    'onboarding': const OnboardingScreen(),
    'eligibility': const EligibilityScreen(),
    'schedule': const EmiScheduleScreen(),
    'compare': const CompareLoansScreen(),
    'murabaha': const MurabahaScreen(),
    'settings': const SettingsScreen(),
    'home': const HomeShellScreen(),
    'banks': const BanksScreen(),
  };
  for (final loc in ['ar', 'en']) {
    for (final e in screens.entries) {
      testWidgets('${loc}_${e.key}', (t) async {
        t.view.physicalSize = const Size(1080, 2340); t.view.devicePixelRatio = 2.75;
        await t.pumpWidget(MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => CalculatorState()),
          ChangeNotifierProvider(create: (_) => RatesState()),
          Provider.value(value: ConsentService()),
          Provider.value(value: AdService()),
        ], child: MaterialApp(debugShowCheckedModeBanner: false, theme: AppTheme.light, locale: Locale(loc),
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          supportedLocales: const [Locale('en'), Locale('ar')], home: e.value)));
        for (var i = 0; i < 6; i++) { await t.pump(const Duration(milliseconds: 500)); }
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/${loc}_${e.key}.png'));
      });
    }
  }
}
