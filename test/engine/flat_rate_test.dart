import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/flat_rate.dart';

void main() {
  test('flat to APR conversion', () {
    final apr = FlatRateEngine.flatToApr(100000, 3, 5);
    expect(apr, greaterThan(5));
  });
}
