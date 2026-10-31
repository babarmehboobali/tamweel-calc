import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/utils/number_parser.dart';

void main() {
  test('Arabic-Indic digits', () {
    expect(NumberParser.parse('١٢٣٫٤٥'), closeTo(123.45, 0.01));
  });
}
