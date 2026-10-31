class RatesData {
  final int schemaVersion;
  final String updatedAt;
  final Map<String, dynamic> disclaimer;
  final Map<String, CountryBanks> countries;

  RatesData({
    required this.schemaVersion,
    required this.updatedAt,
    required this.disclaimer,
    required this.countries,
  });

  factory RatesData.fromJson(Map<String, dynamic> j) {
    final countries = <String, CountryBanks>{};
    final cMap = j['countries'] as Map<String, dynamic>? ?? {};
    cMap.forEach((k, v) {
      countries[k] = CountryBanks.fromJson(v as Map<String, dynamic>);
    });
    return RatesData(
      schemaVersion: j['schemaVersion'] ?? 1,
      updatedAt: j['updatedAt'] ?? '',
      disclaimer: j['disclaimer'] as Map<String, dynamic>? ?? {},
      countries: countries,
    );
  }
}

class CountryBanks {
  final String currency;
  final double vatPct;
  final bool verified;
  final List<Bank> banks;

  CountryBanks({required this.currency, required this.vatPct, required this.verified, required this.banks});

  factory CountryBanks.fromJson(Map<String, dynamic> j) {
    final list = (j['banks'] as List? ?? []).map((b) => Bank.fromJson(b)).toList();
    return CountryBanks(
      currency: j['currency'] ?? '',
      vatPct: (j['vatPct'] as num?)?.toDouble() ?? 15,
      verified: j['verified'] ?? false,
      banks: list,
    );
  }
}

class Bank {
  final String id;
  final Map<String, String> name;
  final bool sharia;
  final String website;
  final String? calculatorUrl;
  final String dbrBase;
  final double? personalAprMin;
  final double? personalAprMax;
  final double? maxAmount;
  final int? maxTenorMonths;
  final double? minSalary;
  final bool salaryTransferRequired;
  final double adminFeePct;
  final double? adminFeeCap;
  final bool adminFeeVatInclusive;
  final double insuranceTakafulPct;
  final int? earlySettlementFeeMonths;
  final double? earlySettlementFeePct;
  final String notes;
  final String lastVerified;
  final String source;
  final Map<String, CategoryRules>? categories;
  final bool verified;

  Bank({
    required this.id,
    this.verified = false,
    required this.name,
    required this.sharia,
    required this.website,
    this.calculatorUrl,
    this.dbrBase = 'total',
    this.personalAprMin,
    this.personalAprMax,
    this.maxAmount,
    this.maxTenorMonths,
    this.minSalary,
    required this.salaryTransferRequired,
    required this.adminFeePct,
    this.adminFeeCap,
    required this.adminFeeVatInclusive,
    required this.insuranceTakafulPct,
    this.earlySettlementFeeMonths,
    this.earlySettlementFeePct,
    required this.notes,
    required this.lastVerified,
    required this.source,
    this.categories,
  });

  factory Bank.fromJson(Map<String, dynamic> j) {
    Map<String, CategoryRules>? cats;
    if (j['categories'] is Map) {
      cats = {};
      (j['categories'] as Map).forEach((k, v) {
        cats![k.toString()] = CategoryRules.fromJson(v as Map<String, dynamic>);
      });
    }
    return Bank(
      id: j['id'] ?? '',
      name: Map<String, String>.from(j['name'] ?? {}),
      sharia: j['sharia'] ?? false,
      website: j['website'] ?? '',
      calculatorUrl: j['calculatorUrl'],
      dbrBase: j['dbrBase'] ?? 'total',
      personalAprMin: (j['personalAprMin'] as num?)?.toDouble(),
      personalAprMax: (j['personalAprMax'] as num?)?.toDouble(),
      maxAmount: (j['maxAmount'] as num?)?.toDouble(),
      maxTenorMonths: j['maxTenorMonths'],
      minSalary: (j['minSalary'] as num?)?.toDouble(),
      salaryTransferRequired: j['salaryTransferRequired'] ?? false,
      adminFeePct: (j['adminFeePct'] as num?)?.toDouble() ?? 1.0,
      adminFeeCap: (j['adminFeeCap'] as num?)?.toDouble(),
      adminFeeVatInclusive: j['adminFeeVatInclusive'] ?? false,
      insuranceTakafulPct: (j['insuranceTakafulPct'] as num?)?.toDouble() ?? 0,
      earlySettlementFeeMonths: j['earlySettlementFeeMonths'],
      earlySettlementFeePct: (j['earlySettlementFeePct'] as num?)?.toDouble(),
      notes: j['notes'] ?? '',
      lastVerified: j['lastVerified'] ?? '',
      source: j['source'] ?? '',
      categories: cats,
      verified: j['verified'] == true,
    );
  }
}

class CategoryRules {
  final double? apr;
  final double? maxAmount;
  final double? minSalary;
  final int? maxTenureMonths;
  final double? dbrCap;
  final double? salaryMultiple;
  final String salaryBase;

  CategoryRules({
    this.apr,
    this.maxAmount,
    this.minSalary,
    this.maxTenureMonths,
    this.dbrCap,
    this.salaryMultiple,
    this.salaryBase = 'total',
  });

  factory CategoryRules.fromJson(Map<String, dynamic> j) => CategoryRules(
        apr: (j['apr'] as num?)?.toDouble(),
        maxAmount: (j['maxAmount'] as num?)?.toDouble(),
        minSalary: (j['minSalary'] as num?)?.toDouble(),
        maxTenureMonths: j['maxTenureMonths'],
        dbrCap: (j['dbrCap'] as num?)?.toDouble(),
        salaryMultiple: (j['salaryMultiple'] as num?)?.toDouble(),
        salaryBase: j['salaryBase'] ?? 'total',
      );
}
