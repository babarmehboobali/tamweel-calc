import 'dart:math' as math;
import 'amortization.dart';
import 'money.dart';

class LoanOffer {
  final String name;
  final double principal;
  final double rate;
  final bool isFlat;
  final int months;
  final double adminFeePct;
  final double? adminFeeCap;
  final double vatPct;
  final double insurancePct;
  final bool adminVatInclusive;

  const LoanOffer({
    required this.name,
    required this.principal,
    required this.rate,
    required this.isFlat,
    required this.months,
    this.adminFeePct = 1.0,
    this.adminFeeCap,
    this.vatPct = 15,
    this.insurancePct = 0,
    this.adminVatInclusive = false,
  });
}

class ComparisonResult {
  final LoanOffer offer;
  final double emi;
  final double totalCost;
  final double totalProfitFees;
  final double effectiveApr;
  final bool isCheapest;

  const ComparisonResult({
    required this.offer,
    required this.emi,
    required this.totalCost,
    required this.totalProfitFees,
    required this.effectiveApr,
    required this.isCheapest,
  });
}

class ComparisonEngine {
  static List<ComparisonResult> compare(List<LoanOffer> offers) {
    final results = <ComparisonResult>[];
    for (final o in offers) {
      double rate = o.rate;
      if (o.isFlat) {
        // simple flat-to-reducing approximation for EMI
        rate = o.rate * 1.8; // rough; real uses IRR
      }
      final emi = AmortizationEngine.emi(o.principal, rate, o.months);
      final totalPayments = emi * o.months;

      double admin = o.principal * o.adminFeePct / 100;
      if (o.adminFeeCap != null) admin = math.min(admin, o.adminFeeCap!);
      double adminWithVat = o.adminVatInclusive ? admin : admin * (1 + o.vatPct / 100);
      final insurance = o.principal * o.insurancePct / 100;
      final totalFees = adminWithVat + insurance;
      final totalCost = totalPayments + totalFees;
      final profitFees = totalCost - o.principal;

      // simple effective APR approximation (cash flow IRR-like)
      final netPrincipal = o.principal - adminWithVat;
      final approxApr = (profitFees / netPrincipal) / (o.months / 12) * 100;

      results.add(ComparisonResult(
        offer: o,
        emi: Money.round2(emi),
        totalCost: Money.round2(totalCost),
        totalProfitFees: Money.round2(profitFees),
        effectiveApr: Money.round2(approxApr),
        isCheapest: false,
      ));
    }
    results.sort((a, b) => a.totalCost.compareTo(b.totalCost));
    if (results.isNotEmpty) {
      final cheapest = results.first;
      results[0] = ComparisonResult(
        offer: cheapest.offer,
        emi: cheapest.emi,
        totalCost: cheapest.totalCost,
        totalProfitFees: cheapest.totalProfitFees,
        effectiveApr: cheapest.effectiveApr,
        isCheapest: true,
      );
    }
    return results;
  }
}
