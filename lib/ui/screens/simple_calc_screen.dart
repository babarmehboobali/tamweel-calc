import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/engine/regulations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/number_parser.dart';
import '../../services/ads/ad_service.dart';
import '../../state/calculator_state.dart';
import '../widgets/number_field.dart';
import '../widgets/motion.dart';

class CalcField {
  final String key, en, ar;
  final double def, min, max;
  final bool isInt;
  const CalcField(this.key, this.en, this.ar, this.def, {this.min = 0, this.max = 0, this.isInt = false});
  bool get hasSlider => max > min;
}

class CalcOut {
  final String label;
  final String value;
  final bool highlight;
  const CalcOut(this.label, this.value, {this.highlight = false});
}

typedef CalcFn = List<CalcOut> Function(Map<String, double> v, int choice, CalcCtx c);

class CalcCtx {
  final bool ar;
  final String cur;
  const CalcCtx(this.ar, this.cur);
  String t(String en, String arText) => ar ? arText : en;
  String m(double v) => Formatters.currency(v, cur, isArabic: ar);
  String n(num v, [int d = 0]) => Formatters.number(v, decimals: d, isArabic: ar);
  String pct(double v) => Formatters.percent(v, isArabic: ar);
}

/// Lean, live-updating calculator screen with optional sliders and a 2-way choice.
class SimpleCalcScreen extends StatefulWidget {
  final String titleEn, titleAr;
  final List<CalcField> fields;
  final List<(String, String)> choices; // (en, ar)
  final CalcFn compute;
  final String? noteEn, noteAr;
  const SimpleCalcScreen({super.key, required this.titleEn, required this.titleAr, required this.fields,
      required this.compute, this.choices = const [], this.noteEn, this.noteAr});

  @override
  State<SimpleCalcScreen> createState() => _SimpleCalcScreenState();
}

class _SimpleCalcScreenState extends State<SimpleCalcScreen> {
  late final Map<String, TextEditingController> _c = {
    for (final f in widget.fields) f.key: TextEditingController(text: _fmt(f, f.def)),
  };
  int _choice = 0;

  String _fmt(CalcField f, double v) => f.isInt || v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  double _val(CalcField f) => NumberParser.parse(_c[f.key]!.text) ?? 0;

  @override
  void initState() {
    super.initState();
    // Result screen: suppress interstitials while here and shortly after.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdService?>()?.markResultViewed();
    });
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final calc = context.watch<CalculatorState?>();
    final cur = calc == null ? 'SAR' : RegulationRules.forCountry(calc.inputs.country).currency;
    final cx = CalcCtx(ar, cur);
    final values = {for (final f in widget.fields) f.key: _val(f)};
    List<CalcOut> out;
    try {
      out = widget.compute(values, _choice, cx);
    } catch (_) {
      out = [];
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(ar ? widget.titleAr : widget.titleEn)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          if (widget.choices.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: SegmentedButton<int>(
                segments: [
                  for (var i = 0; i < widget.choices.length; i++)
                    ButtonSegment(value: i, label: Text(ar ? widget.choices[i].$2 : widget.choices[i].$1, overflow: TextOverflow.ellipsis)),
                ],
                selected: {_choice},
                onSelectionChanged: (s) { tapHaptic(); setState(() => _choice = s.first); },
              ),
            ),
          for (final f in widget.fields) ...[
            NumberField(controller: _c[f.key]!, label: ar ? f.ar : f.en, onChanged: (_) => setState(() {})),
            if (f.hasSlider)
              Slider(
                value: _val(f).clamp(f.min, f.max).toDouble(),
                min: f.min,
                max: f.max,
                divisions: f.isInt ? (f.max - f.min).round() : 100,
                label: _c[f.key]!.text,
                onChanged: (v) {
                  final nv = _fmt(f, f.isInt ? v.roundToDouble() : (v * 100).round() / 100);
                  if (nv != _c[f.key]!.text) tapHaptic();
                  setState(() => _c[f.key]!.text = nv);
                },
              ),
          ],
          const SizedBox(height: 8),
          _ResultsPanel(out: out, ar: ar),
          if (widget.noteEn != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8),
              child: Text(ar ? widget.noteAr! : widget.noteEn!, style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

/// Results with a highlighted gradient hero row and animated value changes.
class _ResultsPanel extends StatelessWidget {
  final List<CalcOut> out;
  final bool ar;
  const _ResultsPanel({required this.out, required this.ar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (out.isEmpty) {
      return EmptyState(icon: Icons.edit_note_rounded, title: ar ? 'أدخل قيمًا صحيحة' : 'Enter valid values');
    }
    final hero = out.where((o) => o.highlight).toList();
    final rest = out.where((o) => !o.highlight).toList();
    final d = motion(context, const Duration(milliseconds: 250));
    Widget swap(String v, TextStyle? st, {TextAlign align = TextAlign.end}) => AnimatedSwitcher(
          duration: d,
          transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: c)),
          child: Text(v, key: ValueKey(v), textAlign: align, style: st),
        );
    return Column(children: [
      if (hero.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
                colors: [Color(0xFF0F766E), Color(0xFF134E4A)]),
            boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final o in hero) ...[
              Text(o.label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: swap(o.value, const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), align: TextAlign.start),
              ),
              const SizedBox(height: 4),
            ],
          ]),
        ),
      if (rest.isNotEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(children: [
              for (final o in rest)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Text(o.label, style: theme.textTheme.bodyMedium)),
                    const SizedBox(width: 8),
                    Flexible(child: swap(o.value, theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                  ]),
                ),
            ]),
          ),
        ),
    ]);
  }
}
