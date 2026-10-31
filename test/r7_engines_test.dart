import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/prepayment.dart';
import 'package:tamweel_calc/core/engine/reverse_calculators.dart';
import 'package:tamweel_calc/core/engine/refinance.dart';
import 'package:tamweel_calc/core/engine/extra_calculators.dart';

// Hand-worked examples. 12% p.a. = 1% per month throughout.
void main() {
  group('prepayment', () {
    // 12,000 over 12m @1%: EMI = 12000·0.01/(1-1.01^-12) = 1,066.19; base profit = 12·1066.19-12000 = 794.23
    test('lump 6,000 in month 1, shorter tenure', () {
      final r = PrepaymentEngine.simulate(principal: 12000, annualRate: 12, months: 12, lumpSum: 6000, lumpMonth: 1);
      expect(r.baseEmi, closeTo(1066.19, 0.01));
      expect(r.baseProfit, closeTo(794.23, 0.01));
      // m1: profit 120, principal 946.19+6000 -> bal 5,053.81; then 1066.19 EMIs clear it in 5 more months
      expect(r.rows.first.balance, closeTo(5053.81, 0.01));
      expect(r.newMonths, 6);
      expect(r.monthsSaved, 6);
      expect(r.newProfit, closeTo(270.11, 0.01));
      expect(r.interestSaved, closeTo(524.12, 0.01));
    });
    test('lump 6,000 in month 1, lower EMI', () {
      final r = PrepaymentEngine.simulate(principal: 12000, annualRate: 12, months: 12, lumpSum: 6000, lumpMonth: 1, mode: PrepayMode.reduceEmi);
      // re-amortise 5,053.81 over 11m: 5053.81·0.01/(1-1.01^-11) = 487.46
      expect(r.finalEmi, closeTo(487.46, 0.01));
      expect(r.newMonths, 12);
      expect(r.newProfit, closeTo(428.26, 0.01));
    });
    test('recurring extra shortens tenure', () {
      final r = PrepaymentEngine.simulate(principal: 12000, annualRate: 12, months: 12, recurringExtra: 1000);
      expect(r.newMonths, lessThan(12));
      expect(r.rows.last.balance, 0);
    });
    test('SAMA settlement = balance + next 3 months profit', () {
      final s = PrepaymentEngine.samaSettlement(principal: 12000, annualRate: 12, months: 12, paidMonths: 6);
      final emi = 12000 * 0.01 / (1 - math.pow(1.01, -12));
      final bal = emi * (1 - math.pow(1.01, -6)) / 0.01; // PV of 6 remaining = 6,179.02
      expect(s.balance, closeTo(bal, 0.02));
      // profits m7..m9: bal·1%, then on reduced balances
      final b8 = bal * 1.01 - emi, b9 = b8 * 1.01 - emi;
      expect(s.charge, closeTo((bal + b8 + b9) * 0.01, 0.03));
      expect(s.payoff, closeTo(s.balance + s.charge, 1e-9));
      expect(s.rebate, closeTo(s.futureProfit - s.charge, 1e-9));
    });
  });

  group('reverse', () {
    test('max loan for EMI 1,000 x 12m @12% = 11,255.08', () {
      expect(ReverseCalculators.maxPrincipalForEmi(emi: 1000, annualRate: 12, months: 12), closeTo(11255.08, 0.01));
    });
    test('tenure for EMI', () {
      expect(ReverseCalculators.monthsForEmi(principal: 11255.08, emi: 1000, annualRate: 12), 12);
      expect(ReverseCalculators.monthsForEmi(principal: 12000, emi: 100, annualRate: 12), isNull); // 100 < 120 profit
      expect(ReverseCalculators.monthsForEmi(principal: 1200, emi: 100, annualRate: 0), 12);
    });
    test('rate from EMI (Newton) recovers 12%', () {
      expect(ReverseCalculators.rateFromEmi(principal: 11255.08, emi: 1000, months: 12), closeTo(12, 0.001));
      expect(ReverseCalculators.rateFromEmi(principal: 12000, emi: 1000, months: 12), 0);
    });
  });

  test('refinance: one loan bought out with cash out', () {
    final r = RefinanceEngine.calculate(
      existing: const [ExistingLoan(outstanding: 50000, emi: 2000, remainingMonths: 30, settlementCharge: 500)],
      newPrincipal: 60000, newAnnualRate: 12, newMonths: 36, adminFeePct: 1, adminFeeCap: 5000, vatPct: 15);
    expect(r.fee, closeTo(690, 1e-6)); // 600 + 15% VAT
    expect(r.payoffTotal, 50500);
    expect(r.cashInHand, closeTo(8810, 1e-6)); // 60000-690-50500
    expect(r.newEmi, closeTo(1992.86, 0.01)); // 60000·0.01/(1-1.01^-36)
    expect(r.oldRemainingCost, 60000);
    expect(r.savings, closeTo(60000 - (1992.86 * 36 - 8810), 0.5));
  });

  test('balloon car loan: 100k, 30% balloon, 12m @12%', () {
    final b = ExtraCalculators.balloon(price: 100000, down: 0, balloonPct: 30, annualRate: 12, months: 12);
    // (100000 - 30000·1.01^-12)·0.01/(1-1.01^-12) = 6,519.42
    expect(b.emi, closeTo(6519.42, 0.01));
    expect(b.balloon, 30000);
    expect(b.totalPaid, closeTo(6519.415 * 12 + 30000, 0.1));
  });

  test('mortgage 20% down', () {
    final m = ExtraCalculators.mortgage(price: 15000, downPct: 20, annualRate: 12, months: 12);
    expect(m.loan, 12000);
    expect(m.emi, closeTo(1066.19, 0.01));
  });

  test('credit card: 1,000 @24% APR paying 100/m', () {
    final c = ExtraCalculators.creditCard(balance: 1000, apr: 24, payment: 100);
    // 2%/m: m1 interest 20 -> 920, ... cleared in month 12, total interest 127.03
    expect(c.months, 12);
    expect(c.totalInterest, closeTo(127.03, 0.01));
    expect(ExtraCalculators.creditCard(balance: 1000, apr: 24, payment: 20).months, isNull);
  });

  test('due dates clamp to month end', () {
    expect(dueDate(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(dueDate(DateTime(2026, 11, 15), 2), DateTime(2027, 1, 15));
  });
}
