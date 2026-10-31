import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/share/share_service.dart';
import '../../data/history_store.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/engine/eligibility.dart';
import '../../core/engine/regulations.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/country.dart';
import '../../core/engine/amortization.dart';
import '../../core/engine/general_mode.dart';
import '../../core/utils/number_parser.dart';
import '../../data/rates_models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ads/ad_service.dart';
import '../../services/pdf/pdf_report_service.dart';
import '../../state/calculator_state.dart';
import '../../state/rates_state.dart';
import '../widgets/number_field.dart';
import '../widgets/motion.dart';
import 'banks_screen.dart';
import 'emi_schedule_screen.dart';

enum Nationality { citizen, expat }
enum EmployerType { government, military, semiGovernment, privateApproved, privateOther, selfEmployed, retired }

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> with SingleTickerProviderStateMixin {
  final _basic = TextEditingController();
  final _housing = TextEditingController();
  final _other = TextEditingController();
  final _emis = TextEditingController();
  final _cards = TextEditingController();
  final _rate = TextEditingController(text: '6');
  final _tenor = TextEditingController(text: '60');
  final _customDbr = TextEditingController();
  final _genDbr = TextEditingController(text: (GeneralSettings.dbrCap * 100).toStringAsFixed(0));
  final _genFeePct = TextEditingController(text: GeneralSettings.adminFeePct == 0 ? '' : GeneralSettings.adminFeePct.toString());
  final _genFeeFixed = TextEditingController(text: GeneralSettings.adminFeeFixed == 0 ? '' : GeneralSettings.adminFeeFixed.toString());
  final _genMultiple = TextEditingController(text: GeneralSettings.salaryMultiple?.toString() ?? '');
  final _genSymbol = TextEditingController();

  Nationality _nationality = Nationality.citizen;
  EmployerType _employer = EmployerType.government;
  String? _selectedBankId;
  Bank? _selectedBank;
  bool _exporting = false;
  late AnimationController _gaugeCtrl;

  int _seenRevision = 0;
  static String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  void _fill() {
    final calc = context.read<CalculatorState>();
    _basic.text = _n(calc.inputs.basicSalary);
    _housing.text = _n(calc.inputs.housingAllowance);
    _other.text = _n(calc.inputs.otherAllowances);
    _emis.text = _n(calc.inputs.existingEmis);
    _cards.text = _n(calc.inputs.cardLimits);
    _rate.text = (calc.inputs.country == Country.general && GeneralSettings.enteredRate != null ? GeneralSettings.enteredRate! : calc.inputs.annualRate).toString();
    _tenor.text = calc.inputs.tenorMonths.toString();
    _seenRevision = calc.revision;
  }

  @override
  void initState() {
    super.initState();
    _gaugeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fill();
      _recalc();
      _gaugeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _gaugeCtrl.dispose();
    _scroll.dispose();
    _basic.dispose();
    _housing.dispose();
    _other.dispose();
    _emis.dispose();
    _cards.dispose();
    _rate.dispose();
    _tenor.dispose();
    _customDbr.dispose();
    super.dispose();
  }

  String _catKey() => '${_nationality.name}_${_employer.name}';

  void _applyBank(Bank? bank) {
    setState(() {
      _selectedBank = bank;
      _selectedBankId = bank?.id;
    });
    if (bank == null) {
      _recalc();
      return;
    }
    final cat = bank.categories?[_catKey()];
    if (cat?.apr != null) _rate.text = cat!.apr.toString();
    else if (bank.personalAprMin != null) _rate.text = bank.personalAprMin.toString();
    if (cat?.maxTenureMonths != null) _tenor.text = cat!.maxTenureMonths.toString();
    _recalc();
  }

  void _recalc() {
    final calc = context.read<CalculatorState>();
    final basic = NumberParser.parse(_basic.text);
    final housing = NumberParser.parse(_housing.text);
    final other = NumberParser.parse(_other.text);
    final emis = NumberParser.parse(_emis.text);
    final cards = NumberParser.parse(_cards.text);
    var rate = NumberParser.parse(_rate.text);
    final tenorParsed = int.tryParse(_tenor.text) ?? 60;
    if (calc.inputs.country == Country.general) {
      GeneralSettings.enteredRate = rate;
      GeneralSettings.dbrCap = ((NumberParser.parse(_genDbr.text) ?? 40) / 100).clamp(0.01, 1.0);
      GeneralSettings.adminFeePct = NumberParser.parse(_genFeePct.text) ?? 0;
      GeneralSettings.adminFeeFixed = NumberParser.parse(_genFeeFixed.text) ?? 0;
      final mult = NumberParser.parse(_genMultiple.text);
      GeneralSettings.salaryMultiple = (mult == null || mult <= 0) ? null : mult;
      if (GeneralSettings.flatRate) rate = GeneralSettings.flatToReducingApr(rate ?? 0, tenorParsed);
      calc.saveGeneral();
    }
    final tenor = int.tryParse(_tenor.text) ?? 60;
    final custom = _customDbr.text.isEmpty ? null : (NumberParser.parse(_customDbr.text) ?? 0) / 100;

    DbrBase? base;
    double? customCap = custom;
    if (_selectedBank != null && calc.inputs.country != Country.general) {
      final cat = _selectedBank!.categories?[_catKey()];
      base = (cat?.salaryBase ?? _selectedBank!.dbrBase) == 'basic' ? DbrBase.basicOnly : DbrBase.totalSalary;
      if (cat?.dbrCap != null) customCap = cat!.dbrCap;
    }

    calc.updateAndRecalc(
      basic: basic,
      housing: housing,
      other: other,
      existingEmis: emis,
      cardLimits: cards,
      annualRate: rate,
      tenorMonths: tenor,
      customDbr: customCap,
      bankDbrBase: base,
    );
  }

  Widget _slider(TextEditingController c, double min, double max, int div, {bool isInt = false}) {
    final v = (NumberParser.parse(c.text) ?? min).clamp(min, max).toDouble();
    return SizedBox(
      height: 32,
      child: Slider(
        value: v, min: min, max: max, divisions: div,
        label: isInt ? v.round().toString() : v.toStringAsFixed(2),
        onChanged: (n) {
          final nv = isInt ? n.round().toString() : ((n * 4).round() / 4).toString();
          if (nv != c.text) { HapticFeedback.selectionClick(); c.text = nv; _recalc(); setState(() {}); }
        },
      ),
    );
  }


  String _summary() {
    final calc = context.read<CalculatorState>();
    final r = calc.result;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final cur = RegulationRules.forCountry(calc.inputs.country).currency;
    String f(double v) => Formatters.currency(v, cur, isArabic: isAr);
    final i = calc.inputs;
    return [
      l10n.eligibilityTitle,
      '${l10n.basicSalary}: ${f(i.basicSalary)}',
      '${l10n.housingAllowance}: ${f(i.housingAllowance)}',
      '${l10n.existingEmis}: ${f(i.existingEmis)}',
      '${l10n.annualRate}: ${i.annualRate.toStringAsFixed(2)}%  •  ${l10n.tenorMonths}: ${i.tenorMonths}',
      if (_selectedBank != null) '${l10n.selectBank}: ${_selectedBank!.name[isAr ? 'ar' : 'en'] ?? _selectedBank!.id}',
      if (r != null) ...[
        '${isAr ? 'الحد الأقصى للقسط' : 'Max monthly installment'}: ${f(r.remainingEmi)}',
        '${l10n.maxFinancing}: ${f(r.maxFinancing)}',
      ],
    ].join('\n');
  }

  void _share() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    ShareService.showSheet(context, subject: isAr ? 'نتيجة أهلية التمويل' : 'Loan eligibility result', body: _summary(), onPdf: _exportPdf);
  }

  Future<void> _save() async {
    final calc = context.read<CalculatorState>();
    final r = calc.result;
    if (r == null) return;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final cur = RegulationRules.forCountry(calc.inputs.country).currency;
    final defName = '${calc.inputs.country.name.toUpperCase()} • ${_selectedBank?.name[isAr ? 'ar' : 'en'] ?? (isAr ? 'حساب' : 'Calculation')}';
    final ctrl = TextEditingController(text: defName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حفظ الحساب' : 'Save calculation'),
        content: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(labelText: isAr ? 'الاسم' : 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: Text(isAr ? 'حفظ' : 'Save')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    String f(double v) => Formatters.currency(v, cur, isArabic: isAr);
    await HistoryStore.save(SavedCalc(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      date: DateTime.now(),
      inputs: calc.inputs,
      results: {
        isAr ? 'القسط' : 'EMI': f(r.remainingEmi),
        isAr ? 'التمويل' : 'Max financing': f(r.maxFinancing),
      },
    ));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'تم الحفظ' : 'Saved')));
  }

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final calc = context.read<CalculatorState>();
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      final rules = RegulationRules.forCountry(calc.inputs.country);
      final result = calc.result!;
      final l10n = AppLocalizations.of(context);
      final schedule = AmortizationEngine.schedule(result.maxFinancing, calc.inputs.annualRate, calc.inputs.tenorMonths);
      await PdfReportService.generateEligibilityReport(
        title: l10n.eligibilityTitle,
        inputs: {
          l10n.basicSalary: Formatters.currency(calc.inputs.basicSalary, rules.currency, isArabic: isAr),
          l10n.housingAllowance: Formatters.currency(calc.inputs.housingAllowance, rules.currency, isArabic: isAr),
          l10n.existingEmis: Formatters.currency(calc.inputs.existingEmis, rules.currency, isArabic: isAr),
          l10n.annualRate: '${calc.inputs.annualRate}%',
          l10n.tenorMonths: calc.inputs.tenorMonths.toString(),
          if (_selectedBank != null) l10n.selectBank: _selectedBank!.name[isAr ? 'ar' : 'en'] ?? _selectedBank!.id,
        },
        results: {l10n.maxFinancing: Formatters.currency(result.maxFinancing, rules.currency, isArabic: isAr)},
        schedule: schedule,
        isArabic: isAr,
        currency: rules.currency,
      );
      if (mounted) {
        final ads = context.read<AdService>();
        ads.markSessionUsed();
        ads.markResultViewed(); // no interstitial after a result/PDF (R7)
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _compareBanks() {
    final calc = context.read<CalculatorState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BanksScreen(
          initialCountry: calc.inputs.country,
          loanType: calc.inputs.loanType,
        ),
      ),
    );
  }

  final ScrollController _scroll = ScrollController();
  bool _heroOut = false;

  static const _flags = {
    Country.general: '🌍', Country.ksa: '🇸🇦', Country.uae: '🇦🇪', Country.qatar: '🇶🇦',
    Country.kuwait: '🇰🇼', Country.bahrain: '🇧🇭', Country.oman: '🇴🇲',
  };
  static const _shortEn = {
    Country.general: 'Worldwide', Country.ksa: 'Saudi', Country.uae: 'UAE', Country.qatar: 'Qatar',
    Country.kuwait: 'Kuwait', Country.bahrain: 'Bahrain', Country.oman: 'Oman',
  };
  static const _shortAr = {
    Country.general: 'دولي', Country.ksa: 'السعودية', Country.uae: 'الإمارات', Country.qatar: 'قطر',
    Country.kuwait: 'الكويت', Country.bahrain: 'البحرين', Country.oman: 'عُمان',
  };

  void _onScroll() {
    final out = _scroll.hasClients && _scroll.offset > 260;
    if (out != _heroOut) setState(() => _heroOut = out);
  }

  void _setCountry(Country v) {
    tapHaptic();
    _selectedBank = null;
    _selectedBankId = null;
    context.read<CalculatorState>().setCountry(v);
    _recalc();
  }

  String _bankName(Bank b, bool isAr) => isAr ? (b.name['ar'] ?? b.name['en'] ?? b.id) : (b.name['en'] ?? b.id);
  String _initials(String n) {
    final parts = n.split(RegExp(r'\s+')).where((p) => p.isNotEmpty && RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(p[0])).toList();
    if (parts.isEmpty) return '•';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Future<void> _pickBank(List<Bank> banks, bool isAr, AppLocalizations l10n) async {
    tapHaptic();
    final cs = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (ctx, sc) => ListView(controller: sc, padding: const EdgeInsets.only(bottom: 24), children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: cs.secondaryContainer, child: Icon(Icons.rule, color: cs.onSecondaryContainer)),
            title: Text(l10n.genericRules),
            trailing: _selectedBankId == null ? Icon(Icons.check_circle, color: cs.primary) : null,
            onTap: () => Navigator.pop(ctx, '__none'),
          ),
          ...banks.map((b) => ListTile(
                leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: Text(_initials(b.name['en'] ?? b.id), style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 13))),
                title: Text(_bankName(b, isAr)),
                subtitle: Text([
                  if (b.personalAprMin != null) '${b.personalAprMin}%+',
                  b.sharia ? (isAr ? 'إسلامي' : 'Islamic') : (isAr ? 'تقليدي' : 'Conventional'),
                  if (!b.verified) (isAr ? 'استرشادي' : 'indicative'),
                ].join(' • ')),
                trailing: _selectedBankId == b.id ? Icon(Icons.check_circle, color: cs.primary) : null,
                onTap: () => Navigator.pop(ctx, b),
              )),
        ]),
      ),
    );
    if (picked == null) return;
    _applyBank(picked is Bank ? picked : null);
  }

  Widget _section(BuildContext context, {required IconData icon, required String title, required List<Widget> children, int index = 0}) {
    final cs = Theme.of(context).colorScheme;
    return StaggerIn(
      index: index,
      child: Container(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 14),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 14),
          ...children,
        ]),
      ),
    );
  }

  Widget _label(BuildContext context, String t) => Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 6, top: 2),
        child: Text(t, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );

  Widget _chips<T>(List<T> values, T selected, String Function(T) label, ValueChanged<T> onSel, {String Function(T)? leading}) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values
            .map((v) => ChoiceChip(
                  label: Text(leading == null ? label(v) : '${leading(v)}  ${label(v)}'),
                  selected: v == selected,
                  showCheckmark: false,
                  onSelected: (_) { tapHaptic(); onSel(v); },
                ))
            .toList(),
      );

  Widget _actionChip(IconData icon, String label, VoidCallback? onTap) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: Pressable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: onTap == null ? 0.08 : 0.16),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  Widget _hero(BuildContext context, EligibilityResult? result, RegulationRules rules, bool isAr, AppLocalizations l10n, RatesState rates) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    String f(double v) => Formatters.currency(v, rules.currency, isArabic: isAr);
    final used = result == null ? 0.0 : result.currentBurden / (result.dbrBaseIncome == 0 ? 1 : result.dbrBaseIncome);
    final cap = result?.capPct ?? 0.333;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20, top + 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: dark ? const [Color(0xFF0B3B37), Color(0xFF0F2A2E), Color(0xFF111827)] : const [Color(0xFF0F766E), Color(0xFF115E59), Color(0xFF0B4F4A)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [BoxShadow(color: const Color(0xFF0F766E).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/branding/icon.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Icon(Icons.calculate, color: Colors.white))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'حاسبة التمويل' : 'Tamweel Calc', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(rates.ratesUpdatedLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD4AF37).withValues(alpha: 0.22), borderRadius: BorderRadius.circular(20)),
            child: Text(isAr ? 'مجاني' : 'FREE', style: const TextStyle(color: Color(0xFFF5D77A), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
          ),
        ]),
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.maxFinancing, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: CountUpText(
                value: result?.maxFinancing ?? 0,
                format: f,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(height: 10),
            Text(isAr ? 'أقصى قسط شهري' : 'Max monthly EMI', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5)),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: CountUpText(
                value: result?.remainingEmi ?? 0,
                format: f,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFFF5D77A), fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          ])),
          const SizedBox(width: 12),
          SizedBox(
            width: 104,
            height: 104,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (used / (cap == 0 ? 1 : cap)).clamp(0.0, 1.0)),
              duration: motion(context, const Duration(milliseconds: 800)),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => CustomPaint(
                painter: _RingPainter(progress: 0, existing: v, color: _gaugeColor(used, cap)),
                child: Center(child: Padding(padding: const EdgeInsets.all(14), child: FittedBox(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  FittedBox(child: Text('${(used * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
                  FittedBox(child: Text(isAr ? 'من ${(cap * 100).toStringAsFixed(1)}% حد' : 'of ${(cap * 100).toStringAsFixed(1)}% cap', textScaler: TextScaler.noScaling, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10.5))),
                ])))),
              ),
            ),
          ),
        ]),
        if (result != null) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [
            _pill(Icons.speed, '${isAr ? 'الالتزامات الحالية' : 'Current DBR'} ${(used * 100).toStringAsFixed(1)}%'),
            _pill(result.limitingFactor == LimitingFactor.noCapacity ? Icons.warning_amber_rounded : Icons.info_outline, limitingFactorLabel(result.limitingFactor, isAr)),
            _pill(Icons.account_balance_wallet_outlined, result.dbrBaseUsed == DbrBase.basicOnly ? (isAr ? 'على الراتب الأساسي' : 'On basic salary') : (isAr ? 'على إجمالي الراتب' : 'On total salary')),
          ]),
        ],
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _actionChip(Icons.table_chart_outlined, isAr ? 'الجدول' : 'Schedule', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmiScheduleScreen()))),
            _actionChip(Icons.picture_as_pdf_outlined, 'PDF', _exporting || result == null ? null : _exportPdf),
            _actionChip(Icons.account_balance_outlined, isAr ? 'قارن البنوك' : 'Compare banks', _compareBanks),
            _actionChip(Icons.ios_share, isAr ? 'إرسال' : 'Share', _share),
            _actionChip(Icons.bookmark_add_outlined, isAr ? 'حفظ' : 'Save', result == null ? null : _save),
          ]),
        ),
      ]),
    );
  }

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 5),
          Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11.5))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final rev = context.select<CalculatorState, int>((c) => c.revision);
    if (rev != _seenRevision) {
      _seenRevision = rev;
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) { _fill(); _recalc(); } });
    }
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;
    final calc = context.watch<CalculatorState>();
    final rates = context.watch<RatesState>();
    final result = calc.result;
    final rules = RegulationRules.forCountry(calc.inputs.country);
    final isGeneral = calc.inputs.country == Country.general;
    final cur = rules.currency;
    final curSym = isAr ? (Formatters.arSymbols[cur] ?? cur) : cur;
    String f(double v) => Formatters.currency(v, cur, isArabic: isAr);
    final banks = rates.data?.countries[calc.inputs.country.jsonKey]?.banks ?? const <Bank>[];

    final costLines = result == null
        ? const <Widget>[]
        : (isGeneral ? _generalCost(result, rules, isAr, colorScheme) : (_selectedBank != null ? _bankCost(result, rules, isAr, l10n, colorScheme, rates) : const <Widget>[]));

    return Scaffold(
      body: Column(children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: rates.refresh,
            edgeOffset: MediaQuery.paddingOf(context).top,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _hero(context, result, rules, isAr, l10n, rates),
                const SizedBox(height: 18),
                _section(context, index: 0, icon: Icons.person_outline, title: isAr ? 'الملف الشخصي' : 'Profile', children: [
                  _label(context, l10n.country),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: Country.values.map((c) => Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: ChoiceChip(
                              label: Text('${_flags[c]}  ${(isAr ? _shortAr : _shortEn)[c]}'),
                              selected: calc.inputs.country == c,
                              showCheckmark: false,
                              onSelected: (_) { if (calc.inputs.country != c) _setCountry(c); },
                            ),
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isGeneral) ..._generalPanel(l10n, isAr) else ...[
                    _label(context, l10n.nationality),
                    SegmentedButton<Nationality>(
                      showSelectedIcon: false,
                      segments: Nationality.values.map((n) => ButtonSegment(value: n, label: Text(_natLabel(n, isAr)), icon: Icon(n == Nationality.citizen ? Icons.badge_outlined : Icons.public))).toList(),
                      selected: {_nationality},
                      onSelectionChanged: (v) { tapHaptic(); setState(() => _nationality = v.first); _applyBank(_selectedBank); },
                    ),
                    const SizedBox(height: 14),
                    _label(context, l10n.employerType),
                    _chips<EmployerType>(EmployerType.values, _employer, (e) => _empLabel(e, isAr), (v) { setState(() => _employer = v); _applyBank(_selectedBank); }),
                    const SizedBox(height: 12),
                  ],
                ]),
                _section(context, index: 1, icon: Icons.payments_outlined, title: isAr ? 'الدخل الشهري' : 'Monthly income', children: [
                  NumberField(controller: _basic, label: l10n.basicSalary, icon: Icons.account_balance_wallet_outlined, suffix: curSym, filled: true, onChanged: (_) => _recalc()),
                  NumberField(controller: _housing, label: l10n.housingAllowance, icon: Icons.home_outlined, suffix: curSym, filled: true, onChanged: (_) => _recalc()),
                  NumberField(controller: _other, label: l10n.otherAllowances, icon: Icons.add_card_outlined, suffix: curSym, filled: true, onChanged: (_) => _recalc()),
                  _totalRow(context, isAr ? 'إجمالي الراتب' : 'Total salary', f(calc.inputs.basicSalary + calc.inputs.housingAllowance + calc.inputs.otherAllowances)),
                ]),
                _section(context, index: 2, icon: Icons.receipt_long_outlined, title: isAr ? 'الالتزامات' : 'Obligations', children: [
                  NumberField(controller: _emis, label: l10n.existingEmis, icon: Icons.credit_score_outlined, suffix: curSym, filled: true, onChanged: (_) => _recalc()),
                  NumberField(controller: _cards, label: l10n.cardLimits, icon: Icons.credit_card, suffix: curSym, filled: true, onChanged: (_) => _recalc()),
                  if (!isGeneral) NumberField(controller: _customDbr, label: l10n.customDbrOptional, icon: Icons.percent, suffix: '%', filled: true, onChanged: (_) => _recalc()),
                ]),
                _section(context, index: 3, icon: Icons.tune, title: isAr ? 'تفاصيل التمويل' : 'Financing details', children: [
                  if (!isGeneral) ...[
                    _bankCard(context, banks, isAr, l10n),
                    const SizedBox(height: 14),
                  ],
                  NumberField(controller: _rate, label: isGeneral && GeneralSettings.flatRate ? (isAr ? 'نسبة ثابتة سنوية' : 'Flat rate per year') : l10n.annualRate, icon: Icons.trending_up, suffix: '%', filled: true, onChanged: (_) { _recalc(); setState(() {}); }),
                  _slider(_rate, 0, 25, 100),
                  const SizedBox(height: 10),
                  NumberField(controller: _tenor, label: l10n.tenorMonths, icon: Icons.calendar_month_outlined, suffix: isAr ? 'شهر' : 'mo', filled: true, onChanged: (_) { _recalc(); setState(() {}); }),
                  _slider(_tenor, 6, 360, 354, isInt: true),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: [12, 24, 36, 48, 60].map((m) => ChoiceChip(
                        label: Text(isAr ? '${m ~/ 12} سنة' : '${m ~/ 12} yr'),
                        selected: _tenor.text == '$m',
                        showCheckmark: false,
                        onSelected: (_) { tapHaptic(); _tenor.text = '$m'; _recalc(); setState(() {}); },
                      )).toList()),
                  const SizedBox(height: 12),
                ]),
                if (costLines.isNotEmpty)
                  _section(context, index: 4, icon: Icons.insights_outlined, title: isAr ? 'التكلفة المتوقعة' : 'Estimated cost', children: [...costLines, const SizedBox(height: 10)]),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: motion(context, const Duration(milliseconds: 220)),
          child: (_heroOut && result != null)
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF115E59)]),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, -2))],
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(l10n.maxFinancing, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart,
                          child: Text(f(result.maxFinancing), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
                    ])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                      Text(isAr ? 'أقصى قسط' : 'Max EMI', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerEnd,
                          child: Text(f(result.remainingEmi), style: const TextStyle(color: Color(0xFFF5D77A), fontSize: 15, fontWeight: FontWeight.w700))),
                    ])),
                    IconButton(
                      tooltip: isAr ? 'للأعلى' : 'Top',
                      icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                      onPressed: () => _scroll.animateTo(0, duration: motion(context, const Duration(milliseconds: 400)), curve: Curves.easeOutCubic),
                    ),
                  ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }

  Widget _totalRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(color: cs.onSurfaceVariant))),
        Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary)))),
      ]),
    );
  }

  Widget _bankCard(BuildContext context, List<Bank> banks, bool isAr, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final b = _selectedBank;
    return Pressable(
      onTap: () => _pickBank(banks, isAr, l10n),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: b == null ? cs.outlineVariant : cs.primary, width: b == null ? 1 : 1.5),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: b == null ? cs.secondaryContainer : cs.primary,
            child: b == null ? Icon(Icons.account_balance, color: cs.onSecondaryContainer) : Text(_initials(b.name['en'] ?? b.id), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.selectBank, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            Text(b == null ? l10n.genericRules : _bankName(b, isAr), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            if (b != null)
              Text([
                if (b.personalAprMin != null) '${isAr ? 'من' : 'from'} ${b.personalAprMin}%',
                '${isAr ? 'رسوم' : 'fee'} ${b.adminFeePct}%',
                if (!b.verified) (isAr ? 'استرشادي' : 'indicative'),
              ].join(' • '), style: Theme.of(context).textTheme.bodySmall),
          ])),
          Icon(Icons.unfold_more, color: cs.primary),
        ]),
      ),
    );
  }


  List<Widget> _generalPanel(AppLocalizations l10n, bool isAr) {
    final cur = GeneralSettings.currency;
    final isCommon = GeneralSettings.commonCurrencies.contains(cur);
    return [
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        isExpanded: true,
        value: isCommon ? cur : '__custom',
        decoration: InputDecoration(labelText: isAr ? 'العملة' : 'Currency'),
        items: [
          ...GeneralSettings.commonCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))),
          DropdownMenuItem(value: '__custom', child: Text(isAr ? 'رمز مخصص…' : 'Custom symbol…')),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() => GeneralSettings.currency = v == '__custom' ? (_genSymbol.text.trim().isEmpty ? '¤' : _genSymbol.text.trim()) : v);
          _recalc();
        },
      ),
      if (!isCommon)
        TextField(
          controller: _genSymbol..text = _genSymbol.text.isEmpty ? cur : _genSymbol.text,
          decoration: InputDecoration(labelText: isAr ? 'رمز العملة' : 'Currency symbol'),
          onChanged: (v) { GeneralSettings.currency = v.trim().isEmpty ? '¤' : v.trim(); _recalc(); },
        ),
      NumberField(controller: _genDbr, label: isAr ? 'حد نسبة الاستقطاع %' : 'DBR limit %', onChanged: (_) => _recalc()),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(isAr ? 'متناقص' : 'Reducing')),
            ButtonSegment(value: true, label: Text(isAr ? 'ثابت' : 'Flat')),
          ],
          selected: {GeneralSettings.flatRate},
          onSelectionChanged: (v) { setState(() => GeneralSettings.flatRate = v.first); _recalc(); },
        ),
      ),
      NumberField(controller: _genFeePct, label: isAr ? 'رسوم إدارية %' : 'Admin fee %', onChanged: (_) => _recalc()),
      NumberField(controller: _genFeeFixed, label: isAr ? 'رسوم إدارية ثابتة' : 'Admin fee (fixed amount)', onChanged: (_) => _recalc()),
      NumberField(controller: _genMultiple, label: isAr ? 'أقصى مضاعف للراتب (اختياري)' : 'Max salary multiple (optional)', onChanged: (_) => _recalc()),
    ];
  }

  List<Widget> _generalCost(EligibilityResult r, RegulationRules rules, bool isAr, ColorScheme cs) {
    final calc = context.read<CalculatorState>();
    final p = r.maxFinancing;
    final n = calc.inputs.tenorMonths;
    final emi = AmortizationEngine.emi(p, calc.inputs.annualRate, n);
    final fee = p > 0 ? GeneralSettings.adminFee(p) : 0.0;
    final apr = GeneralSettings.effectiveApr(p, emi, n, fee);
    final cur = rules.currency;
    final st = TextStyle(color: cs.onSurface, fontSize: 13.5, height: 1.5);
    return [
      const SizedBox(height: 6),
      if (GeneralSettings.flatRate) Text('${isAr ? 'المعدل المتناقص المكافئ' : 'Equivalent reducing rate'}: ${calc.inputs.annualRate.toStringAsFixed(2)}%', style: st),
      Text('${isAr ? 'القسط' : 'EMI'}: ${Formatters.currency(emi, cur, isArabic: isAr)} • ${isAr ? 'رسوم إدارية' : 'Admin fee'}: ${Formatters.currency(fee, cur, isArabic: isAr)}', style: st),
      Text('${isAr ? 'إجمالي التكلفة' : 'Total cost'}: ${Formatters.currency(emi * n + fee, cur, isArabic: isAr)} • APR ${apr.toStringAsFixed(2)}%', style: st),
    ];
  }

  String _natLabel(Nationality n, bool ar) => ar ? {Nationality.citizen: 'مواطن', Nationality.expat: 'مقيم'}[n]! : {Nationality.citizen: 'Citizen', Nationality.expat: 'Expat'}[n]!;
  String _empLabel(EmployerType e, bool ar) => (ar
      ? {EmployerType.government: 'حكومي', EmployerType.military: 'عسكري', EmployerType.semiGovernment: 'شبه حكومي', EmployerType.privateApproved: 'خاص (معتمد)', EmployerType.privateOther: 'خاص (آخر)', EmployerType.selfEmployed: 'أعمال حرة', EmployerType.retired: 'متقاعد'}
      : {EmployerType.government: 'Government', EmployerType.military: 'Military', EmployerType.semiGovernment: 'Semi-government', EmployerType.privateApproved: 'Private (approved)', EmployerType.privateOther: 'Private (other)', EmployerType.selfEmployed: 'Self-employed', EmployerType.retired: 'Retired'})[e]!;

  List<Widget> _bankCost(EligibilityResult r, RegulationRules rules, bool isAr, AppLocalizations l10n, ColorScheme cs, RatesState rates) {
    final b = _selectedBank!;
    final cat = b.categories?[_catKey()];
    final calc = context.read<CalculatorState>();
    var p = r.maxFinancing;
    if (cat?.maxAmount != null && p > cat!.maxAmount!) p = cat.maxAmount!;
    else if (b.maxAmount != null && p > b.maxAmount!) p = b.maxAmount!;
    final n = calc.inputs.tenorMonths;
    final emi = AmortizationEngine.emi(p, calc.inputs.annualRate, n);
    final vat = rates.data?.countries[calc.inputs.country.jsonKey]?.vatPct ?? 0;
    var fee = p * b.adminFeePct / 100;
    if (b.adminFeeCap != null && fee > b.adminFeeCap!) fee = b.adminFeeCap!;
    if (!b.adminFeeVatInclusive) fee *= 1 + vat / 100;
    final ins = p * b.insuranceTakafulPct / 100 * n / 12;
    final total = emi * n + fee + ins;
    // APR: monthly IRR on net proceeds (p - fee - ins)
    final net = p - fee - ins;
    double lo = 0, hi = 0.1;
    for (var i = 0; i < 80; i++) {
      final m = (lo + hi) / 2;
      final pv = m == 0 ? emi * n : emi * (1 - math.pow(1 + m, -n)) / m;
      if (pv > net) lo = m; else hi = m;
    }
    final apr = ((lo + hi) / 2) * 12 * 100;
    final cur = rules.currency;
    final st = TextStyle(color: cs.onSurface, fontSize: 13.5, height: 1.5);
    final minSal = cat?.minSalary ?? b.minSalary;
    return [
      const SizedBox(height: 6),
      Text('${b.name[isAr ? 'ar' : 'en'] ?? b.id}${b.verified ? '' : (isAr ? ' (استرشادي)' : ' (indicative)')}', style: st.copyWith(fontWeight: FontWeight.bold)),
      if (p < r.maxFinancing) Text('${isAr ? 'حد البنك' : 'Bank max'}: ${Formatters.currency(p, cur, isArabic: isAr)}', style: st),
      Text('${isAr ? 'القسط' : 'EMI'}: ${Formatters.currency(emi, cur, isArabic: isAr)} • ${isAr ? 'رسوم إدارية' : 'Admin fee'}: ${Formatters.currency(fee, cur, isArabic: isAr)}', style: st),
      Text('${isAr ? 'إجمالي التكلفة' : 'Total cost'}: ${Formatters.currency(total, cur, isArabic: isAr)} • APR ${apr.toStringAsFixed(2)}%', style: st),
      if (minSal != null && calc.inputs.basicSalary + calc.inputs.housingAllowance + calc.inputs.otherAllowances < minSal)
        Text('${isAr ? 'أقل من الحد الأدنى للراتب' : 'Below bank minimum salary'}: ${Formatters.currency(minSal, cur, isArabic: isAr)}', style: st.copyWith(color: cs.error)),
    ];
  }

  Color _gaugeColor(double used, double cap) {
    final ratio = used / cap;
    if (ratio < 0.7) return Colors.green;
    if (ratio < 0.9) return Colors.amber;
    return Colors.red;
  }
}

