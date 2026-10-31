import 'dart:math' as math;
import 'amortization.dart';

class ExistingLoan {
  final double outstanding;
  final double emi;
  final int remainingMonths;
  final double settlementCharge; // early-settlement fee/charge, if any
  const ExistingLoan({required this.outstanding, required this.emi, required this.remainingMonths, this.settlementCharge = 0});
}

class RefinanceResult {
  final double oldEmi;
  final double newEmi;
  final double emiChange; // new - old (negative = lower)
  final double payoffTotal;
  final double fee;
  final double cashInHand;
  final double oldRemainingCost;
  final double newTotalCost;
  final double savings; // positive = cheaper overall (compares total outflows; ignores cash-out value of money)
  const RefinanceResult({required this.oldEmi, required this.newEmi, required this.emiChange, required this.payoffTotal,
      required this.fee, required this.cashInHand, required this.oldRemainingCost, required this.newTotalCost, required this.savings});
}

/// Refinance / buy-out / consolidation. Based on Grok's R7 draft; fee+VAT, settlement charges and cash-out adjusted.
class RefinanceEngine {
  static RefinanceResult calculate({
    required List<ExistingLoan> existing,
    required double newPrincipal,
    required double newAnnualRate,
    required int newMonths,
    double adminFeePct = 0,
    double adminFeeCap = double.infinity,
    double vatPct = 0,
  }) {
    final payoff = existing.fold(0.0, (s, l) => s + l.outstanding + l.settlementCharge);
    final oldEmi = existing.fold(0.0, (s, l) => s + l.emi);
    final oldCost = existing.fold(0.0, (s, l) => s + l.emi * l.remainingMonths);
    final fee = math.min(newPrincipal * adminFeePct / 100, adminFeeCap) * (1 + vatPct / 100);
    final cash = newPrincipal - fee - payoff;
    final emi = AmortizationEngine.emi(newPrincipal, newAnnualRate, newMonths);
    final newCost = emi * newMonths;
    // Fair comparison: the new loan's cost is reduced by the cash it hands back.
    final savings = oldCost - (newCost - cash);
    return RefinanceResult(oldEmi: oldEmi, newEmi: emi, emiChange: emi - oldEmi, payoffTotal: payoff, fee: fee,
        cashInHand: cash, oldRemainingCost: oldCost, newTotalCost: newCost, savings: savings);
  }
}
