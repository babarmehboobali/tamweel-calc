import 'money.dart';

class MurabahaResult {
  final double commodityCost;
  final double bankProfit;
  final double salePrice;
  final double installment;
  final double adminFee;
  final double vatOnFee;
  final double netCash;

  const MurabahaResult({
    required this.commodityCost,
    required this.bankProfit,
    required this.salePrice,
    required this.installment,
    required this.adminFee,
    required this.vatOnFee,
    required this.netCash,
  });
}

class MurabahaEngine {
  static MurabahaResult calculate({
    required double financedAmount,
    required double annualProfitRate,
    required int months,
    required double adminFeePct,
    required double vatPct,
  }) {
    final totalProfit = financedAmount * (annualProfitRate / 100) * (months / 12);
    final salePrice = financedAmount + totalProfit;
    final installment = salePrice / months;
    final adminFee = financedAmount * (adminFeePct / 100);
    final vat = adminFee * (vatPct / 100);
    final netCash = financedAmount - adminFee - vat;

    return MurabahaResult(
      commodityCost: Money.round2(financedAmount),
      bankProfit: Money.round2(totalProfit),
      salePrice: Money.round2(salePrice),
      installment: Money.round2(installment),
      adminFee: Money.round2(adminFee),
      vatOnFee: Money.round2(vat),
      netCash: Money.round2(netCash),
    );
  }
}
