import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'eligibility_screen.dart';
import 'emi_schedule_screen.dart';
import 'compare_loans_screen.dart';
import 'banks_screen.dart';
import 'early_payoff_screen.dart';
import 'flat_rate_screen.dart';
import 'murabaha_screen.dart';
import 'about_privacy_screen.dart';
import 'settings_screen.dart';
import 'saved_calcs_screen.dart';
import 'loan_tracker_screen.dart';
import 'r7_calculators.dart';
import '../widgets/adaptive_banner_wrapper.dart';
import '../widgets/motion.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ads/ad_service.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;

  void _maybeInterstitial() {
    final ads = context.read<AdService>();
    if (ads.canShowInterstitial()) {
      ads.showInterstitial(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      const EligibilityScreen(),
      const EmiScheduleScreen(),
      const CompareLoansScreen(),
      const BanksScreen(),
      _MoreTab(onAction: _maybeInterstitial),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: motion(context, const Duration(milliseconds: 260)),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(a), child: child),
              ),
              child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
            ),
          ),
          const AdaptiveBannerWrapper(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          tapHaptic();
          final ads = context.read<AdService>();
          // Tabs 0-2 show results: never an interstitial on them or right after leaving them.
          if (_index <= 2) ads.markResultViewed();
          setState(() => _index = i);
          if (i >= 3) _maybeInterstitial();
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.calculate_outlined), selectedIcon: const Icon(Icons.calculate), label: l10n.eligibility),
          NavigationDestination(icon: const Icon(Icons.table_chart_outlined), selectedIcon: const Icon(Icons.table_chart), label: l10n.emi),
          NavigationDestination(icon: const Icon(Icons.compare), label: l10n.compare),
          NavigationDestination(icon: const Icon(Icons.account_balance_outlined), selectedIcon: const Icon(Icons.account_balance), label: l10n.banks),
          NavigationDestination(icon: const Icon(Icons.more_horiz), label: l10n.more),
        ],
      ),
    );
  }
}

class _MoreTab extends StatelessWidget {
  final VoidCallback onAction;
  const _MoreTab({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final tiles = [
      (Icons.bookmarks_outlined, Localizations.localeOf(context).languageCode == 'ar' ? 'الحسابات المحفوظة' : 'Saved calculations', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedCalcsScreen()))),
      (Icons.event_available, ar ? 'متابعة التمويل' : 'Loan tracker', () => go(const LoanTrackerScreen())),
      (Icons.savings_outlined, ar ? 'السداد المبكر والتسوية' : 'Prepayment & settlement', () => go(prepaymentScreen())),
      (Icons.u_turn_left, ar ? 'الحاسبات العكسية' : 'Reverse calculators', () => go(reverseScreen())),
      (Icons.sync_alt, ar ? 'إعادة التمويل / الشراء' : 'Refinance / buy-out', () => go(refinanceScreen())),
      (Icons.home_work_outlined, ar ? 'التمويل العقاري' : 'Home finance', () => go(mortgageScreen())),
      (Icons.directions_car_outlined, ar ? 'تمويل السيارات (دفعة أخيرة)' : 'Car finance (balloon)', () => go(balloonScreen())),
      (Icons.credit_card, ar ? 'سداد البطاقة الائتمانية' : 'Credit card payoff', () => go(creditCardScreen())),
      (Icons.speed, l10n.earlyPayoff, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarlyPayoffScreen()))),
      (Icons.swap_horiz, l10n.flatToApr, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlatRateScreen()))),
      (Icons.account_balance_wallet, l10n.murabaha, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MurabahaScreen()))),
      (Icons.info_outline, l10n.aboutPrivacy, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPrivacyScreen()))),
      (Icons.settings, l10n.settings, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ];

    final cs = Theme.of(context).colorScheme;
    const grads = [
      [Color(0xFF0F766E), Color(0xFF14B8A6)], [Color(0xFF1D4ED8), Color(0xFF60A5FA)], [Color(0xFFB45309), Color(0xFFF59E0B)],
      [Color(0xFF7C3AED), Color(0xFFA78BFA)], [Color(0xFFBE123C), Color(0xFFFB7185)], [Color(0xFF047857), Color(0xFF34D399)],
    ];
    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth > 560 ? 3 : 2;
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      return GridView.builder(
        padding: const EdgeInsetsDirectional.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: textScale > 1.2 ? 0.85 : 1.05,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, i) {
          final t = tiles[i];
          final g = grads[i % grads.length];
          return StaggerIn(
            index: i,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Pressable(
                onTap: () => t.$3(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(colors: g, begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd),
                          boxShadow: [BoxShadow(color: g[0].withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Icon(t.$1, size: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(t.$2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
