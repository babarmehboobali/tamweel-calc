import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color accent = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  static const double space1 = 8;
  static const double space2 = 16;
  static const double space3 = 24;
  static const double space4 = 32;

  static const TextStyle _buttonText = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle currencyStyle = TextStyle(
    fontFamily: 'Cairo',
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w600,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          surface: surface,
                    onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        fontFamily: 'Cairo',
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(allowEnterRouteSnapshotting: false),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 2, titleTextStyle: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700)),
        sliderTheme: const SliderThemeData(showValueIndicator: ShowValueIndicator.onlyForDiscrete, trackHeight: 4),
        chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, letterSpacing: -0.5),
          titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: 'Cairo', fontFeatures: [FontFeature.tabularFigures()]),
          bodyMedium: TextStyle(fontFamily: 'Cairo', fontFeatures: [FontFeature.tabularFigures()]),
          labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: const Color(0x220F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: surface,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.6)),
          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: _buttonText,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: _buttonText,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(textStyle: _buttonText),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(textStyle: _buttonText),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(textStyle: WidgetStateProperty.all(_buttonText)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: primary.withValues(alpha: 0.14),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: const Color(0xFF14B8A6),
          secondary: accentLight,
        ),
        fontFamily: 'Cairo',
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(allowEnterRouteSnapshotting: false),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 2, titleTextStyle: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700)),
        sliderTheme: const SliderThemeData(showValueIndicator: ShowValueIndicator.onlyForDiscrete, trackHeight: 4),
        chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Cairo', fontFeatures: [FontFeature.tabularFigures()]),
          bodyMedium: TextStyle(fontFamily: 'Cairo', fontFeatures: [FontFeature.tabularFigures()]),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1B2A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0x1FFFFFFF))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: _buttonText,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(textStyle: _buttonText),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(textStyle: _buttonText),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(textStyle: _buttonText),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(textStyle: WidgetStateProperty.all(_buttonText)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      );
}
