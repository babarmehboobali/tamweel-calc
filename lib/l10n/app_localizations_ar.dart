// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'حاسبة التمويل الشخصي والقروض';

  @override
  String get eligibilityTitle => 'الأهلية';

  @override
  String get eligibility => 'الأهلية';

  @override
  String get emi => 'القسط';

  @override
  String get compare => 'مقارنة';

  @override
  String get banks => 'البنوك';

  @override
  String get more => 'المزيد';

  @override
  String get country => 'الدولة';

  @override
  String get personal => 'شخصي';

  @override
  String get auto => 'سيارة';

  @override
  String get mortgage => 'عقاري';

  @override
  String get basicSalary => 'الراتب الأساسي';

  @override
  String get housingAllowance => 'بدل السكن';

  @override
  String get otherAllowances => 'بدلات أخرى';

  @override
  String get existingEmis => 'الأقساط الحالية';

  @override
  String get cardLimits => 'حدود البطاقات الائتمانية';

  @override
  String get annualRate => 'المعدل السنوي %';

  @override
  String get tenorMonths => 'المدة (أشهر)';

  @override
  String get maxFinancing => 'أقصى تمويل';

  @override
  String remainingEmiCapacity(String amount) {
    return 'قدرة القسط المتبقية: $amount';
  }

  @override
  String get dbrCap => 'سقف نسبة الدين';

  @override
  String get limitingFactor => 'العامل المحدد';

  @override
  String get limitingDbr => 'حد نسبة الدين';

  @override
  String get limitingSalaryMultiple => 'حد مضاعف الراتب';

  @override
  String get limitingNoCapacity => 'لا توجد قدرة متبقية';

  @override
  String get indicativeWarning => 'استرشادي – تحقق من البنك';

  @override
  String get viewSchedule => 'عرض الجدول';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get compareBanks => 'مقارنة البنوك';

  @override
  String get emiSchedule => 'القسط والجدول';

  @override
  String get monthlyEmi => 'القسط الشهري';

  @override
  String get totalProfit => 'إجمالي الربح';

  @override
  String get principal => 'الأصل';

  @override
  String get profit => 'الربح';

  @override
  String get month => 'الشهر';

  @override
  String get installment => 'القسط';

  @override
  String get balance => 'الرصيد';

  @override
  String get compareLoans => 'مقارنة العروض';

  @override
  String get totalCost => 'التكلفة الإجمالية';

  @override
  String get earlyPayoff => 'السداد المبكر';

  @override
  String get extraMonthly => 'دفعة شهرية إضافية';

  @override
  String get calculate => 'احسب';

  @override
  String get monthsSaved => 'الأشهر الموفرة';

  @override
  String get profitSaved => 'الربح الموفر';

  @override
  String get flatToApr => 'الثابت ↔ الفعلي';

  @override
  String get flatRate => 'المعدل الثابت %';

  @override
  String get reducing => 'المتناقص';

  @override
  String get years => 'السنوات';

  @override
  String get effectiveApr => 'المعدل الفعلي';

  @override
  String get murabaha => 'مرابحة';

  @override
  String get murabahaTooltip =>
      'المرابحة بيع بربح. يشتري البنك الأصل ويبيعه لك بسعر أعلى يُسدد على أقساط.';

  @override
  String get amount => 'المبلغ';

  @override
  String get profitRate => 'معدل الربح %';

  @override
  String get salePrice => 'سعر البيع';

  @override
  String get netCash => 'صافي النقد';

  @override
  String get source => 'المصدر';

  @override
  String get sharia => 'متوافق مع الشريعة';

  @override
  String get conventional => 'تقليدي';

  @override
  String get language => 'اللغة';

  @override
  String get system => 'النظام';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get islamicTerminology => 'مصطلحات إسلامية';

  @override
  String get privacyOptions => 'خيارات الخصوصية';

  @override
  String get removeAds24h => 'إزالة الإعلانات لـ ٢٤ ساعة';

  @override
  String get aboutPrivacy => 'حول والخصوصية';

  @override
  String get disclaimerFull =>
      'تقديرات فقط. ليست موافقة بنكية. الحسابات تبقى على جهازك. تحقق من البنك قبل التقدم.';

  @override
  String get privacyPolicySummary =>
      'لا نجمع ولا نرفع بياناتك المالية. قد يستخدم AdMob معرّفات الإعلان.';

  @override
  String get fontCredit =>
      'الخطوط: Cairo و Noto Naskh Arabic بموجب رخصة SIL Open Font License.';

  @override
  String get onboardingWelcome => 'خطط لتمويلك بخصوصية كاملة على الجهاز.';

  @override
  String get next => 'التالي';

  @override
  String get selectCountry => 'اختر دولتك';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get iUnderstand => 'أفهم';

  @override
  String get disclaimerShort =>
      'تقديرات فقط. ليست موافقة بنكية. تحقق من البنك.';

  @override
  String get skip => 'تخطي';

  @override
  String get useMaxEligible => 'استخدم الحد الأقصى المؤهل';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get addOffer => 'أضف عرضاً';

  @override
  String get results => 'النتائج';

  @override
  String get rateNotPublished => 'السعر غير منشور – تحقق من البنك';

  @override
  String get noBanksFound => 'لم يتم العثور على بنوك';

  @override
  String get settings => 'الإعدادات';

  @override
  String get rateUs => 'قيّمنا';

  @override
  String get aboutDisclaimer =>
      'حول وإخلاء المسؤولية: هذا التطبيق يوفر تقديرات فقط وليس مستشاراً مالياً أو بنكاً.';

  @override
  String get salarySection => 'الراتب';

  @override
  String get obligationsSection => 'الالتزامات الحالية';

  @override
  String get loanSection => 'تفاصيل التمويل';

  @override
  String get howCalculated => 'كيف تم الحساب';

  @override
  String get usedDbr => 'نسبة الاستقطاع المستخدمة';

  @override
  String howCalculatedBody(
      String cap, String income, String emi, String remaining) {
    return 'نسبة الاستقطاع المسموحة $cap% من الدخل المؤهل $income. الالتزامات الحالية $emi. المتبقي بعد الالتزامات $remaining.';
  }

  @override
  String get noBanks => 'لا توجد بنوك متاحة لهذه الدولة بعد';

  @override
  String get nationality => 'الجنسية';

  @override
  String get employerType => 'جهة العمل';

  @override
  String get selectBank => 'البنك';

  @override
  String get customDbrOptional => 'نسبة استقطاع مخصصة % (اختياري)';

  @override
  String get dbrAppliedTo => 'تُطبق النسبة على';

  @override
  String get basicSalaryOnly => 'الراتب الأساسي فقط';

  @override
  String get totalSalaryBasicHousingOther =>
      'إجمالي الراتب (أساسي + سكن + بدلات)';

  @override
  String get genericRules => 'أي بنك (قواعد البنك المركزي)';

  @override
  String get appTitle => 'حاسبة التمويل الشخصي والقروض';
}
