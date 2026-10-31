import 'package:flutter/material.dart';
import '../../services/share/share_service.dart';
import 'package:provider/provider.dart';
import '../../core/engine/comparison.dart';
import '../../state/calculator_state.dart';
import '../../l10n/app_localizations.dart';
import '../../services/pdf/pdf_report_service.dart';
import '../widgets/number_field.dart';

class CompareLoansScreen extends StatefulWidget {
  final String? prefillName;
  final double? prefillRate;
  const CompareLoansScreen({super.key, this.prefillName, this.prefillRate});

  @override
  State<CompareLoansScreen> createState() => _CompareLoansScreenState();
}

class _CompareLoansScreenState extends State<CompareLoansScreen> {
  final List<LoanOffer> offers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  void _prefill() {
    final inputs = context.read<CalculatorState>().inputs;
    final base = widget.prefillRate ?? inputs.annualRate;
    setState(() {
      offers.addAll([
        LoanOffer(
          name: widget.prefillName ?? 'Offer A',
          principal: 100000,
          rate: base,
          isFlat: false,
          months: inputs.tenorMonths,
          adminFeePct: 1.0,
          adminFeeCap: 2500,
          vatPct: 15,
          insurancePct: 0.4,
        ),
        LoanOffer(
          name: 'Offer B',
          principal: 100000,
          rate: base + 0.5,
          isFlat: false,
          months: inputs.tenorMonths,
          adminFeePct: 1.0,
          adminFeeCap: 2500,
          vatPct: 15,
          insurancePct: 0.4,
        ),
      ]);
    });
  }

  void _addOffer() {
    if (offers.length >= 4) return;
    setState(() {
      offers.add(LoanOffer(
        name: 'Offer ${offers.length + 1}',
        principal: 100000,
        rate: 6,
        isFlat: false,
        months: 60,
        adminFeePct: 1,
        adminFeeCap: 2500,
        vatPct: 15,
      ));
    });
  }

  void _remove(int i) => setState(() => offers.removeAt(i));

  Future<void> _export() async {
    if (offers.length < 2) return;
    final results = ComparisonEngine.compare(offers);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    await PdfReportService.generateComparisonReport(results: results, isArabic: isAr);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = offers.length >= 2 ? ComparisonEngine.compare(offers) : <ComparisonResult>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.compareLoans), actions: [
        IconButton(
          icon: const Icon(Icons.ios_share),
          tooltip: 'Email / Share',
          onPressed: results.isEmpty ? null : () => ShareService.showSheet(context,
              subject: l10n.compareLoans,
              body: [
                l10n.compareLoans,
                ...results.map((r) => '${r.isCheapest ? '★ ' : ''}${r.offer.name}: EMI ${r.emi.toStringAsFixed(2)} • total ${r.totalCost.toStringAsFixed(2)} • APR ${r.effectiveApr.toStringAsFixed(2)}%'),
              ].join('\n'),
              onPdf: _export),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Text(l10n.indicativeWarning, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          const SizedBox(height: 8),
          ...offers.asMap().entries.map((e) {
            final i = e.key;
            final o = e.value;
            return Card(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(12),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: l10n.offerName),
                      controller: TextEditingController(text: o.name),
                      onChanged: (v) => setState(() => offers[i] = LoanOffer(
                            name: v,
                            principal: o.principal,
                            rate: o.rate,
                            isFlat: o.isFlat,
                            months: o.months,
                            adminFeePct: o.adminFeePct,
                            adminFeeCap: o.adminFeeCap,
                            vatPct: o.vatPct,
                            insurancePct: o.insurancePct,
                            adminVatInclusive: o.adminVatInclusive,
                          )),
                    ),
                    NumberField(
                      controller: TextEditingController(text: o.principal.toString()),
                      label: l10n.amount,
                      onChanged: (v) {
                        final p = double.tryParse(v.replaceAll(',', '')) ?? o.principal;
                        setState(() => offers[i] = LoanOffer(
                              name: o.name,
                              principal: p,
                              rate: o.rate,
                              isFlat: o.isFlat,
                              months: o.months,
                              adminFeePct: o.adminFeePct,
                              adminFeeCap: o.adminFeeCap,
                              vatPct: o.vatPct,
                              insurancePct: o.insurancePct,
                              adminVatInclusive: o.adminVatInclusive,
                            ));
                      },
                    ),
                    SwitchListTile(
                      title: Text(l10n.flatRate),
                      value: o.isFlat,
                      onChanged: (v) => setState(() => offers[i] = LoanOffer(
                            name: o.name,
                            principal: o.principal,
                            rate: o.rate,
                            isFlat: v,
                            months: o.months,
                            adminFeePct: o.adminFeePct,
                            adminFeeCap: o.adminFeeCap,
                            vatPct: o.vatPct,
                            insurancePct: o.insurancePct,
                            adminVatInclusive: o.adminVatInclusive,
                          )),
                    ),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _remove(i)),
                  ],
                ),
              ),
            );
          }),
          if (offers.length < 4) OutlinedButton(onPressed: _addOffer, child: Text(l10n.addOffer)),
          const SizedBox(height: 16),
          if (results.isNotEmpty) ...[
            Text(l10n.results, style: Theme.of(context).textTheme.titleMedium),
            ...results.map((r) => Card(
                  color: r.isCheapest ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: ListTile(
                    title: Text(r.offer.name),
                    subtitle: Text(
                      '${l10n.totalCost}: ${r.totalCost.toStringAsFixed(2)}\n'
                      '${l10n.monthlyEmi}: ${r.emi.toStringAsFixed(2)}\n'
                      'APR: ${r.effectiveApr.toStringAsFixed(2)}% (incl. fees)',
                    ),
                    trailing: r.isCheapest ? const Icon(Icons.star, color: Colors.amber) : null,
                  ),
                )),
            ElevatedButton(onPressed: _export, child: Text(l10n.exportPdf)),
          ],
        ],
      ),
    );
  }
}
