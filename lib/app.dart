import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'state/app_state.dart';
import 'ui/theme.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/home_shell_screen.dart';

class TamweelApp extends StatelessWidget {
  const TamweelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final effectiveLocale = appState.locale ?? (deviceLocale.languageCode == 'ar' ? const Locale('ar') : const Locale('en'));

    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appState.themeMode,
      locale: effectiveLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: appState.hasSeenOnboarding ? const HomeShellScreen() : const OnboardingScreen(),
    );
  }
}
