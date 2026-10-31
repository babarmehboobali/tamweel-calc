import '../../core/models/country.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/engine/regulations.dart';
import '../../data/rates_models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/rates_state.dart';
import 'compare_loans_screen.dart';
import '../widgets/motion.dart';

class BanksScreen extends StatefulWidget {
  final Country? initialCountry;
  final LoanType? loanType;
  const BanksScreen({super.key, this.initialCountry, this.loanType});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  String? _filterIslamic;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<RatesState>().load().timeout(const Duration(seconds: 15));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final rates = context.watch<RatesState>();
    final countryKey = (widget.initialCountry ?? Country.ksa).jsonKey;
    final banks = rates.data?.countries[countryKey]?.banks ?? [];
    final cs = Theme.of(context).colorScheme;

    List<Bank> filtered = banks;
    if (_filterIslamic == 'islamic') filtered = filtered.where((b) => b.sharia).toList();
    if (_filterIslamic == 'conventional') filtered = filtered.where((b) => !b.sharia).toList();

    // Show cached/bundled data straight away; only show skeletons when there is nothing yet.
    final showSkeleton = _loading && banks.isEmpty;

    Widget body;
    if (showSkeleton) {
      body = ListView(
        key: const ValueKey('skeleton'),
        padding: const EdgeInsetsDirectional.all(16),
        children: List.generate(6, (_) => const _BankSkeleton()),
      );
    } else if (_error != null && banks.isEmpty) {
      body = ListView(key: const ValueKey('error'), children: [
        const SizedBox(height: 60),
        EmptyState(
          icon: Icons.cloud_off_rounded,
          title: isAr ? 'تعذر تحميل البنوك' : 'Could not load banks',
          subtitle: isAr ? 'تحقق من الاتصال ثم حاول مجددًا' : 'Check your connection and try again',
          action: FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
        ),
      ]);
    } else {
      body = ListView(
        key: const ValueKey('list'),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
        children: [
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final f in [(null, isAr ? 'الكل' : 'All'), ('islamic', isAr ? 'إسلامي' : 'Islamic'), ('conventional', isAr ? 'تقليدي' : 'Conventional')])
              ChoiceChip(
                label: Text(f.$2),
                selected: _filterIslamic == f.$1,
                onSelected: (_) { tapHaptic(); setState(() => _filterIslamic = f.$1); },
              ),
          ]),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            EmptyState(icon: Icons.account_balance_outlined, title: l10n.noBanks)
          else
            for (var i = 0; i < filtered.length; i++)
              StaggerIn(key: ValueKey('${_filterIslamic}_${filtered[i].id}'), index: i, child: _BankCard(bank: filtered[i], isAr: isAr, cs: cs)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.banks),
        bottom: _loading && !showSkeleton ? const PreferredSize(preferredSize: Size.fromHeight(2), child: LinearProgressIndicator(minHeight: 2)) : null,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: AnimatedSwitcher(duration: motion(context, const Duration(milliseconds: 300)), child: body),
      ),
    );
  }
}

class _BankSkeleton extends StatelessWidget {
  const _BankSkeleton();
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Shimmer(height: 44, width: 44, radius: 22),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Shimmer(height: 14, width: 160),
              SizedBox(height: 8),
              Shimmer(height: 12, width: 100),
            ])),
          ]),
        ),
      );
}

class _BankCard extends StatefulWidget {
  final Bank bank;
  final bool isAr;
  final ColorScheme cs;
  const _BankCard({required this.bank, required this.isAr, required this.cs});
  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard> {
  bool _open = false;

  static const _palette = [Color(0xFF0F766E), Color(0xFF1D4ED8), Color(0xFF7C3AED), Color(0xFFB45309), Color(0xFFBE123C), Color(0xFF047857)];

  @override
  Widget build(BuildContext context) {
    final b = widget.bank;
    final isAr = widget.isAr;
    final cs = widget.cs;
    final name = isAr ? (b.name['ar'] ?? b.name['en']!) : (b.name['en'] ?? '');
    final apr = b.personalAprMin;
    final initial = (b.name['en'] ?? b.id).trim().isEmpty ? '?' : (b.name['en'] ?? b.id).trim()[0].toUpperCase();
    final color = _palette[b.id.hashCode.abs() % _palette.length];
    final t = Theme.of(context).textTheme;
    String row(String en, String ar) => isAr ? ar : en;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Pressable(
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Wrap(spacing: 6, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text(apr != null ? row('APR from ${apr.toStringAsFixed(2)}%', 'معدل سنوي من ${apr.toStringAsFixed(2)}%') : row('Rate not published', 'المعدل غير منشور'),
                        style: t.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                    if (b.sharia) _tag(row('Islamic', 'إسلامي'), const Color(0xFF047857)),
                    if (b.verified) _tag(row('Verified', 'موثّق'), const Color(0xFF1D4ED8)),
                  ]),
                ]),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: motion(context, const Duration(milliseconds: 200)),
                child: const Icon(Icons.expand_more),
              ),
            ]),
            AnimatedSize(
              duration: motion(context, const Duration(milliseconds: 250)),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional.topStart,
              child: !_open
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(top: 10, end: 6),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _kv(row('Admin fee', 'الرسوم الإدارية'), '${b.adminFeePct.toStringAsFixed(2)}%${b.adminFeeCap != null ? row(' (cap ${b.adminFeeCap!.toStringAsFixed(0)})', ' (بحد ${b.adminFeeCap!.toStringAsFixed(0)})') : ''}'),
                        if (b.personalAprMax != null) _kv(row('APR range', 'نطاق المعدل'), '${(apr ?? 0).toStringAsFixed(2)}% – ${b.personalAprMax!.toStringAsFixed(2)}%'),
                        if (b.maxTenorMonths != null) _kv(row('Max tenor', 'أقصى مدة'), row('${b.maxTenorMonths} months', '${b.maxTenorMonths} شهرًا')),
                        if (b.minSalary != null) _kv(row('Min salary', 'الحد الأدنى للراتب'), b.minSalary!.toStringAsFixed(0)),
                        _kv(row('DBR base', 'أساس الاستقطاع'), b.dbrBase == 'basic' ? row('Basic salary', 'الراتب الأساسي') : row('Total salary', 'إجمالي الراتب')),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 4, children: [
                          FilledButton.tonalIcon(
                            icon: const Icon(Icons.compare_arrows, size: 18),
                            label: Text(row('Compare', 'قارن')),
                            onPressed: () {
                              tapHaptic();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => CompareLoansScreen(prefillName: name, prefillRate: apr)));
                            },
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: Text(row('Bank website', 'موقع البنك')),
                            onPressed: () async {
                              final url = b.calculatorUrl ?? b.website;
                              if (url.isNotEmpty) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            },
                          ),
                        ]),
                      ]),
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tag(String s, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(s, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(k, style: Theme.of(context).textTheme.bodySmall)),
          Flexible(child: Text(v, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ]),
      );
}
