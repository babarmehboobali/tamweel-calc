import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';

void main() {
  // KSA employed, income 15000, existing 1000, no cards, 6% 60m → remaining ~4000, max ~206k
  test('KSA consumer worked example', () {
    final rules = RegulationRules.forCountry(Country.ksa);
    final r = EligibilityEngine.calculate(
      rules: rules,
      loanType: LoanType.personal,
      status: EmploymentStatus.employed,
      basic: 10000,
      housing: 3000,
      other: 2000,
      existingEmis: 1000,
      cardLimits: 0,
      annualRate: 6,
      tenorMonths: 60,
    );
    expect(r.capPct, closeTo(0.3333, 0.001));
    expect(r.remainingEmi, closeTo(4000, 1));
    expect(r.maxFinancing, closeTo(206900, 200));
  });

  // UAE 50% + 20x
  test('UAE 50% DBR and 20x multiple', () {
    final rules = RegulationRules.forCountry(Country.uae);
    final r = EligibilityEngine.calculate(
      rules: rules,
      loanType: LoanType.personal,
      status: EmploymentStatus.employed,
      basic: 15000,
      housing: 0,
      other: 0,
      existingEmis: 0,
      cardLimits: 0,
      annualRate: 5,
      tenorMonths: 48,
    );
    expect(r.capPct, 0.5);
    expect(r.maxFinancing, lessThanOrEqualTo(15000 * 20));
  });

  // Card burden 5%
  test('card limit burden 5%', () {
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
