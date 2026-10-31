import 'package:flutter/material.dart';
import '../../core/engine/extra_calculators.dart';
import '../../core/engine/prepayment.dart';
import '../../core/engine/refinance.dart';
import '../../core/engine/reverse_calculators.dart';
import 'simple_calc_screen.dart';

const _p = CalcField('p', 'Financing amount', 'مبلغ التمويل', 200000, min: 10000, max: 2000000);
const _rate = CalcField('rate', 'Annual rate (%)', 'معدل الربح السنوي (%)', 6, min: 0, max: 30);
const _months = CalcField('n', 'Tenure (months)', 'المدة (بالأشهر)', 60, min: 6, max: 360, isInt: true);

Widget prepaymentScreen() => SimpleCalcScreen(
      titleEn: 'Prepayment & early settlement',
      titleAr: 'السداد المبكر والتسوية',
      choices: const [('Shorter tenure', 'تقليل المدة'), ('Lower instalment', 'تخفيض القسط')],
      fields: const [
        _p, _rate, _months,
        CalcField('lump', 'Lump-sum payment', 'دفعة مقطوعة', 20000, min: 0, max: 500000),
        CalcField('lm', 'Lump sum in month', 'الدفعة في الشهر رقم', 12, min: 1, max: 360, isInt: true),
        CalcField('extra', 'Extra every month', 'مبلغ إضافي شهريًا', 0, min: 0, max: 20000),
        CalcField('paid', 'Instalments paid (for settlement)', 'الأقساط المدفوعة (للتسوية)', 24, min: 0, max: 360, isInt: true),
      ],
      noteEn: 'Settlement figure is indicative: outstanding principal plus up to 3 months of future profit, per SAMA rules. Confirm with your bank.',
      noteAr: 'مبلغ التسوية تقديري: أصل المبلغ المتبقي مع أرباح ثلاثة أشهر قادمة كحد أقصى وفق تعليمات ساما. يُرجى التأكد من البنك.',
      compute: (v, choice, c) {
        final n = v['n']!.round();
        final r = PrepaymentEngine.simulate(
          principal: v['p']!, annualRate: v['rate']!, months: n,
          lumpSum: v['lump']!, lumpMonth: v['lm']!.round(), recurringExtra: v['extra']!,
          mode: choice == 0 ? PrepayMode.reduceTenure : PrepayMode.reduceEmi,
        );
        final s = PrepaymentEngine.samaSettlement(principal: v['p']!, annualRate: v['rate']!, months: n, paidMonths: v['paid']!.round());
        return [
          CalcOut(c.t('Current instalment', 'القسط الحالي'), c.m(r.baseEmi)),
          if (choice == 1) CalcOut(c.t('New instalment', 'القسط الجديد'), c.m(r.finalEmi), highlight: true),
          CalcOut(c.t('New tenure', 'المدة الجديدة'), '${c.n(r.newMonths)} ${c.t('months', 'شهرًا')}'),
          CalcOut(c.t('Months saved', 'الأشهر الموفَّرة'), c.n(r.monthsSaved), highlight: choice == 0),
          CalcOut(c.t('Profit saved', 'الأرباح الموفَّرة'), c.m(r.interestSaved), highlight: true),
          CalcOut(c.t('Settlement amount (indicative)', 'مبلغ التسوية (تقديري)'), c.m(s.payoff), highlight: true),
          CalcOut(c.t('Profit rebate', 'الأرباح المُعفاة'), c.m(s.rebate)),
        ];
      },
    );

