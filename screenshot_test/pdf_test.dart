import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/amortization.dart';
import 'package:tamweel_calc/services/pdf/pdf_report_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final ar in [true, false]) {
    test('pdf ${ar ? 'ar' : 'en'}', () async {
      try { await PdfReportService.generateEligibilityReport(
        title: ar ? 'تقرير الأهلية للتمويل' : 'Financing Eligibility Report',
        inputs: ar
            ? {'الدولة': 'السعودية', 'الراتب الأساسي': '10,000', 'بدل السكن': '3,000', 'الأقساط الحالية': '1,000', 'المدة': '60 شهر'}
            : {'Country': 'KSA', 'Basic salary': '10,000', 'Housing': '3,000', 'Existing EMIs': '1,000', 'Tenor': '60 months'},
        results: ar ? {'أقصى تمويل': '206,876.38 ر.س', 'نسبة عبء الدين': '33.3%'} : {'Max financing': '206,876.38 SAR', 'DBR cap': '33.3%'},
        schedule: AmortizationEngine.schedule(206876.38, 6, 60),
        isArabic: ar,
        currency: 'SAR',
        onBytes: (b) => File('/workspace/tamweel/sample_report${ar ? '' : '_en'}.pdf').writeAsBytesSync(b),
      ); } on MissingPluginException catch (_) {}
    });
  }
}
