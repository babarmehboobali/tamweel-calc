// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Loan Calculator: Tamweel & EMI';

  @override
  String get eligibilityTitle => 'Eligibility';

  @override
  String get eligibility => 'Eligibility';

  @override
  String get emi => 'EMI';

  @override
  String get compare => 'Compare';

  @override
  String get banks => 'Banks';

  @override
  String get more => 'More';

  @override
  String get country => 'Country';

  @override
  String get personal => 'Personal';

  @override
  String get auto => 'Auto';

  @override
  String get mortgage => 'Mortgage';

  @override
  String get basicSalary => 'Basic salary';

  @override
  String get housingAllowance => 'Housing allowance';

  @override
  String get otherAllowances => 'Other allowances';

  @override
  String get existingEmis => 'Existing EMIs';

  @override
  String get cardLimits => 'Credit card limits';

  @override
  String get annualRate => 'Annual rate %';

  @override
  String get tenorMonths => 'Tenor (months)';

  @override
  String get maxFinancing => 'Max financing';

  @override
  String remainingEmiCapacity(String amount) {
    return 'Remaining EMI capacity: $amount';
  }

  @override
  String get dbrCap => 'DBR cap';

  @override
  String get limitingFactor => 'Limiting factor';

  @override
  String get limitingDbr => 'DBR limit';

  @override
  String get limitingSalaryMultiple => 'Salary multiple limit';

  @override
  String get limitingNoCapacity => 'No remaining capacity';

  @override
  String get indicativeWarning => 'Indicative – verify with the bank';

  @override
  String get viewSchedule => 'View schedule';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get compareBanks => 'Compare banks';

  @override
  String get emiSchedule => 'EMI & Schedule';

  @override
  String get monthlyEmi => 'Monthly EMI';

  @override
  String get totalProfit => 'Total profit';

  @override
  String get principal => 'Principal';

  @override
  String get profit => 'Profit';

  @override
  String get month => 'Month';

  @override
  String get installment => 'Installment';

  @override
  String get balance => 'Balance';

  @override
  String get compareLoans => 'Compare loans';

  @override
  String get totalCost => 'Total cost';

  @override
  String get earlyPayoff => 'Early payoff';

  @override
  String get extraMonthly => 'Extra monthly payment';

  @override
  String get calculate => 'Calculate';

  @override
  String get monthsSaved => 'Months saved';

  @override
  String get profitSaved => 'Profit saved';

  @override
  String get flatToApr => 'Flat ↔ APR';

  @override
  String get flatRate => 'Flat rate %';

  @override
  String get reducing => 'Reducing';

  @override
  String get years => 'Years';

  @override
  String get effectiveApr => 'Effective APR';

  @override
  String get murabaha => 'Murabaha';

  @override
  String get murabahaTooltip =>
      'Murabaha is a cost-plus sale. The bank buys the asset and sells it to you at a higher price payable in instalments.';

  @override
  String get amount => 'Amount';

  @override
  String get profitRate => 'Profit rate %';

  @override
  String get salePrice => 'Sale price';

  @override
  String get netCash => 'Net cash';

  @override
  String get source => 'Source';

  @override
  String get sharia => 'Sharia';

  @override
  String get conventional => 'Conventional';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get islamicTerminology => 'Islamic terminology';

  @override
  String get privacyOptions => 'Privacy options';

  @override
  String get removeAds24h => 'Remove ads for 24h';

  @override
  String get aboutPrivacy => 'About & Privacy';

  @override
  String get disclaimerFull =>
      'Estimates only. Not a bank approval. Calculations stay on your device. Verify with your bank before applying.';

  @override
  String get privacyPolicySummary =>
      'We do not collect or upload your financial data. AdMob may use advertising identifiers for ads.';

  @override
  String get fontCredit =>
      'Fonts: Cairo and Noto Naskh Arabic under the SIL Open Font License.';

  @override
  String get onboardingWelcome => 'Plan your financing with on-device privacy.';

  @override
  String get next => 'Next';

  @override
  String get selectCountry => 'Select your country';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get getStarted => 'Get started';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get disclaimerShort =>
      'Estimates only. Not a bank approval. Verify with your bank.';

  @override
  String get skip => 'Skip';

  @override
  String get useMaxEligible => 'Use max eligible';

  @override
  String get offerName => 'Offer name';

  @override
  String get addOffer => 'Add offer';

  @override
  String get results => 'Results';

  @override
  String get rateNotPublished => 'Rate not published – check with bank';

  @override
  String get noBanksFound => 'No banks found';

  @override
  String get settings => 'Settings';

  @override
  String get rateUs => 'Rate us';

  @override
  String get aboutDisclaimer =>
      'About & disclaimer: This app provides estimates only and is not a financial advisor or bank.';

  @override
  String get salarySection => 'Salary';

  @override
  String get obligationsSection => 'Existing obligations';

  @override
  String get loanSection => 'Loan details';

  @override
  String get howCalculated => 'How we calculated';

  @override
  String get usedDbr => 'DBR used';

  @override
  String howCalculatedBody(
      String cap, String income, String emi, String remaining) {
    return 'Allowed DBR $cap% of eligible income $income. Existing obligations $emi. Remaining after obligations $remaining.';
  }

  @override
  String get noBanks => 'No banks available for this country yet';

  @override
  String get nationality => 'Nationality';

  @override
  String get employerType => 'Employer type';

  @override
  String get selectBank => 'Bank';

  @override
  String get customDbrOptional => 'Custom DBR % (optional)';

  @override
  String get dbrAppliedTo => 'DBR applied to';

  @override
  String get basicSalaryOnly => 'Basic salary only';

  @override
  String get totalSalaryBasicHousingOther =>
      'Total salary (basic + housing + other)';

  @override
  String get genericRules => 'Any bank (central-bank rules)';

  @override
  String get appTitle => 'Loan Calculator: Tamweel & EMI';
}
