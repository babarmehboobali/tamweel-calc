import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamweel_calc/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/state/app_state.dart';
import 'package:tamweel_calc/state/calculator_state.dart';
import 'package:tamweel_calc/state/rates_state.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';
import 'package:tamweel_calc/services/ads/consent_service.dart';
import 'package:tamweel_calc/ui/theme.dart';
import 'package:tamweel_calc/ui/screens/eligibility_screen.dart';
import 'package:tamweel_calc/ui/screens/banks_screen.dart';
import 'package:tamweel_calc/ui/screens/compare_loans_screen.dart';
import 'package:tamweel_calc/ui/screens/emi_schedule_screen.dart';
import 'package:tamweel_calc/ui/screens/settings_screen.dart';
import 'package:tamweel_calc/ui/screens/saved_calcs_screen.dart';
import 'dart:convert';
import 'package:tamweel_calc/ui/screens/r7_calculators.dart';
import 'package:tamweel_calc/ui/screens/loan_tracker_screen.dart';

Future<void> loadFonts() async {
  for (final f in [['Cairo','assets/fonts/Cairo-Regular.ttf'],['Cairo','assets/fonts/Cairo-Bold.ttf'],['Roboto','/opt/flutter/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf']]) {
    final file = File(f[1]); if (!file.existsSync()) continue;
    final l = FontLoader(f[0])..addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer))); await l.load();
  }
  final mi = File('/opt/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (mi.existsSync()) { final l = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(mi.readAsBytesSync().buffer))); await l.load(); }
}

Map<String, Object> inputsFor(String c, {double basic = 10000, double housing = 2500, double rate = 5, int tenor = 60}) => {
  'last_inputs': jsonEncode({'country': c, 'loanType': 'personal', 'status': 'employed', 'basic': basic, 'housing': housing, 'other': 0, 'emis': 0, 'cards': 0, 'rate': rate, 'tenor': tenor}),
  'country': c,
};

class Shot {
  final Widget Function() screen;
  final Map<String, Object> prefs;
  final Future<void> Function(WidgetTester t)? act;
  final bool dark;
  Shot(this.screen, this.prefs, {this.act, this.dark = false});
}

Future<void> settle(WidgetTester t, [int ms = 800]) async {
  await t.runAsync(() => Future.delayed(Duration(milliseconds: ms)));
  for (var i = 0; i < 10; i++) { await t.pump(const Duration(milliseconds: 200)); }
}

void main() {
  final loan = jsonEncode([{'id': 'a1', 'name': 'Personal loan', 'p': 200000, 'r': 6, 'n': 60, 's': '2026-06-27T00:00:00.000', 'paid': [1,2,3,4,5], 'rd': 3}]);
  Future<void> scroll(WidgetTester t, double dy) async { await t.drag(find.byType(Scrollable).first, Offset(0, -dy)); await settle(t, 200); }
  final shots = <String, Shot>{
    'prepay': Shot(prepaymentScreen, inputsFor('ksa'), act: (t) => scroll(t, 500)),
    'reverse': Shot(reverseScreen, inputsFor('ksa')),
    'refinance': Shot(refinanceScreen, inputsFor('ksa'), act: (t) => scroll(t, 900)),
    'mortgage': Shot(mortgageScreen, inputsFor('ksa')),
    'balloon': Shot(balloonScreen, inputsFor('ksa'), act: (t) => scroll(t, 250)),
    'card': Shot(creditCardScreen, inputsFor('ksa')),
    'tracker': Shot(() => const LoanTrackerScreen(), {...inputsFor('ksa'), 'tracked_loans': loan}, act: (t) async {
      await t.tap(find.byType(ListTile).first); await settle(t, 400);
    }),
    'schedule': Shot(() => const EmiScheduleScreen(), inputsFor('ksa'), act: (t) => scroll(t, 450)),
    'settings': Shot(() => const SettingsScreen(), {'broker_on': true, 'broker_name': 'Al Noor Finance', 'broker_phone': '+966 55 123 4567'}, act: (t) => scroll(t, 450)),
    'darkprepay': Shot(prepaymentScreen, inputsFor('ksa'), dark: true),
  };
  for (final loc in ['ar','en']) for (final e in shots.entries) {
    testWidgets('$loc ${e.key}', (tester) async {
      await tester.runAsync(loadFonts);
      tester.view.physicalSize = const Size(1080, 2340); tester.view.devicePixelRatio = 3;
      SharedPreferences.setMockInitialValues(e.value.prefs);
      await tester.pumpWidget(MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => CalculatorState()),
        ChangeNotifierProvider(create: (_) => RatesState()),
        Provider.value(value: ConsentService()),
        Provider.value(value: AdService()),
      ], child: MaterialApp(debugShowCheckedModeBanner: false,
        theme: AppTheme.light, darkTheme: AppTheme.dark,
        themeMode: e.value.dark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(loc),
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        supportedLocales: const [Locale('ar'), Locale('en')],
        home: e.value.screen(),
      )));
      await settle(tester, 2000);
      if (e.value.act != null) await e.value.act!(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/${loc}_${e.key}.png'));
    });
  }
}
