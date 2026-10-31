import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';

void main() {
  test('KSA consumer DBR 33.33% example', () {
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
  });

  test('UAE 50% DBR and card burden', () {
    final rules = RegulationRules.forCountry(Country.uae);
    final r = EligibilityEngine.calculate(
      rules: rules,
      loanType: LoanType.personal,
      status: EmploymentStatus.employed,
      basic: 15000,
      housing: 0,
      other: 0,
      existingEmis: 0,
      cardLimits: 20000,
      annualRate: 5,
      tenorMonths: 48,
    );
    expect(r.cardBurden, closeTo(1000, 1));
  });
}
