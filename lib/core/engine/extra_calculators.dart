import 'dart:math' as math;
import 'amortization.dart';

class ExtraCalculators {
  /// Mortgage with down payment.
  static ({double down, double loan, double emi, double totalProfit, double totalPaid}) mortgage({
    required double price, required double downPct, required double annualRate, required int months}) {
    final down = price * downPct / 100;
    final loan = price - down;
    final emi = AmortizationEngine.emi(loan, annualRate, months);
    return (down: down, loan: loan, emi: emi, totalProfit: emi * months - loan, totalPaid: down + emi * months);
  }

  /// Car loan with a balloon (final lump) payment. EMI = (P - B·v^n)·r / (1 - v^n), v = 1/(1+r).
  static ({double loan, double balloon, double emi, double totalProfit, double totalPaid}) balloon({
    required double price, required double down, required double balloonPct, required double annualRate, required int months}) {
    final loan = price - down;
    final b = price * balloonPct / 100;
    final r = annualRate / 12 / 100;
    final double emi;
    if (r == 0) {
      emi = (loan - b) / months;
    } else {
      final v = math.pow(1 + r, -months).toDouble();
      emi = (loan - b * v) * r / (1 - v);
    }
    final paid = emi * months + b;
    return (loan: loan, balloon: b, emi: emi, totalProfit: paid - loan, totalPaid: paid + down);
  }

  /// Credit card payoff with a fixed monthly payment. Interest = balance × APR/12 each month.
  /// Returns null months if the payment never covers the interest.
  static ({int? months, double totalInterest, double totalPaid}) creditCard({
    required double balance, required double apr, required double payment}) {
    final r = apr / 12 / 100;
    if (payment <= balance * r) return (months: null, totalInterest: double.infinity, totalPaid: double.infinity);
    var b = balance, interest = 0.0, paid = 0.0, m = 0;
    while (b > 0.005 && m < 1200) {
      final i = b * r;
      interest += i;
      final pay = math.min(payment, b + i);
      paid += pay;
      b = b + i - pay;
      m++;
    }
    return (months: m, totalInterest: interest, totalPaid: paid);
  }
}

/// Real due dates: same day each month, clamped to month end.
DateTime dueDate(DateTime start, int k) {
  final y = start.year + (start.month - 1 + k) ~/ 12;
  final mo = (start.month - 1 + k) % 12 + 1;
  final last = DateTime(y, mo + 1, 0).day;
  return DateTime(y, mo, math.min(start.day, last));
}
