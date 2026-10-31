import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamweel_calc/state/calculator_state.dart';
import 'package:tamweel_calc/state/app_state.dart';
import 'package:tamweel_calc/state/rates_state.dart';

import 'package:tamweel_calc/ui/screens/eligibility_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tamweel_calc/l10n/app_localizations.dart';

void main() {
  testWidgets('eligibility hero shows max financing on first frame', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => CalculatorState()),
        ChangeNotifierProvider(create: (_) => RatesState()),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('ar')],
        home: EligibilityScreen(),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(find.textContaining('Max financing'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Max financing'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
