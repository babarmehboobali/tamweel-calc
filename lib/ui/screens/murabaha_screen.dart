import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/engine/murabaha.dart';
import '../../core/engine/flat_rate.dart';
import '../../l10n/app_localizations.dart';
import '../../services/pdf/pdf_report_service.dart';
import '../widgets/number_field.dart';
import '../theme.dart';

class MurabahaScreen extends StatefulWidget {
  const MurabahaScreen({super.key});

  @override
  State<MurabahaScreen> createState() => _MurabahaScreenState();
}

class _MurabahaScreenState extends State<MurabahaScreen> {
  final _amount = TextEditingController(text: '100000');
  final _rate = TextEditingController(text: '6');
  final _months = TextEditingController(text: '60');
  bool _isFlat = true;
  MurabahaResult? result;
  double? apr;
  bool _exporting = false;

  void _calc() {
    HapticFeedback.lightImpact();
    final amount = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final rate = double.tryParse(_rate.text) ?? 0;
    final months = int.tryParse(_months.text) ?? 60;
    setState(() {
      result = MurabahaEngine.calculate(
        financedAmount: amount,
        annualProfitRate: rate,
        months: months,
        adminFeePct: 1,
        vatPct: 15,
      );
      apr = _isFlat ? FlatRateEngine.flatToApr(amount, rate, months ~/ 12) : rate;
    });
  }

  Future<void> _export() async {
    if (result == null) return;
    setState(() => _exporting = true);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    await PdfReportService.generateEligibilityReport(
      title: l10n.murabaha,
      inputs: {l10n.amount: _amount.text, l10n.profitRate: _rate.text},
      results: {
        l10n.salePrice: result!.salePrice.toStringAsFixed(2),
        l10n.netCash: result!.netCash.toStringAsFixed(2),
      },
      schedule: [],
      isArabic: isAr,
      currency: 'SAR',
    );
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.murabaha),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(l10n.murabaha),
                content: Text(l10n.murabahaTooltip),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                children: [
                  NumberField(controller: _amount, label: l10n.amount),
                  NumberField(controller: _rate, label: l10n.profitRate),
                  NumberField(controller: _months, label: l10n.tenorMonths),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: true, label: Text(l10n.flatRate)),
                      ButtonSegment(value: false, label: Text(l10n.reducing)),
                    ],
                    selected: {_isFlat},
                    onSelectionChanged: (s) => setState(() => _isFlat = s.first),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _calc, child: Text(l10n.calculate)),
                ],
              ),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.salePrice, style: Theme.of(context).textTheme.titleMedium),
                    Text(result!.salePrice.toStringAsFixed(2), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontFeatures: const [FontFeature.tabularFigures()])),
                    const SizedBox(height: 8),
                    Text('${l10n.monthlyEmi}: ${result!.installment.toStringAsFixed(2)}'),
                    if (apr != null) Text('${l10n.effectiveApr}: ${apr!.toStringAsFixed(2)}%'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: Container(height: 12, color: colorScheme.primary)),
                        Expanded(flex: 1, child: Container(height: 12, color: colorScheme.secondary)),
                      ],
                    ),
                    Text('${l10n.principal} / ${l10n.profit}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _exporting ? null : _export,
                      child: _exporting ? const CircularProgressIndicator() : Text(l10n.exportPdf),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
