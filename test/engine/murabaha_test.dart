import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/murabaha.dart';

void main() {
  test('murabaha calculation', () {
    final r = MurabahaEngine.calculate(
      financedAmount: 100000,
      annualProfitRate: 6,
      months: 60,
      adminFeePct: 1,
      vatPct: 15,
    );
    expect(r.salePrice, greaterThan(100000));
    expect(r.netCash, lessThan(100000));
  });
}
