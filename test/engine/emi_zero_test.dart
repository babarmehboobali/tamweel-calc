import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/amortization.dart';

void main() {
  test('EMI at 0% rate', () {
    expect(AmortizationEngine.emi(12000, 0, 12), closeTo(1000, 0.01));
  });
}
