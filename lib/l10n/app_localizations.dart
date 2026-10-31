import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Loan Calculator: Tamweel & EMI'**
  String get appName;

  /// No description provided for @eligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibilityTitle;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @emi.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get emi;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @banks.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get banks;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @mortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get mortgage;

  /// No description provided for @basicSalary.
  ///
  /// In en, this message translates to:
  /// **'Basic salary'**
  String get basicSalary;

  /// No description provided for @housingAllowance.
  ///
  /// In en, this message translates to:
  /// **'Housing allowance'**
  String get housingAllowance;

  /// No description provided for @otherAllowances.
  ///
  /// In en, this message translates to:
  /// **'Other allowances'**
  String get otherAllowances;

  /// No description provided for @existingEmis.
  ///
  /// In en, this message translates to:
  /// **'Existing EMIs'**
  String get existingEmis;

  /// No description provided for @cardLimits.
  ///
  /// In en, this message translates to:
  /// **'Credit card limits'**
  String get cardLimits;

  /// No description provided for @annualRate.
  ///
  /// In en, this message translates to:
  /// **'Annual rate %'**
  String get annualRate;

  /// No description provided for @tenorMonths.
  ///
  /// In en, this message translates to:
  /// **'Tenor (months)'**
  String get tenorMonths;

  /// No description provided for @maxFinancing.
  ///
  /// In en, this message translates to:
  /// **'Max financing'**
  String get maxFinancing;

  /// No description provided for @remainingEmiCapacity.
  ///
  /// In en, this message translates to:
  /// **'Remaining EMI capacity: {amount}'**
  String remainingEmiCapacity(String amount);

  /// No description provided for @dbrCap.
  ///
  /// In en, this message translates to:
  /// **'DBR cap'**
  String get dbrCap;

  /// No description provided for @limitingFactor.
  ///
  /// In en, this message translates to:
  /// **'Limiting factor'**
  String get limitingFactor;

  /// No description provided for @limitingDbr.
  ///
  /// In en, this message translates to:
  /// **'DBR limit'**
  String get limitingDbr;

  /// No description provided for @limitingSalaryMultiple.
  ///
  /// In en, this message translates to:
  /// **'Salary multiple limit'**
  String get limitingSalaryMultiple;

  /// No description provided for @limitingNoCapacity.
  ///
  /// In en, this message translates to:
  /// **'No remaining capacity'**
  String get limitingNoCapacity;

  /// No description provided for @indicativeWarning.
  ///
  /// In en, this message translates to:
  /// **'Indicative – verify with the bank'**
  String get indicativeWarning;

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View schedule'**
  String get viewSchedule;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @compareBanks.
  ///
  /// In en, this message translates to:
  /// **'Compare banks'**
  String get compareBanks;

  /// No description provided for @emiSchedule.
  ///
  /// In en, this message translates to:
  /// **'EMI & Schedule'**
  String get emiSchedule;

  /// No description provided for @monthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'Monthly EMI'**
  String get monthlyEmi;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total profit'**
  String get totalProfit;

  /// No description provided for @principal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get principal;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @installment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get installment;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @compareLoans.
  ///
  /// In en, this message translates to:
  /// **'Compare loans'**
  String get compareLoans;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get totalCost;

  /// No description provided for @earlyPayoff.
  ///
  /// In en, this message translates to:
  /// **'Early payoff'**
  String get earlyPayoff;

  /// No description provided for @extraMonthly.
  ///
  /// In en, this message translates to:
  /// **'Extra monthly payment'**
  String get extraMonthly;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @monthsSaved.
  ///
  /// In en, this message translates to:
  /// **'Months saved'**
  String get monthsSaved;

  /// No description provided for @profitSaved.
  ///
  /// In en, this message translates to:
  /// **'Profit saved'**
  String get profitSaved;

  /// No description provided for @flatToApr.
  ///
  /// In en, this message translates to:
  /// **'Flat ↔ APR'**
  String get flatToApr;

  /// No description provided for @flatRate.
  ///
  /// In en, this message translates to:
  /// **'Flat rate %'**
  String get flatRate;

  /// No description provided for @reducing.
  ///
  /// In en, this message translates to:
  /// **'Reducing'**
  String get reducing;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @effectiveApr.
  ///
  /// In en, this message translates to:
  /// **'Effective APR'**
  String get effectiveApr;

  /// No description provided for @murabaha.
  ///
  /// In en, this message translates to:
  /// **'Murabaha'**
  String get murabaha;

  /// No description provided for @murabahaTooltip.
  ///
  /// In en, this message translates to:
  /// **'Murabaha is a cost-plus sale. The bank buys the asset and sells it to you at a higher price payable in instalments.'**
  String get murabahaTooltip;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @profitRate.
  ///
  /// In en, this message translates to:
  /// **'Profit rate %'**
  String get profitRate;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get salePrice;

  /// No description provided for @netCash.
  ///
  /// In en, this message translates to:
  /// **'Net cash'**
  String get netCash;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @sharia.
  ///
  /// In en, this message translates to:
  /// **'Sharia'**
  String get sharia;

  /// No description provided for @conventional.
  ///
  /// In en, this message translates to:
  /// **'Conventional'**
  String get conventional;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @islamicTerminology.
  ///
  /// In en, this message translates to:
  /// **'Islamic terminology'**
  String get islamicTerminology;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get privacyOptions;

  /// No description provided for @removeAds24h.
  ///
  /// In en, this message translates to:
  /// **'Remove ads for 24h'**
  String get removeAds24h;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'About & Privacy'**
  String get aboutPrivacy;

  /// No description provided for @disclaimerFull.
  ///
  /// In en, this message translates to:
  /// **'Estimates only. Not a bank approval. Calculations stay on your device. Verify with your bank before applying.'**
  String get disclaimerFull;

  /// No description provided for @privacyPolicySummary.
  ///
  /// In en, this message translates to:
  /// **'We do not collect or upload your financial data. AdMob may use advertising identifiers for ads.'**
  String get privacyPolicySummary;

  /// No description provided for @fontCredit.
  ///
  /// In en, this message translates to:
  /// **'Fonts: Cairo and Noto Naskh Arabic under the SIL Open Font License.'**
  String get fontCredit;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Plan your financing with on-device privacy.'**
  String get onboardingWelcome;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectCountry;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// No description provided for @disclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'Estimates only. Not a bank approval. Verify with your bank.'**
  String get disclaimerShort;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @useMaxEligible.
  ///
  /// In en, this message translates to:
  /// **'Use max eligible'**
  String get useMaxEligible;

  /// No description provided for @offerName.
  ///
  /// In en, this message translates to:
  /// **'Offer name'**
  String get offerName;

  /// No description provided for @addOffer.
  ///
  /// In en, this message translates to:
  /// **'Add offer'**
  String get addOffer;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @rateNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Rate not published – check with bank'**
  String get rateNotPublished;

  /// No description provided for @noBanksFound.
  ///
  /// In en, this message translates to:
  /// **'No banks found'**
  String get noBanksFound;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get rateUs;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'About & disclaimer: This app provides estimates only and is not a financial advisor or bank.'**
  String get aboutDisclaimer;

  /// No description provided for @salarySection.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salarySection;

  /// No description provided for @obligationsSection.
  ///
  /// In en, this message translates to:
  /// **'Existing obligations'**
  String get obligationsSection;

  /// No description provided for @loanSection.
  ///
  /// In en, this message translates to:
  /// **'Loan details'**
  String get loanSection;

  /// No description provided for @howCalculated.
  ///
  /// In en, this message translates to:
  /// **'How we calculated'**
  String get howCalculated;

  /// No description provided for @usedDbr.
  ///
  /// In en, this message translates to:
  /// **'DBR used'**
  String get usedDbr;

  /// No description provided for @howCalculatedBody.
  ///
  /// In en, this message translates to:
  /// **'Allowed DBR {cap}% of eligible income {income}. Existing obligations {emi}. Remaining after obligations {remaining}.'**
  String howCalculatedBody(
      String cap, String income, String emi, String remaining);

  /// No description provided for @noBanks.
  ///
  /// In en, this message translates to:
  /// **'No banks available for this country yet'**
  String get noBanks;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @employerType.
  ///
  /// In en, this message translates to:
  /// **'Employer type'**
  String get employerType;

  /// No description provided for @selectBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get selectBank;

  /// No description provided for @customDbrOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom DBR % (optional)'**
  String get customDbrOptional;

  /// No description provided for @dbrAppliedTo.
  ///
  /// In en, this message translates to:
  /// **'DBR applied to'**
  String get dbrAppliedTo;

  /// No description provided for @basicSalaryOnly.
  ///
  /// In en, this message translates to:
  /// **'Basic salary only'**
  String get basicSalaryOnly;

  /// No description provided for @totalSalaryBasicHousingOther.
  ///
  /// In en, this message translates to:
  /// **'Total salary (basic + housing + other)'**
  String get totalSalaryBasicHousingOther;

  /// No description provided for @genericRules.
  ///
  /// In en, this message translates to:
  /// **'Any bank (central-bank rules)'**
  String get genericRules;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan Calculator: Tamweel & EMI'**
  String get appTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
