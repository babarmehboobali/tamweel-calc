import 'package:flutter/material.dart';
import '../../services/share/share_service.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../state/calculator_state.dart';
import '../../state/app_state.dart';
import '../../core/engine/amortization.dart';
import '../../core/engine/eligibility.dart';
import '../../core/engine/regulations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/number_parser.dart';
import '../../l10n/app_localizations.dart';
import '../../services/pdf/pdf_report_service.dart';
import '../widgets/number_field.dart';
import '../../core/engine/extra_calculators.dart';
import '../../services/export/csv_export.dart';
import '../../services/ads/ad_service.dart';
import 'package:intl/intl.dart';
import '../widgets/motion.dart';

class EmiScheduleScreen extends StatefulWidget {
  const EmiScheduleScreen({super.key});

  @override
  State<EmiScheduleScreen> createState() => _EmiScheduleScreenState();
}

class _EmiScheduleScreenState extends State<EmiScheduleScreen> {
  final _principalCtrl = TextEditingController();
  double _principal = 100000;
  bool _exporting = false;
  int _touched = -1;
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPrincipal();
      context.read<AdService?>()?.markResultViewed();
    });
  }

  void _initPrincipal() {
    final calc = context.read<CalculatorState>();
    final app = context.read<AppState>();
    final rules = RegulationRules.forCountry(calc.inputs.country);
    final result = EligibilityEngine.calculate(
      rules: rules,
      loanType: calc.inputs.loanType,
      status: calc.inputs.employmentStatus,
      basic: calc.inputs.basicSalary,
      housing: calc.inputs.housingAllowance,
      other: calc.inputs.otherAllowances,
      existingEmis: calc.inputs.existingEmis,
      cardLimits: calc.inputs.cardLimits,
      annualRate: calc.inputs.annualRate,
      tenorMonths: calc.inputs.tenorMonths,
      customDbrCap: app.customDbrCap,
    );
    setState(() {
      _principal = result.maxFinancing > 0 ? result.maxFinancing : 100000;
      _principalCtrl.text = _principal.toStringAsFixed(0);
    });
  }

  void _useMax() => _initPrincipal();

  Future<void> _export(List<AmortizationRow> schedule, String currency, bool isAr) async {
    setState(() => _exporting = true);
    final l10n = AppLocalizations.of(context);
    await PdfReportService.generateEligibilityReport(
      title: l10n.emiSchedule,
      inputs: {l10n.principal: Formatters.currency(_principal, currency, isArabic: isAr)},
      results: {l10n.monthlyEmi: Formatters.currency(schedule.isNotEmpty ? schedule.first.installment : 0, currency, isArabic: isAr)},
      schedule: schedule,
      isArabic: isAr,
      currency: currency,
    );
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inputs = context.watch<CalculatorState>().inputs;
    final rules = RegulationRules.forCountry(inputs.country);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final emi = AmortizationEngine.emi(_principal, inputs.annualRate, inputs.tenorMonths);
    final schedule = AmortizationEngine.schedule(_principal, inputs.annualRate, inputs.tenorMonths);
    final totalProfit = schedule.fold(0.0, (s, r) => s + r.profit);
    String fd(DateTime d) => Formatters.digits(DateFormat('MMM yyyy', isAr ? 'ar' : 'en').format(d), isArabic: isAr);
    final payoff = dueDate(_start, inputs.tenorMonths - 1);
    final sliderMax = _principal > 2000000 ? _principal : 2000000.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emiSchedule), actions: [
        IconButton(
          icon: const Icon(Icons.ios_share),
          tooltip: isAr ? 'إرسال / مشاركة' : 'Email / Share',
          onPressed: () => ShareService.showSheet(context,
              subject: l10n.emiSchedule,
              body: [
                l10n.emiSchedule,
                '${l10n.principal}: ${Formatters.currency(_principal, rules.currency, isArabic: isAr)}',
                '${l10n.annualRate}: ${inputs.annualRate.toStringAsFixed(2)}%  •  ${inputs.tenorMonths}m',
                '${l10n.monthlyEmi}: ${Formatters.currency(emi, rules.currency, isArabic: isAr)}',
                '${l10n.totalProfit}: ${Formatters.currency(totalProfit, rules.currency, isArabic: isAr)}',
              ].join('\n'),
              onPdf: () => _export(schedule, rules.currency, isAr)),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          NumberField(
            controller: _principalCtrl,
            label: l10n.principal,
            onChanged: (v) => setState(() => _principal = NumberParser.parse(v) ?? _principal),
          ),
          Slider(
            value: _principal.clamp(10000, sliderMax).toDouble(),
            min: 10000,
            max: sliderMax,
            divisions: 199,
            onChanged: (v) => setState(() {
              _principal = (v / 1000).round() * 1000.0;
              _principalCtrl.text = _principal.toStringAsFixed(0);
            }),
          ),
          Wrap(spacing: 8, runSpacing: 4, children: [
            ActionChip(label: Text(l10n.useMaxEligible), onPressed: _useMax),
            ActionChip(
              avatar: const Icon(Icons.event, size: 18),
              label: Text('${isAr ? 'أول قسط' : 'First due'}: ${fd(_start)}'),
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null) setState(() => _start = d);
              },
            ),
          ]),
          const SizedBox(height: 8),
          _HeroCard(
            title: l10n.monthlyEmi,
            value: emi,
            fmt: (v) => Formatters.currency(v, rules.currency, isArabic: isAr),
            lines: [
              '${l10n.totalProfit}: ${Formatters.currency(totalProfit, rules.currency, isArabic: isAr)}',
              '${isAr ? 'تاريخ السداد النهائي' : 'Payoff date'}: ${fd(payoff)}',
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(touchCallback: (e, r) {
                      final i = (!e.isInterestedForInteractions || r?.touchedSection == null) ? -1 : r!.touchedSection!.touchedSectionIndex;
                      if (i != _touched) { if (i >= 0) tapHaptic(); setState(() => _touched = i); }
                    }),
                    sectionsSpace: 3,
                    sections: [
                      for (final (i, v, c) in [(0, _principal, const Color(0xFF0F766E)), (1, totalProfit, const Color(0xFFF59E0B))])
                        PieChartSectionData(
                          value: v <= 0 ? 0.0001 : v,
                          title: '${(v / ((_principal + totalProfit) == 0 ? 1 : (_principal + totalProfit)) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          color: c,
                          radius: _touched == i ? 62 : 50,
                        ),
                    ],
                    centerSpaceRadius: 36,
                  ),
                  duration: motion(context, const Duration(milliseconds: 400)),
                  curve: Curves.easeOutCubic,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _legend(const Color(0xFF0F766E), l10n.principal, Formatters.currency(_principal, rules.currency, isArabic: isAr), _touched == 0),
                  const SizedBox(height: 12),
                  _legend(const Color(0xFFF59E0B), l10n.profit, Formatters.currency(totalProfit, rules.currency, isArabic: isAr), _touched == 1),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text(isAr ? 'الرصيد المتبقي' : 'Remaining balance', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((sp) => LineTooltipItem('${Formatters.digits(sp.x.toInt().toString(), isArabic: isAr)}\n${Formatters.currency(sp.y, rules.currency, isArabic: isAr)}', const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [FlSpot(0, _principal), ...schedule.map((r) => FlSpot(r.month.toDouble(), r.closing))],
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.teal.withValues(alpha: 0.15)),
                  ),
                ],
              ),
              duration: motion(context, const Duration(milliseconds: 400)),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(Colors.teal.withOpacity(0.1)),
              columns: [
                DataColumn(label: Text(l10n.month)),
                DataColumn(label: Text('${l10n.installment}\n(${rules.currency})')),
                DataColumn(label: Text(l10n.principal)),
                DataColumn(label: Text(l10n.profit)),
                DataColumn(label: Text(l10n.balance)),
              ],
              rows: schedule.take(24).map((r) => DataRow(cells: [
                    DataCell(Text(Formatters.digits('${r.month} · ${fd(dueDate(_start, r.month - 1))}', isArabic: isAr))),
                    DataCell(Text(Formatters.currency(r.installment, '', isArabic: isAr).trim())),
                    DataCell(Text(Formatters.currency(r.principal, '', isArabic: isAr).trim())),
                    DataCell(Text(Formatters.currency(r.profit, '', isArabic: isAr).trim())),
                    DataCell(Text(Formatters.currency(r.closing, '', isArabic: isAr).trim())),
                  ])).toList(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _exporting ? null : () => _export(schedule, rules.currency, isAr),
            child: _exporting ? const CircularProgressIndicator() : Text(l10n.exportPdf),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.grid_on),
            label: Text(isAr ? 'تصدير CSV (إكسل)' : 'Export CSV (Excel)'),
            onPressed: () => CsvExport.share(schedule, start: _start, isArabic: isAr),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label, String value, bool active) => AnimatedContainer(
        duration: motion(context, const Duration(milliseconds: 200)),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? c.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart,
                  child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
        ]),
      );
}

/// Gradient header card with an animated count-up value.
class _HeroCard extends StatelessWidget {
  final String title;
  final double value;
  final String Function(double) fmt;
  final List<String> lines;
  const _HeroCard({required this.title, required this.value, required this.fmt, required this.lines});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
            colors: [Color(0xFF0F766E), Color(0xFF134E4A)]),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: CountUpText(value: value, format: fmt,
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
        ),
        const SizedBox(height: 6),
        for (final l in lines) Text(l, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
      ]),
    );
  }
}
