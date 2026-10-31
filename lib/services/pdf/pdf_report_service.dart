import 'package:intl/date_symbol_data_local.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../core/engine/amortization.dart';
import '../../core/engine/comparison.dart';
import 'pdf_fonts.dart';
import 'dart:io';
import '../../data/broker_store.dart';
import '../review/rate_us_service.dart';

class PdfReportService {
  /// Broker mode: name, phone and gallery logo under the app header.
  static Future<pw.Widget Function(pw.Widget)> _brokerWrap() async {
    final b = await BrokerStore.load();
    if (!b.enabled || (b.name.isEmpty && b.phone.isEmpty && b.logoPath.isEmpty)) return (pw.Widget w) => w;
    Uint8List? logo;
    try {
      if (b.logoPath.isNotEmpty && File(b.logoPath).existsSync()) logo = await File(b.logoPath).readAsBytes();
    } catch (_) {}
    return (pw.Widget w) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          w,
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.teal200), borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Row(children: [
              if (logo != null) pw.Image(pw.MemoryImage(logo), width: 40, height: 40, fit: pw.BoxFit.contain),
              if (logo != null) pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (b.name.isNotEmpty) pw.Text(b.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                if (b.phone.isNotEmpty) pw.Text(b.phone, style: const pw.TextStyle(fontSize: 10), textDirection: pw.TextDirection.ltr),
              ])),
            ]),
          ),
          pw.SizedBox(height: 6),
        ]);
  }

  static Future<void> generateEligibilityReport({
    required String title,
    required Map<String, String> inputs,
    required Map<String, String> results,
    required List<AmortizationRow> schedule,
    required bool isArabic,
    required String currency,
    void Function(Uint8List bytes)? onBytes,
  }) async {
    await initializeDateFormatting(isArabic ? 'ar' : 'en');
    final theme = await PdfFonts.load();
    final logoBytes = (await rootBundle.load('assets/branding/logo.png')).buffer.asUint8List();
    final doc = pw.Document(theme: theme);
    final broker = await _brokerWrap();
    final dir = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final date = DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(DateTime.now());
    final numFmt = NumberFormat('#,##0.00', isArabic ? 'ar' : 'en');

    doc.addPage(pw.MultiPage(
      textDirection: dir,
      header: (c) => broker(pw.Row(children: [
        pw.Image(pw.MemoryImage(logoBytes), width: 36, height: 36),
        pw.SizedBox(width: 8),
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Spacer(),
        pw.Text(date, style: const pw.TextStyle(fontSize: 10)),
      ])),
      footer: (c) => pw.Column(children: [
        pw.Divider(),
        pw.Text(
          isArabic
              ? 'تقدير فقط. ليست موافقة بنكية. تحقق من البنك قبل التقدم. صفحة ${c.pageNumber}/${c.pagesCount}'
              : 'Estimate only. Not a bank approval. Verify with your bank. Page ${c.pageNumber}/${c.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ]),
      build: (c) => [
        pw.Text(isArabic ? 'المدخلات' : 'Inputs', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...inputs.entries.map((e) => pw.Text('${e.key}: ${e.value}')),
        pw.SizedBox(height: 16),
        pw.Text(isArabic ? 'النتائج' : 'Results', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ...results.entries.map((e) => pw.Text('${e.key}: ${e.value}')),
        if (schedule.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          pw.Text(isArabic ? 'جدول السداد ($currency)' : 'Amortization Schedule ($currency)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
            cellAlignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            headers: isArabic
                ? ['الشهر', 'الرصيد', 'القسط', 'الأصل', 'الربح', 'الإغلاق']
                : ['Month', 'Opening', 'Installment', 'Principal', 'Profit', 'Closing'],
            data: schedule.map((r) => [
                  r.month.toString(),
                  numFmt.format(r.opening),
                  numFmt.format(r.installment),
                  numFmt.format(r.principal),
                  numFmt.format(r.profit),
                  numFmt.format(r.closing),
                ]).toList(),
          ),
        ],
      ],
    ));
    final bytes = await doc.save();
    onBytes?.call(bytes);
    await Printing.sharePdf(bytes: bytes, filename: 'Tamweel_Eligibility.pdf');
    await RateUsService.onPdfExported();
  }

  static Future<void> generateComparisonReport({
    required List<ComparisonResult> results,
    required bool isArabic,
    void Function(Uint8List bytes)? onBytes,
  }) async {
    await initializeDateFormatting(isArabic ? 'ar' : 'en');
    final theme = await PdfFonts.load();
    final logoBytes = (await rootBundle.load('assets/branding/logo.png')).buffer.asUint8List();
    final doc = pw.Document(theme: theme);
    final broker = await _brokerWrap();
    final dir = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final numFmt = NumberFormat('#,##0.00', isArabic ? 'ar' : 'en');

    doc.addPage(pw.MultiPage(
      textDirection: dir,
      header: (c) => broker(pw.Row(children: [
        pw.Image(pw.MemoryImage(logoBytes), width: 36, height: 36),
        pw.SizedBox(width: 8),
        pw.Text(isArabic ? 'مقارنة العروض' : 'Loan Comparison', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ])),
      footer: (c) => pw.Text(
        isArabic ? 'تقدير فقط. صفحة ${c.pageNumber}/${c.pagesCount}' : 'Estimate only. Page ${c.pageNumber}/${c.pagesCount}',
        style: const pw.TextStyle(fontSize: 8),
      ),
      build: (c) => [
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
          headers: isArabic
              ? ['العرض', 'القسط', 'التكلفة', 'الربح والرسوم', 'المعدل الفعلي']
              : ['Offer', 'EMI', 'Total cost', 'Profit+fees', 'APR'],
          data: results.map((r) => [
                r.offer.name + (r.isCheapest ? (isArabic ? ' (الأفضل)' : ' (best)') : ''),
                numFmt.format(r.emi),
                numFmt.format(r.totalCost),
                numFmt.format(r.totalProfitFees),
                '${r.effectiveApr.toStringAsFixed(2)}%',
              ]).toList(),
        ),
      ],
    ));
    final bytes = await doc.save();
    onBytes?.call(bytes);
    await Printing.sharePdf(bytes: bytes, filename: 'Tamweel_Comparison.pdf');
    await RateUsService.onPdfExported();
  }
}
