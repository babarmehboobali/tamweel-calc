import 'amortization.dart';

enum PrepayMode { reduceTenure, reduceEmi }

class PrepayRow {
  final int month;
  final double payment; // regular installment + any extra
  final double profit;
  final double principal;
  final double balance;
  const PrepayRow(this.month, this.payment, this.profit, this.principal, this.balance);
}

class PrepaymentResult {
  final double baseProfit;
  final double newProfit;
  final int baseMonths;
  final int newMonths;
  final double baseEmi;
  final double finalEmi; // EMI after last re-amortisation (reduceEmi) or unchanged
  final List<PrepayRow> rows;
  double get interestSaved => baseProfit - newProfit;
  int get monthsSaved => baseMonths - newMonths;
  const PrepaymentResult({required this.baseProfit, required this.newProfit, required this.baseMonths, required this.newMonths,
      required this.baseEmi, required this.finalEmi, required this.rows});
}

/// Prepayment simulator (reducing balance). Extras are paid together with the instalment of the given month.
class PrepaymentEngine {
  static PrepaymentResult simulate({
    required double principal,
    required double annualRate,
    required int months,
    double lumpSum = 0,
    int lumpMonth = 12,
    double recurringExtra = 0,
    int recurringFrom = 1,
    PrepayMode mode = PrepayMode.reduceTenure,
  }) {
    final r = annualRate / 12 / 100;
    final baseEmi = AmortizationEngine.emi(principal, annualRate, months);
    final baseProfit = baseEmi * months - principal;
    var emi = baseEmi;
    var bal = principal;
    var profitSum = 0.0;
    final rows = <PrepayRow>[];
    for (var m = 1; m <= months && bal > 0.005; m++) {
      final profit = bal * r;
      var princ = emi - profit;
      var extra = (m == lumpMonth ? lumpSum : 0.0) + (m >= recurringFrom ? recurringExtra : 0.0);
      if (princ + extra > bal) {
        // final payment clears the balance
        princ = bal;
        extra = 0;
      } else {
        princ += extra;
      }
      bal -= princ;
      profitSum += profit;
      rows.add(PrepayRow(m, princ + profit, profit, princ, bal < 0.005 ? 0 : bal));
      if (mode == PrepayMode.reduceEmi && extra > 0 && bal > 0.005 && m < months) {
        emi = AmortizationEngine.emi(bal, annualRate, months - m);
      }
    }
    return PrepaymentResult(baseProfit: baseProfit, newProfit: profitSum, baseMonths: months, newMonths: rows.length,
        baseEmi: baseEmi, finalEmi: emi, rows: rows);
  }

  /// Indicative SAMA early settlement: pay outstanding principal + up to 3 months' future profit
  /// (all remaining future profit is rebated except up to 3 months).
  static ({double balance, double charge, double payoff, double futureProfit, double rebate}) samaSettlement({
    required double principal,
    required double annualRate,
    required int months,
    required int paidMonths,
  }) {
    final rows = AmortizationEngine.schedule(principal, annualRate, months);
    if (paidMonths >= months) return (balance: 0.0, charge: 0.0, payoff: 0.0, futureProfit: 0.0, rebate: 0.0);
    final balance = paidMonths <= 0 ? principal : rows[paidMonths - 1].closing;
    final future = rows.skip(paidMonths).toList();
    final futureProfit = future.fold(0.0, (s, x) => s + x.profit);
    final charge = future.take(3).fold(0.0, (s, x) => s + x.profit);
    return (balance: balance, charge: charge, payoff: balance + charge, futureProfit: futureProfit, rebate: futureProfit - charge);
  }
}
