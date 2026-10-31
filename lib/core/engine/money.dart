/// Banker-safe rounding to 2 decimal places for display.
/// Calculations stay in full double precision until display.
class Money {
  static double round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  static double roundTo(double value, int decimals) {
    final factor = _pow10(decimals);
    return (value * factor).roundToDouble() / factor;
  }

  static double _pow10(int n) {
    double r = 1;
    for (int i = 0; i < n; i++) r *= 10;
    return r;
  }
}
