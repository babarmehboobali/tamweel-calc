import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/comparison.dart';

void main() {
  test('comparison ranking', () {
    final offers = [
      const LoanOffer(name: 'A', principal: 100000, rate: 7, isFlat: false, months: 60, adminFeePct: 1, vatPct: 15),
      const LoanOffer(name: 'B', principal: 100000, rate: 5, isFlat: false, months: 60, adminFeePct: 1, vatPct: 15),
    ];
    final results = ComparisonEngine.compare(offers);
    expect(results.first.isCheapest, isTrue);
    expect(results.first.offer.name, 'B');
  });
}
