import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/early_payoff.dart';

void main() {
  test('early payoff savings', () {
    final r = EarlyPayoffEngine.simulate(
      principal: 100000,
      annualRate: 6,
      originalMonths: 60,
      extraMonthly: 500,
    );
    expect(r.monthsSaved, greaterThan(0));
    expect(r.profitSaved, greaterThan(0));
  });
}
