import 'dart:math' as math;
import 'amortization.dart';

class FlatRateEngine {
  static double flatToApr(double principal, double flatPercent, int years) {
    final months = years * 12;
    final totalProfit = principal * (flatPercent / 100) * years;
    final emi = (principal + totalProfit) / months;
    return _solveApr(principal, emi, months);
  }

  static double aprToFlat(double principal, double aprPercent, int years) {
    final months = years * 12;
    final emi = AmortizationEngine.emi(principal, aprPercent, months);
    final totalPaid = emi * months;
    final totalProfit = totalPaid - principal;
    return (totalProfit / principal / years) * 100;
  }

  static double _solveApr(double principal, double emi, int months) {
    double low = 0.0;
    double high = 0.5;
    for (int i = 0; i < 200; i++) {
      final mid = (low + high) / 2;
      final pv = emi * (1 - math.pow(1 + mid, -months)) / mid;
      if ((pv - principal).abs() < 1e-8) return mid * 12 * 100;
      if (pv > principal) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return ((low + high) / 2) * 12 * 100;
  }
}