/// Readable, localized text for why financing is capped.
String limitingFactorLabel(LimitingFactor f, bool isAr) {
  switch (f) {
    case LimitingFactor.dbr:
      return isAr ? 'محدود بنسبة الاستقطاع' : 'Limited by DBR cap';
    case LimitingFactor.salaryMultiple:
      return isAr ? 'محدود بمضاعف الراتب' : 'Limited by salary multiple';
    case LimitingFactor.noCapacity:
      return isAr ? 'لا توجد قدرة سداد متبقية' : 'No repayment capacity left';
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double existing;
  final Color color;
  _RingPainter({required this.progress, required this.existing, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 6;
    final rect = Rect.fromCircle(center: c, radius: r);
    Paint p(Color col) => Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, p(Colors.white.withValues(alpha: 0.15)));
    const start = -math.pi / 2;
    if (progress > 0) canvas.drawArc(rect, start, 2 * math.pi * progress, false, p(const Color(0xFFF5D77A)));
    if (existing > 0) canvas.drawArc(rect, start, 2 * math.pi * existing.clamp(0, progress == 0 ? existing : progress), false, p(color));
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.progress != progress || o.existing != existing || o.color != color;
}

// ignore: unused_element
class _DbrGaugePainter extends CustomPainter {
  final double progress;
  final double cap;
  final Color color;
  final double animation;

  _DbrGaugePainter({required this.progress, required this.cap, required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height - 8;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14, 3.14, false, paint);
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 3.14, 3.14 * progress.clamp(0, 1) * animation, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
