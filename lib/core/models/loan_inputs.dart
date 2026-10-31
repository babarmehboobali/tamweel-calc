import '../engine/regulations.dart';

class LoanInputs {
  final Country country;
  final LoanType loanType;
  final EmploymentStatus employmentStatus;
  final double basicSalary;
  final double housingAllowance;
  final double otherAllowances;
  final double existingEmis;
  final double cardLimits;
  final double annualRate;
  final int tenorMonths;
  final double? customDbrCap;

  const LoanInputs({
    required this.country,
    required this.loanType,
    required this.employmentStatus,
    required this.basicSalary,
    required this.housingAllowance,
    required this.otherAllowances,
    required this.existingEmis,
    required this.cardLimits,
    required this.annualRate,
    required this.tenorMonths,
    this.customDbrCap,
  });

  LoanInputs copyWith({
    Country? country,
    LoanType? loanType,
    EmploymentStatus? employmentStatus,
    double? basicSalary,
    double? housingAllowance,
    double? otherAllowances,
    double? existingEmis,
    double? cardLimits,
    double? annualRate,
    int? tenorMonths,
    double? customDbrCap,
  }) {
    return LoanInputs(
      country: country ?? this.country,
      loanType: loanType ?? this.loanType,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      basicSalary: basicSalary ?? this.basicSalary,
      housingAllowance: housingAllowance ?? this.housingAllowance,
      otherAllowances: otherAllowances ?? this.otherAllowances,
      existingEmis: existingEmis ?? this.existingEmis,
      cardLimits: cardLimits ?? this.cardLimits,
      annualRate: annualRate ?? this.annualRate,
      tenorMonths: tenorMonths ?? this.tenorMonths,
      customDbrCap: customDbrCap ?? this.customDbrCap,
    );
  }
}