Widget reverseScreen() => SimpleCalcScreen(
      titleEn: 'Reverse calculators',
      titleAr: 'الحاسبات العكسية',
      fields: const [
        CalcField('emi', 'Target monthly instalment', 'القسط الشهري المستهدف', 4000, min: 500, max: 30000),
        _rate, _months,
        CalcField('p', 'Loan amount (for tenure & rate)', 'مبلغ التمويل (للمدة والمعدل)', 200000, min: 10000, max: 2000000),
      ],
      compute: (v, _, c) {
        final maxP = ReverseCalculators.maxPrincipalForEmi(emi: v['emi']!, annualRate: v['rate']!, months: v['n']!.round());
        final m = ReverseCalculators.monthsForEmi(principal: v['p']!, emi: v['emi']!, annualRate: v['rate']!);
        final rate = ReverseCalculators.rateFromEmi(principal: v['p']!, emi: v['emi']!, months: v['n']!.round());
        return [
          CalcOut(c.t('Max loan for this instalment', 'أقصى تمويل لهذا القسط'), c.m(maxP), highlight: true),
          CalcOut(c.t('Tenure needed', 'المدة اللازمة'),
              m == null ? c.t('Instalment too low', 'القسط منخفض جدًا') : '${c.n(m)} ${c.t('months', 'شهرًا')}', highlight: true),
          CalcOut(c.t('Implied annual rate', 'المعدل السنوي الضمني'), rate == null ? '—' : c.pct(rate), highlight: true),
        ];
      },
    );

Widget refinanceScreen() => SimpleCalcScreen(
      titleEn: 'Refinance / buy-out',
      titleAr: 'إعادة التمويل / الشراء',
      fields: const [
        CalcField('o1', 'Loan 1 outstanding', 'المتبقي من التمويل 1', 120000),
        CalcField('e1', 'Loan 1 instalment', 'قسط التمويل 1', 3000),
        CalcField('m1', 'Loan 1 months left', 'الأشهر المتبقية للتمويل 1', 48, isInt: true),
        CalcField('o2', 'Loan 2 outstanding (card/other)', 'المتبقي من التمويل 2 (بطاقة/أخرى)', 0),
        CalcField('e2', 'Loan 2 instalment', 'قسط التمويل 2', 0),
        CalcField('m2', 'Loan 2 months left', 'الأشهر المتبقية للتمويل 2', 0, isInt: true),
        CalcField('np', 'New financing amount', 'مبلغ التمويل الجديد', 200000, min: 10000, max: 2000000),
        _rate, _months,
        CalcField('fee', 'Admin fee (%)', 'الرسوم الإدارية (%)', 1),
        CalcField('vat', 'VAT on fee (%)', 'ضريبة القيمة المضافة على الرسوم (%)', 15),
      ],
      noteEn: 'Savings = remaining payments on old loans − (new loan payments − cash in hand). Indicative only.',
      noteAr: 'الوفر = الدفعات المتبقية على التمويلات الحالية − (دفعات التمويل الجديد − النقد المتبقي). تقديري فقط.',
      compute: (v, _, c) {
        final r = RefinanceEngine.calculate(
          existing: [
            ExistingLoan(outstanding: v['o1']!, emi: v['e1']!, remainingMonths: v['m1']!.round()),
            if (v['o2']! > 0) ExistingLoan(outstanding: v['o2']!, emi: v['e2']!, remainingMonths: v['m2']!.round()),
          ],
          newPrincipal: v['np']!, newAnnualRate: v['rate']!, newMonths: v['n']!.round(),
          adminFeePct: v['fee']!, adminFeeCap: 5000, vatPct: v['vat']!,
        );
        return [
          CalcOut(c.t('Current total instalment', 'إجمالي الأقساط الحالية'), c.m(r.oldEmi)),
          CalcOut(c.t('New instalment', 'القسط الجديد'), c.m(r.newEmi), highlight: true),
          CalcOut(c.t('Buy-out amount', 'مبلغ الشراء (السداد)'), c.m(r.payoffTotal)),
          CalcOut(c.t('Fees incl. VAT', 'الرسوم مع الضريبة'), c.m(r.fee)),
          CalcOut(c.t('Cash in hand', 'النقد المتبقي لك'), c.m(r.cashInHand), highlight: true),
          CalcOut(c.t('Overall savings', 'إجمالي الوفر'), c.m(r.savings), highlight: true),
        ];
      },
    );

