import 'dart:math' as math;
import 'money.dart';

class AmortizationRow {
  final int month;
  final double opening;
  final double installment;
  final double principal;
  final double profit;
  final double closing;

  const AmortizationRow({
    required this.month,
    required this.opening,
    required this.installment,
    required this.principal,
    required this.profit,
    required this.closing,
  });
}

class AmortizationEngine {
  static double emi(double principal, double annualRate, int months) {
    if (months <= 0) return 0;
    final r = annualRate / 12 / 100;
    if (r == 0) return principal / months;
    final factor = math.pow(1 + r, months).toDouble();
    return principal * r * factor / (factor - 1);
  }

  static List<AmortizationRow> schedule(double principal, double annualRate, int months) {
    if (months <= 0 || principal <= 0) return [];
    final installment = emi(principal, annualRate, months);
    final r = annualRate / 12 / 100;
    final rows = <AmortizationRow>[];
    double balance = principal;

    for (int m = 1; m <= months; m++) {
      final profit = balance * r;
      double principalPart = installment - profit;
      if (m == months) {
        principalPart = balance;
      }
      final closing = (balance - principalPart).clamp(0.0, double.infinity);
      rows.add(AmortizationRow(
        month: m,
        opening: Money.round2(balance),
        installment: Money.round2(m == months ? principalPart + profit : installment),
        principal: Money.round2(principalPart),
        profit: Money.round2(profit),
        closing: Money.round2(closing),
      ));
      balance = closing;
    }
    return rows;
  }
}

