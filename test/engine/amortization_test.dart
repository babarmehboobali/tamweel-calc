import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/amortization.dart';

void main() {
  test('0% rate EMI', () {
    expect(AmortizationEngine.emi(12000, 0, 12), closeTo(1000, 0.01));
  });

  test('last row balance reaches 0', () {
    final s = AmortizationEngine.schedule(100000, 6, 60);
    expect(s.last.closing, closeTo(0, 0.1));
  });
}
