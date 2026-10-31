import 'dart:math' as math;
import 'regulations.dart';
import 'money.dart';

enum LimitingFactor { dbr, salaryMultiple, noCapacity }
enum DbrBase { basicOnly, totalSalary }

class EligibilityResult {
  final double eligibleIncome;
  final double dbrBaseIncome;
  final DbrBase dbrBaseUsed;
  final double capPct;
  final double maxTotalEmi;
  final double cardBurden;
  final double currentBurden;
  final double remainingEmi;
  final double maxFinancing;
  final LimitingFactor limitingFactor;

  const EligibilityResult({
    required this.eligibleIncome,
    required this.dbrBaseIncome,
    required this.dbrBaseUsed,
    required this.capPct,
    required this.maxTotalEmi,
    required this.cardBurden,
    required this.currentBurden,
    required this.remainingEmi,
    required this.maxFinancing,
    required this.limitingFactor,
  });
}

class EligibilityEngine {
  static EligibilityResult calculate({
    required RegulationRules rules,
    required LoanType loanType,
    required EmploymentStatus status,
    required double basic,
    required double housing,
    required double other,
    required double existingEmis,
    required double cardLimits,
    required double annualRate,
    required int tenorMonths,
    double? customDbrCap,
    DbrBase? bankDbrBase,
  }) {
    final totalSalary = basic + housing + other;
    final dbrBase = bankDbrBase ?? (rules.country == Country.ksa ? DbrBase.totalSalary : DbrBase.totalSalary);
    final dbrBaseIncome = dbrBase == DbrBase.basicOnly ? basic : totalSalary;

    double capPct = customDbrCap ?? rules.capFor(loanType, status, totalSalary);
    if (rules.country == Country.ksa && loanType != LoanType.mortgage) {
      capPct = status == EmploymentStatus.pensioner ? 0.25 : 0.3333;
    }

    final maxTotalEmi = dbrBaseIncome * capPct;
    final cardBurden = cardLimits * rules.cardLimitBurdenPct;
    final currentBurden = existingEmis + cardBurden;
    final remainingEmi = (maxTotalEmi - currentBurden).clamp(0.0, double.infinity);

    double maxFinancing = 0;
    if (remainingEmi > 0 && tenorMonths > 0) {
      final r = annualRate / 12 / 100;
      if (r == 0) {
        maxFinancing = remainingEmi * tenorMonths;
      } else {
        maxFinancing = remainingEmi * (1 - math.pow(1 + r, -tenorMonths)) / r;
      }
    }

    LimitingFactor factor = LimitingFactor.dbr;
    if (remainingEmi <= 0) {
      factor = LimitingFactor.noCapacity;
      maxFinancing = 0;
    } else if (loanType != LoanType.mortgage && rules.consumerSalaryMultipleCap != null) {
      final multipleCap = rules.consumerSalaryMultipleCap! * totalSalary;
      if (maxFinancing > multipleCap) {
        maxFinancing = multipleCap;
        factor = LimitingFactor.salaryMultiple;
      }
    }

    return EligibilityResult(
      eligibleIncome: totalSalary,
      dbrBaseIncome: dbrBaseIncome,
      dbrBaseUsed: dbrBase,
      capPct: capPct,
      maxTotalEmi: Money.round2(maxTotalEmi),
      cardBurden: Money.round2(cardBurden),
      currentBurden: Money.round2(currentBurden),
      remainingEmi: Money.round2(remainingEmi),
      maxFinancing: Money.round2(maxFinancing),
      limitingFactor: factor,
    );
  }
}
