class BankRate {
  final String id;
  final String nameEn;
  final String nameAr;
  final double? personalAprMin;
  final double? personalAprMax;
  final double? mortgageAprMin;
  final double? mortgageAprMax;
  final double adminFeePct;
  final double? adminFeeCap;
  final int maxTenorMonths;
  final double? minSalary;
  final bool sharia;
  final String website;
  final bool indicative;

  const BankRate({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.personalAprMin,
    this.personalAprMax,
    this.mortgageAprMin,
    this.mortgageAprMax,
    required this.adminFeePct,
    this.adminFeeCap,
    required this.maxTenorMonths,
    this.minSalary,
    required this.sharia,
    required this.website,
    required this.indicative,
  });

  factory BankRate.fromJson(Map<String, dynamic> j) {
    return BankRate(
      id: j['id'] as String,
      nameEn: (j['name'] as Map)['en'] as String,
      nameAr: (j['name'] as Map)['ar'] as String,
      personalAprMin: (j['personalAprMin'] as num?)?.toDouble(),
      personalAprMax: (j['personalAprMax'] as num?)?.toDouble(),
      mortgageAprMin: (j['mortgageAprMin'] as num?)?.toDouble(),
      mortgageAprMax: (j['mortgageAprMax'] as num?)?.toDouble(),
      adminFeePct: (j['adminFeePct'] as num).toDouble(),
      adminFeeCap: (j['adminFeeCap'] as num?)?.toDouble(),
      maxTenorMonths: j['maxTenorMonths'] as int,
      minSalary: (j['minSalary'] as num?)?.toDouble(),
      sharia: j['sharia'] as bool,
      website: j['website'] as String,
      indicative: j['indicative'] as bool? ?? true,
    );
  }
}
