import 'package:intl/intl.dart';

class Formatters {
  /// User setting: show Arabic-Indic digits (٠١٢…) in Arabic UI. Western digits by default.
  static bool arabicDigits = false;

  static const _arab = '٠١٢٣٤٥٦٧٨٩';

  static String digits(String s, {bool isArabic = false}) {
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final w = '0123456789'.indexOf(ch);
      final a = _arab.indexOf(ch);
      if (isArabic && arabicDigits && w >= 0) {
        b.write(_arab[w]);
      } else if (!(isArabic && arabicDigits) && a >= 0) {
        b.write(a);
      } else if (!(isArabic && arabicDigits) && (ch == '٬')) {
        b.write(',');
      } else if (!(isArabic && arabicDigits) && (ch == '٫')) {
        b.write('.');
      } else {
        b.write(ch);
      }
    }
    return b.toString();
  }

  /// Arabic currency symbols, written after the number in Arabic UI.
  static const Map<String, String> arSymbols = {
    'SAR': 'ر.س', 'AED': 'د.إ', 'KWD': 'د.ك', 'QAR': 'ر.ق', 'BHD': 'د.ب', 'OMR': 'ر.ع',
  };

  static String currency(double value, String code, {bool isArabic = false}) {
    final decimals = (code == 'KWD' || code == 'BHD' || code == 'OMR') ? 3 : 2;
    final fmt = NumberFormat.currency(locale: 'en', symbol: '', decimalDigits: decimals);
    final neg = value < 0;
    var num = fmt.format(value.abs()).trim();
    if (neg) num = '-$num';
    if (!isArabic) return digits('$num $code', isArabic: false);
    // Arabic: isolate the number LTR so the minus sign stays attached on the left,
    // then the localized symbol after the number (to its left in RTL).
    final sym = arSymbols[code] ?? code;
    return '\u2066${digits(num, isArabic: true)}\u2069 $sym';
  }

  /// Remove bidi isolate marks (for plain-text exports such as PDF).
  static String plain(String s) => s.replaceAll(RegExp('[\u2066-\u2069\u200e\u200f]'), '');

  static String number(num value, {int decimals = 0, bool isArabic = false}) {
    final fmt = NumberFormat.decimalPatternDigits(locale: 'en', decimalDigits: decimals);
    return digits(fmt.format(value), isArabic: isArabic);
  }

  static String percent(double value, {bool isArabic = false}) => digits('${value.toStringAsFixed(2)}%', isArabic: isArabic);
}
