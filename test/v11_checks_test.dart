import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/core/engine/amortization.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/general_mode.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';
import 'package:tamweel_calc/core/utils/formatters.dart';
import 'package:tamweel_calc/l10n/app_localizations.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';
import 'package:tamweel_calc/services/ads/consent_service.dart';
import 'package:tamweel_calc/state/app_state.dart';
import 'package:tamweel_calc/state/calculator_state.dart';
import 'package:tamweel_calc/state/rates_state.dart';
import 'package:tamweel_calc/ui/screens/home_shell_screen.dart';
import 'package:tamweel_calc/ui/theme.dart';
import 'package:tamweel_calc/ui/widgets/motion.dart';

void main() {
  group('worked calculations (v11 re-verify)', () {
    test('Saudi basic-only base', () {
      final r = EligibilityEngine.calculate(
        rules: RegulationRules.forCountry(Country.ksa), loanType: LoanType.personal, status: EmploymentStatus.employed,
        basic: 10000, housing: 2500, other: 0, existingEmis: 0, cardLimits: 0, annualRate: 5, tenorMonths: 60,
        bankDbrBase: DbrBase.basicOnly,
      );
      expect(r.remainingEmi, closeTo(3333, 0.5));
      expect(r.maxFinancing, closeTo(176618.02, 0.5));
    });
    test('NBK APR 6.92%', () {
      const p = 20443.47;
      final emi = AmortizationEngine.emi(p, 6.5, 60);
      expect(GeneralSettings.effectiveApr(p, emi, 60, p * 0.01), closeTo(6.92, 0.01));
    });
    test('12,000 at 12% for 12 months', () {
      expect(AmortizationEngine.emi(12000, 12, 12), closeTo(1066.19, 0.01));
    });
  });

  group('currency formatting', () {
    test('English: code after number', () {
      expect(Formatters.currency(1234.5, 'SAR'), '1,234.50 SAR');
      expect(Formatters.currency(-50, 'SAR'), '-50.00 SAR');
    });
    test('Arabic: localized symbol after number, minus kept with digits', () {
      final s = Formatters.currency(1234.5, 'SAR', isArabic: true);
      expect(s.endsWith('ر.س'), isTrue);
      expect(Formatters.plain(s), '1,234.50 ر.س');
      final n = Formatters.currency(-50, 'KWD', isArabic: true);
      expect(Formatters.plain(n), '-50.000 د.ك');
      expect(n.startsWith('\u2066-'), isTrue);
    });
  });

  testWidgets('CountUpText ends at final value', (t) async {
    await t.pumpWidget(MaterialApp(home: CountUpText(value: 100, format: (v) => v.toStringAsFixed(0))));
    await t.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });

  for (final loc in ['en', 'ar']) {
    for (final dark in [false, true]) {
      testWidgets('no overflow 320dp, font 1.5x, $loc ${dark ? 'dark' : 'light'}', (t) async {
        SharedPreferences.setMockInitialValues({});
        t.view.physicalSize = const Size(960, 2000);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        await t.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => CalculatorState()),
            ChangeNotifierProvider(create: (_) => RatesState()),
            Provider.value(value: ConsentService()),
            Provider.value(value: AdService()),
          ],
          child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            locale: Locale(loc),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
            builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.5)), child: w!),
            home: const HomeShellScreen(),
          ),
        ));
        for (var i = 0; i < 5; i++) {
          await t.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
          await t.pump(const Duration(seconds: 1));
          await t.tap(find.byType(NavigationDestination).at(i == 4 ? 4 : (i + 1) % 5));
          await t.pump(const Duration(seconds: 1));
        }
        await t.pump(const Duration(seconds: 2));
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 30));
      });
    }
  }
}
