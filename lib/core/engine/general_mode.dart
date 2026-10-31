import 'dart:math' as math;

/// User-defined settings for "General / Worldwide" mode (no preset regulator or bank rules).
class GeneralSettings {
  static String currency = 'USD';
  static double dbrCap = 0.40;
  static bool flatRate = false;
  static double adminFeePct = 0;
  static double adminFeeFixed = 0;
  static double? salaryMultiple;
  /// Rate as typed by the user (flat or reducing, per [flatRate]).
  static double? enteredRate;

  static const commonCurrencies = [
    'USD', 'EUR', 'GBP', 'PKR', 'INR', 'BDT', 'EGP', 'JOD', 'TRY', 'MYR', 'IDR', 'PHP', 'NGN', 'ZAR',
    'CAD', 'AUD', 'CHF', 'JPY', 'CNY', 'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR',
  ];

  /// Converts a flat (add-on) annual rate to the equivalent reducing APR (%).
  static double flatToReducingApr(double flatPct, int months) {
    if (flatPct <= 0 || months <= 0) return 0;
    final emiPerUnit = (1 + flatPct / 100 * months / 12) / months;
    double lo = 0, hi = 1;
    for (var i = 0; i < 200; i++) {
      final m = (lo + hi) / 2;
      final pv = emiPerUnit * (1 - math.pow(1 + m, -months)) / m;
      if (pv > 1) { lo = m; } else { hi = m; }
    }
    return (lo + hi) / 2 * 12 * 100;
  }

  /// Admin fee for a principal: percentage plus fixed amount.
  static double adminFee(double principal) => principal * adminFeePct / 100 + adminFeeFixed;

  /// Effective APR (%) including upfront fees, from monthly IRR on net proceeds.
  static double effectiveApr(double principal, double emi, int months, double upfrontFees) {
    final net = principal - upfrontFees;
    if (net <= 0 || months <= 0) return 0;
    double lo = 0, hi = 1;
    for (var i = 0; i < 200; i++) {
      final m = (lo + hi) / 2;
      final pv = m == 0 ? emi * months : emi * (1 - math.pow(1 + m, -months)) / m;
      if (pv > net) { lo = m; } else { hi = m; }
    }
    return (lo + hi) / 2 * 12 * 100;
  }
}
