import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFonts {
  static Future<pw.ThemeData> load() async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    return pw.ThemeData.withFont(base: regular, bold: bold);
  }
}
