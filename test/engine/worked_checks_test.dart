import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/general_mode.dart';

void main() {
  test('Saudi worked check (total salary base)', () {
    final r = EligibilityEngine.calculate(
      rules: RegulationRules.forCountry(Country.ksa), loanType: LoanType.personal, status: EmploymentStatus.employed,
      basic: 10000, housing: 2500, other: 0, existingEmis: 0, cardLimits: 0, annualRate: 5, tenorMonths: 60,
    );
    // ignore: avoid_print
    print('KSA emiCap=${r.remainingEmi} pv=${r.maxFinancing}');
    expect(r.remainingEmi, closeTo(4166.25, 0.01));
    expect(r.maxFinancing, closeTo(220772.53, 0.05));
  });

  test('KWT NBK citizen_government worked check', () {
    // category: apr 6.5, dbrCap 0.40, max 25,000 KWD, 60m, salaryBase total, 25x multiple, fee 1%
    final r = EligibilityEngine.calculate(
      rules: RegulationRules.forCountry(Country.kuwait), loanType: LoanType.personal, status: EmploymentStatus.employed,
      basic: 800, housing: 200, other: 0, existingEmis: 0, cardLimits: 0, annualRate: 6.5, tenorMonths: 60,
      customDbrCap: 0.40, bankDbrBase: DbrBase.totalSalary,
    );
    final principal = r.maxFinancing.clamp(0, 25000).toDouble();
    final fee = principal * 0.01;
    final r12 = 0.065 / 12;
    final emi = principal * r12 / (1 - 1 / _pow(1 + r12, 60));
    final apr = GeneralSettings.effectiveApr(principal, emi, 60, fee);
    // ignore: avoid_print
    print('KWT emiCap=${r.remainingEmi} pv=${r.maxFinancing} principal=$principal emi=$emi fee=$fee total=${emi * 60 + fee} apr=$apr');
    expect(r.remainingEmi, closeTo(400, 0.01));
    expect(principal, closeTo(20443.47, 0.05));
  });
}

double _pow(double b, int e) { var x = 1.0; for (var i = 0; i < e; i++) { x *= b; } return x; }
