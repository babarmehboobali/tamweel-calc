import 'amortization.dart';
import 'money.dart';

class EarlyPayoffResult {
  final int newTenorMonths;
  final int monthsSaved;
  final double profitSaved;
  final double totalProfitNew;

  const EarlyPayoffResult({
    required this.newTenorMonths,
    required this.monthsSaved,
    required this.profitSaved,
    required this.totalProfitNew,
  });
}

class EarlyPayoffEngine {
  static EarlyPayoffResult simulate({
    required double principal,
    required double annualRate,
    required int originalMonths,
    required double extraMonthly,
    double lumpSum = 0,
    int lumpSumMonth = 0,
  }) {
    final originalEmi = AmortizationEngine.emi(principal, annualRate, originalMonths);
    final originalProfit = (originalEmi * originalMonths) - principal;

    double balance = principal;
    final r = annualRate / 12 / 100;
    int month = 0;
    double totalProfit = 0;

    while (balance > 0.01 && month < originalMonths * 2) {
      month++;
      final profit = balance * r;
      totalProfit += profit;
      double payment = originalEmi + extraMonthly;
      if (month == lumpSumMonth) payment += lumpSum;
      final principalPaid = (payment - profit).clamp(0.0, balance);
      balance -= principalPaid;
      if (balance < 0.01) balance = 0;
    }

    final monthsSaved = (originalMonths - month).clamp(0, originalMonths);
    final profitSaved = (originalProfit - totalProfit).clamp(0.0, double.infinity);

    return EarlyPayoffResult(
      newTenorMonths: month,
      monthsSaved: monthsSaved,
      profitSaved: Money.round2(profitSaved),
      totalProfitNew: Money.round2(totalProfit),
    );
  }
}
