import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/engine/amortization.dart';
import '../../core/engine/extra_calculators.dart';

class CsvExport {
  /// RFC-4180 CSV with UTF-8 BOM so Excel opens Arabic headers correctly.
  static String scheduleCsv(List<AmortizationRow> rows, {DateTime? start, bool isArabic = false}) {
    final h = isArabic
        ? ['الشهر', 'التاريخ', 'القسط', 'أصل المبلغ', 'الربح', 'الرصيد']
        : ['Month', 'Date', 'Instalment', 'Principal', 'Profit', 'Balance'];
    String d(DateTime x) => '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
    final b = StringBuffer('\uFEFF${h.join(',')}\r\n');
    for (final r in rows) {
      b.write([
        r.month,
        start == null ? '' : d(dueDate(start, r.month - 1)),
        r.installment.toStringAsFixed(2),
        r.principal.toStringAsFixed(2),
        r.profit.toStringAsFixed(2),
        r.closing.toStringAsFixed(2),
      ].join(','));
      b.write('\r\n');
    }
    return b.toString();
  }

  static Future<void> share(List<AmortizationRow> rows, {DateTime? start, bool isArabic = false}) async {
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/tamweel_schedule.csv');
    await f.writeAsString(scheduleCsv(rows, start: start, isArabic: isArabic));
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'text/csv')], subject: 'Tamweel schedule'));
  }
}
