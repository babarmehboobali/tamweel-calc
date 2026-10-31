import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/general_mode.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/amortization.dart';
import 'package:tamweel_calc/core/models/country.dart';

void main() {
  setUp(() {
    GeneralSettings.currency = 'USD';
    GeneralSettings.dbrCap = 0.40;
    GeneralSettings.adminFeePct = 0;
    GeneralSettings.adminFeeFixed = 0;
    GeneralSettings.salaryMultiple = null;
  });

  test('flat 5% over 60m converts to ~9.1% reducing APR', () {
    final apr = GeneralSettings.flatToReducingApr(5, 60);
    expect(apr, closeTo(9.11, 0.05));
    // EMI at that APR equals flat EMI on 100k: (100000 + 100000*0.05*5)/60
    expect(AmortizationEngine.emi(100000, apr, 60), closeTo(125000 / 60, 0.5));
  });

  test('admin fee % + fixed', () {
    GeneralSettings.adminFeePct = 1;
    GeneralSettings.adminFeeFixed = 50;
    expect(GeneralSettings.adminFee(100000), 1050);
  });

  test('effective APR rises above nominal with upfront fee', () {
    final emi = AmortizationEngine.emi(100000, 8, 60);
    expect(GeneralSettings.effectiveApr(100000, emi, 60, 0), closeTo(8, 0.05));
    expect(GeneralSettings.effectiveApr(100000, emi, 60, 2000), greaterThan(8.7));
  });

  test('General eligibility uses 40% DBR and chosen currency', () {
    GeneralSettings.currency = 'EUR';
    final rules = RegulationRules.forCountry(Country.general);
    expect(rules.currency, 'EUR');
    final r = EligibilityEngine.calculate(
      rules: rules, loanType: LoanType.personal, status: EmploymentStatus.employed,
      basic: 5000, housing: 0, other: 0, existingEmis: 500, cardLimits: 0,
      annualRate: 8, tenorMonths: 60,
    );
    expect(r.maxTotalEmi, closeTo(2000, 0.01));
    expect(r.remainingEmi, closeTo(1500, 0.01));
  });

  test('salary multiple caps financing', () {
    GeneralSettings.salaryMultiple = 10;
    final r = EligibilityEngine.calculate(
      rules: RegulationRules.forCountry(Country.general), loanType: LoanType.personal, status: EmploymentStatus.employed,
      basic: 5000, housing: 0, other: 0, existingEmis: 0, cardLimits: 0, annualRate: 8, tenorMonths: 60,
    );
    expect(r.maxFinancing, lessThanOrEqualTo(50000.01));
  });

  test('default country by region', () {
    expect(defaultCountryForRegion('SA'), Country.ksa);
    expect(defaultCountryForRegion('AE'), Country.uae);
    expect(defaultCountryForRegion('US'), Country.general);
    expect(defaultCountryForRegion(null), Country.general);
  });
}
