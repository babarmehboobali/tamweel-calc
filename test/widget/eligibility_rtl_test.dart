import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamweel_calc/l10n/app_localizations.dart';
import 'package:tamweel_calc/ui/screens/eligibility_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/state/app_state.dart';
import 'package:tamweel_calc/state/calculator_state.dart';
import 'package:tamweel_calc/state/rates_state.dart';
import 'package:tamweel_calc/services/ads/ad_service.dart';
import 'package:tamweel_calc/services/ads/consent_service.dart';

void main() {
  testWidgets('eligibility screen RTL in Arabic', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => CalculatorState()),
      ChangeNotifierProvider(create: (_) => RatesState()),
      Provider.value(value: ConsentService()),
      Provider.value(value: AdService()),
    ], child: MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: const EligibilityScreen(),
    )));
    await tester.pump(const Duration(seconds: 1));
    expect(Directionality.of(tester.element(find.byType(EligibilityScreen))), TextDirection.rtl);
  });
}
