import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';

void main() {
  test('UAE 50% DBR cap', () {
    final rules = RegulationRules.forCountry(Country.uae);
    final r = EligibilityEngine.calculate(
      rules: rules,
      loanType: LoanType.personal,
      status: EmploymentStatus.employed,
      basic: 10000,
      housing: 0,
      other: 0,
      existingEmis: 0,
      cardLimits: 0,
      annualRate: 5,
      tenorMonths: 48,
    );
    expect(r.capPct, 0.5);
  });

  test('card-limit burden 5%', () {
    final rules = RegulationRules.forCountry(Country.uae);
    final r = EligibilityEngine.calculate(
      rules: rules,
      loanType: LoanType.personal,
      status: EmploymentStatus.employed,
      basic: 10000,
      housing: 0,
      other: 0,
      existingEmis: 0,
      cardLimits: 10000,
      annualRate: 5,
      tenorMonths: 48,
    );
    expect(r.cardBurden, closeTo(500, 1));
  });
}
