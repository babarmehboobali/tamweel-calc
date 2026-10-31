import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/l10n/app_localizations.dart';
import 'package:tamweel_calc/state/app_state.dart';
import 'package:tamweel_calc/state/calculator_state.dart';
import 'package:tamweel_calc/state/rates_state.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';
import 'package:tamweel_calc/services/ads/consent_service.dart';
import 'package:tamweel_calc/ui/screens/eligibility_screen.dart';
import 'package:tamweel_calc/ui/theme.dart';
import 'dart:convert';

void main() {
  test('limiting factor labels are readable, never enum codes', () {
    for (final f in LimitingFactor.values) {
      for (final ar in [false, true]) {
        final s = limitingFactorLabel(f, ar);
        expect(s, isNot(f.name));
        expect(s.length, greaterThan(5));
      }
    }
    expect(limitingFactorLabel(LimitingFactor.dbr, false), 'Limited by DBR cap');
  });

  testWidgets('main page: hero, grouped sections, chips instead of dropdowns, safe area', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 3;
    t.view.padding = const FakeViewPadding(top: 120);
    addTearDown(t.view.reset);
    await t.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => CalculatorState()),
      ChangeNotifierProvider(create: (_) => RatesState()),
      Provider.value(value: ConsentService()),
      Provider.value(value: AdService()),
    ], child: const MaterialApp(
      localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: [Locale('en'), Locale('ar')],
      home: EligibilityScreen(),
    )));
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<Object?>), findsNothing);
    expect(find.byType(ChoiceChip), findsWidgets);
    expect(find.text('Limited by DBR cap'), findsOneWidget);
    expect(find.text('dbr'), findsNothing);
    // rates label is below the status bar inset (40dp)
    final rl = find.textContaining('updated', findRichText: true);
    if (rl.evaluate().isNotEmpty) expect(t.getTopLeft(rl.first).dy, greaterThan(40));
    // switching nationality via segmented button works
    await t.tap(find.textContaining('Saudi'));
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await t.pump(const Duration(seconds: 1));
    await t.ensureVisible(find.text('Expat'));
    await t.tap(find.text('Expat'));
    await t.pump(const Duration(seconds: 1));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 10));
  });

  for (final loc in ['en', 'ar']) {
    for (final dark in [false, true]) {
      for (final country in ['ksa', 'general']) {
        testWidgets('main page scroll-through no overflow 320dp 1.5x $loc ${dark ? 'dark' : 'light'} $country', (t) async {
          SharedPreferences.setMockInitialValues({'last_inputs': jsonEncode({'country': country, 'loanType': 'personal', 'status': 'employed', 'basic': 10000, 'housing': 2500, 'other': 0, 'emis': 0, 'cards': 0, 'rate': 5, 'tenor': 60})});
          t.view.physicalSize = const Size(960, 1800);
          t.view.devicePixelRatio = 3;
          t.view.padding = const FakeViewPadding(top: 90);
          addTearDown(t.view.reset);
          await t.pumpWidget(MultiProvider(providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => CalculatorState()),
            ChangeNotifierProvider(create: (_) => RatesState()),
            Provider.value(value: ConsentService()),
            Provider.value(value: AdService()),
          ], child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            locale: Locale(loc),
            localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
            supportedLocales: const [Locale('en'), Locale('ar')],
            builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.5)), child: w!),
            home: const EligibilityScreen(),
          )));
          await t.runAsync(() => Future.delayed(const Duration(milliseconds: 400)));
          await t.pump(const Duration(seconds: 2));
          for (var i = 0; i < 8; i++) {
            await t.drag(find.byType(Scrollable).first, const Offset(0, -400));
            await t.pump(const Duration(milliseconds: 500));
            expect(t.takeException(), isNull);
          }
          await t.pumpWidget(const SizedBox());
          await t.pump(const Duration(seconds: 10));
        });
      }
    }
  }
}
