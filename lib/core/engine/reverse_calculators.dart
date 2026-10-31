import 'dart:math' as math;
import 'amortization.dart';

class ReverseCalculators {
  /// Max principal for a target EMI (reducing balance). PV of an annuity.
  static double maxPrincipalForEmi({required double emi, required double annualRate, required int months}) {
    if (months <= 0 || emi <= 0) return 0;
    final r = annualRate / 12 / 100;
    if (r == 0) return emi * months;
    return emi * (1 - math.pow(1 + r, -months)) / r;
  }

  /// Months needed to repay [principal] with [emi]; null if the EMI never covers the profit.
  static int? monthsForEmi({required double principal, required double emi, required double annualRate}) {
    if (principal <= 0 || emi <= 0) return null;
    final r = annualRate / 12 / 100;
    if (r == 0) return (principal / emi).ceil();
    if (emi <= principal * r) return null;
    final n = -math.log(1 - principal * r / emi) / math.log(1 + r);
    return (n - 1e-3).ceil();
  }

  /// Annual reducing rate (%) implied by an EMI. Newton's method with bisection fallback.
  static double? rateFromEmi({required double principal, required double emi, required int months}) {
    if (principal <= 0 || emi <= 0 || months <= 0) return null;
    if (emi * months < principal - 1e-9) return null; // negative rate
    if ((emi * months - principal).abs() < 1e-9) return 0;
    double f(double r) => AmortizationEngine.emi(principal, r * 1200, months) - emi;
    var r = (emi * months / principal - 1) / months; // initial guess (monthly)
    for (var i = 0; i < 50; i++) {
      final h = 1e-7;
      final d = (f(r + h) - f(r - h)) / (2 * h);
      if (d == 0) break;
      final next = r - f(r) / d;
      if (next <= 0 || next.isNaN) break;
      if ((next - r).abs() < 1e-12) return next * 1200;
      r = next;
    }
    var lo = 0.0, hi = 1.0;
    for (var i = 0; i < 200; i++) {
      final mid = (lo + hi) / 2;
      if (f(mid) > 0) { hi = mid; } else { lo = mid; }
    }
    return (lo + hi) / 2 * 1200;
  }
}
