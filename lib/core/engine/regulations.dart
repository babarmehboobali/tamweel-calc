import 'general_mode.dart';
enum Country { general, ksa, uae, qatar, kuwait, bahrain, oman }
enum LoanType { personal, auto, mortgage }
enum EmploymentStatus { employed, pensioner }

class MortgageTier {
  final double maxIncome;
  final double cap;
  const MortgageTier(this.maxIncome, this.cap);
}

class RegulationRules {
  final Country country;
  final double consumerDbrCap;
  final double pensionerDbrCap;
  final List<MortgageTier> mortgageDbrTiers;
  final double cardLimitBurdenPct;
  final double? consumerSalaryMultipleCap;
  final int maxConsumerTenorMonths;
  final int maxMortgageTenorMonths;
  final String currency;
  final bool isVerified;

  const RegulationRules({
    required this.country,
    required this.consumerDbrCap,
    required this.pensionerDbrCap,
    required this.mortgageDbrTiers,
    required this.cardLimitBurdenPct,
    this.consumerSalaryMultipleCap,
    required this.maxConsumerTenorMonths,
    required this.maxMortgageTenorMonths,
    required this.currency,
    required this.isVerified,
  });

  double capFor(LoanType type, EmploymentStatus status, double income) {
    if (type == LoanType.mortgage) {
      for (final tier in mortgageDbrTiers) {
        if (income <= tier.maxIncome) return tier.cap;
      }
      return mortgageDbrTiers.last.cap;
    }
    if (status == EmploymentStatus.pensioner) return pensionerDbrCap;
    return consumerDbrCap;
  }

  static RegulationRules forCountry(Country c) {
    switch (c) {
      case Country.general:
        return RegulationRules(
          country: Country.general,
          consumerDbrCap: GeneralSettings.dbrCap,
          pensionerDbrCap: GeneralSettings.dbrCap,
          mortgageDbrTiers: [MortgageTier(double.infinity, GeneralSettings.dbrCap)],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: GeneralSettings.salaryMultiple,
          maxConsumerTenorMonths: 360,
          maxMortgageTenorMonths: 360,
          currency: GeneralSettings.currency,
          isVerified: true,
        );
      case Country.ksa:
        return const RegulationRules(
          country: Country.ksa,
          consumerDbrCap: 0.3333,
          pensionerDbrCap: 0.25,
          mortgageDbrTiers: [
            MortgageTier(15000, 0.55),
            MortgageTier(25000, 0.65),
            MortgageTier(double.infinity, 0.65),
          ],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: null,
          maxConsumerTenorMonths: 60,
          maxMortgageTenorMonths: 300,
          currency: 'SAR',
          isVerified: true,
        );
      case Country.uae:
        return const RegulationRules(
          country: Country.uae,
          consumerDbrCap: 0.50,
          pensionerDbrCap: 0.30,
          mortgageDbrTiers: [MortgageTier(double.infinity, 0.50)],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: 20.0,
          maxConsumerTenorMonths: 48,
          maxMortgageTenorMonths: 300,
          currency: 'AED',
          isVerified: true,
        );
      case Country.qatar:
        return const RegulationRules(
          country: Country.qatar,
          consumerDbrCap: 0.50,
          pensionerDbrCap: 0.50,
          mortgageDbrTiers: [MortgageTier(double.infinity, 0.50)],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: null,
          maxConsumerTenorMonths: 48,
          maxMortgageTenorMonths: 300,
          currency: 'QAR',
          isVerified: false,
        );
      case Country.kuwait:
        return const RegulationRules(
          country: Country.kuwait,
          consumerDbrCap: 0.40,
          pensionerDbrCap: 0.30,
          mortgageDbrTiers: [MortgageTier(double.infinity, 0.40)],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: 25.0,
          maxConsumerTenorMonths: 60,
          maxMortgageTenorMonths: 180,
          currency: 'KWD',
          isVerified: false,
        );
      case Country.bahrain:
        return const RegulationRules(
          country: Country.bahrain,
          consumerDbrCap: 0.50,
          pensionerDbrCap: 0.50,
          mortgageDbrTiers: [MortgageTier(double.infinity, 0.50)],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: null,
          maxConsumerTenorMonths: 60,
          maxMortgageTenorMonths: 300,
          currency: 'BHD',
          isVerified: false,
        );
      case Country.oman:
        return const RegulationRules(
          country: Country.oman,
          consumerDbrCap: 0.50,
          pensionerDbrCap: 0.50,
          mortgageDbrTiers: [MortgageTier(double.infinity, 0.50)],
          cardLimitBurdenPct: 0.05,
          consumerSalaryMultipleCap: null,
          maxConsumerTenorMonths: 60,
          maxMortgageTenorMonths: 300,
          currency: 'OMR',
          isVerified: false,
        );
    }
  }
}
