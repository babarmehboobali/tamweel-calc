import '../engine/regulations.dart';

class CountryModel {
  final Country country;
  final String nameEn;
  final String nameAr;
  final String currency;
  final bool isVerified;

  const CountryModel({
    required this.country,
    required this.nameEn,
    required this.nameAr,
    required this.currency,
    required this.isVerified,
  });

  static List<CountryModel> all = [
    const CountryModel(country: Country.general, nameEn: 'General / Worldwide', nameAr: 'عام / دولي', currency: '', isVerified: true),
    const CountryModel(country: Country.ksa, nameEn: 'Saudi Arabia', nameAr: 'المملكة العربية السعودية', currency: 'SAR', isVerified: true),
    const CountryModel(country: Country.uae, nameEn: 'United Arab Emirates', nameAr: 'الإمارات العربية المتحدة', currency: 'AED', isVerified: true),
    const CountryModel(country: Country.qatar, nameEn: 'Qatar', nameAr: 'قطر', currency: 'QAR', isVerified: false),
    const CountryModel(country: Country.kuwait, nameEn: 'Kuwait', nameAr: 'الكويت', currency: 'KWD', isVerified: false),
    const CountryModel(country: Country.bahrain, nameEn: 'Bahrain', nameAr: 'البحرين', currency: 'BHD', isVerified: false),
    const CountryModel(country: Country.oman, nameEn: 'Oman', nameAr: 'عُمان', currency: 'OMR', isVerified: false),
  ];

  String displayName(bool isArabic) => isArabic ? nameAr : nameEn;
}

extension CountryX on Country {
  CountryModel get _m => CountryModel.all.firstWhere((m) => m.country == this);
  String get enName => _m.nameEn;
  String get arName => _m.nameAr;
  String get jsonKey => const {
        Country.general: 'GEN', Country.ksa: 'KSA', Country.uae: 'UAE', Country.kuwait: 'KWT',
        Country.qatar: 'QAT', Country.bahrain: 'BHR', Country.oman: 'OMN',
      }[this]!;
}

const gccRegions = {'SA', 'AE', 'KW', 'QA', 'BH', 'OM'};
Country defaultCountryForRegion(String? region) {
  switch (region?.toUpperCase()) {
    case 'SA': return Country.ksa;
    case 'AE': return Country.uae;
    case 'KW': return Country.kuwait;
    case 'QA': return Country.qatar;
    case 'BH': return Country.bahrain;
    case 'OM': return Country.oman;
    default: return Country.general;
  }
}