Widget mortgageScreen() => SimpleCalcScreen(
      titleEn: 'Home finance (down payment)',
      titleAr: 'التمويل العقاري (الدفعة الأولى)',
      fields: const [
        CalcField('price', 'Property price', 'سعر العقار', 1000000, min: 100000, max: 10000000),
        CalcField('down', 'Down payment (%)', 'الدفعة الأولى (%)', 10, min: 0, max: 90),
        CalcField('rate', 'Annual rate (%)', 'معدل الربح السنوي (%)', 5, min: 0, max: 20),
        CalcField('n', 'Tenure (months)', 'المدة (بالأشهر)', 300, min: 12, max: 360, isInt: true),
      ],
      compute: (v, _, c) {
        final r = ExtraCalculators.mortgage(price: v['price']!, downPct: v['down']!, annualRate: v['rate']!, months: v['n']!.round());
        return [
          CalcOut(c.t('Down payment', 'الدفعة الأولى'), c.m(r.down)),
          CalcOut(c.t('Financing amount', 'مبلغ التمويل'), c.m(r.loan)),
          CalcOut(c.t('Monthly instalment', 'القسط الشهري'), c.m(r.emi), highlight: true),
          CalcOut(c.t('Total profit', 'إجمالي الأرباح'), c.m(r.totalProfit)),
          CalcOut(c.t('Total paid', 'إجمالي المدفوع'), c.m(r.totalPaid)),
        ];
      },
    );

Widget balloonScreen() => SimpleCalcScreen(
      titleEn: 'Car finance (balloon)',
      titleAr: 'تمويل السيارات (الدفعة الأخيرة)',
      fields: const [
        CalcField('price', 'Car price', 'سعر السيارة', 120000, min: 20000, max: 1000000),
        CalcField('down', 'Down payment', 'الدفعة الأولى', 0, min: 0, max: 500000),
        CalcField('b', 'Balloon / final payment (% of price)', 'الدفعة الأخيرة (% من السعر)', 30, min: 0, max: 60),
        CalcField('rate', 'Annual rate (%)', 'معدل الربح السنوي (%)', 6, min: 0, max: 20),
        CalcField('n', 'Tenure (months)', 'المدة (بالأشهر)', 60, min: 12, max: 84, isInt: true),
      ],
      compute: (v, _, c) {
        final r = ExtraCalculators.balloon(price: v['price']!, down: v['down']!, balloonPct: v['b']!, annualRate: v['rate']!, months: v['n']!.round());
        return [
          CalcOut(c.t('Monthly instalment', 'القسط الشهري'), c.m(r.emi), highlight: true),
          CalcOut(c.t('Final (balloon) payment', 'الدفعة الأخيرة'), c.m(r.balloon)),
          CalcOut(c.t('Total profit', 'إجمالي الأرباح'), c.m(r.totalProfit)),
          CalcOut(c.t('Total paid', 'إجمالي المدفوع'), c.m(r.totalPaid)),
        ];
      },
    );

Widget creditCardScreen() => SimpleCalcScreen(
      titleEn: 'Credit card payoff',
      titleAr: 'سداد البطاقة الائتمانية',
      fields: const [
        CalcField('bal', 'Card balance', 'رصيد البطاقة', 10000, min: 500, max: 100000),
        CalcField('apr', 'Annual rate (%)', 'المعدل السنوي (%)', 30, min: 0, max: 60),
        CalcField('pay', 'Monthly payment', 'الدفعة الشهرية', 1000, min: 50, max: 20000),
      ],
      compute: (v, _, c) {
        final r = ExtraCalculators.creditCard(balance: v['bal']!, apr: v['apr']!, payment: v['pay']!);
        if (r.months == null) {
          return [CalcOut(c.t('Result', 'النتيجة'), c.t('Payment does not cover the monthly charge', 'الدفعة لا تغطي الرسوم الشهرية'), highlight: true)];
        }
        final now = DateTime.now();
        final d = dueDate(DateTime(now.year, now.month, 1), r.months!);
        return [
          CalcOut(c.t('Months to pay off', 'أشهر السداد'), c.n(r.months!), highlight: true),
          CalcOut(c.t('Debt-free by', 'خالٍ من الدين في'), '${c.n(d.month)}/${c.n(d.year, 0).replaceAll(',', '')}'),
          CalcOut(c.t('Total interest', 'إجمالي الفوائد'), c.m(r.totalInterest), highlight: true),
          CalcOut(c.t('Total paid', 'إجمالي المدفوع'), c.m(r.totalPaid)),
        ];
      },
    );
