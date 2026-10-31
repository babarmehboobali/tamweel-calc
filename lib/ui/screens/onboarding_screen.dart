import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../core/engine/regulations.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _current = 0;
  Country _country = Country.ksa;
  Locale? _locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(onPressed: () => context.read<AppState>().completeOnboarding(country: _country, loc: _locale), child: Text(l10n.skip)),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _current = i),
                children: [
                  _page1(l10n),
                  _page2(l10n),
                  _page3(l10n),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Container(
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _current ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    ),
                  )),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _page1(AppLocalizations l10n) => Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFFD97706)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.trending_up, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(l10n.appName, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(l10n.onboardingWelcome, textAlign: TextAlign.center),
            const Spacer(),
            ElevatedButton(onPressed: () => _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease), child: Text(l10n.next)),
          ],
        ),
      );

  Widget _page2(AppLocalizations l10n) => Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectCountry, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...Country.values.map((c) => RadioListTile<Country>(
                  title: Text(c.name.toUpperCase()),
                  value: c,
                  groupValue: _country,
                  onChanged: (v) => setState(() => _country = v!),
                )),
            const Spacer(),
            ElevatedButton(onPressed: () => _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease), child: Text(l10n.next)),
          ],
        ),
      );

  Widget _page3(AppLocalizations l10n) => Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectLanguage, style: Theme.of(context).textTheme.titleLarge),
            RadioListTile<Locale?>(title: Text(l10n.system), value: null, groupValue: _locale, onChanged: (v) => setState(() => _locale = v)),
            RadioListTile<Locale?>(title: const Text('English'), value: const Locale('en'), groupValue: _locale, onChanged: (v) => setState(() => _locale = v)),
            RadioListTile<Locale?>(title: const Text('العربية'), value: const Locale('ar'), groupValue: _locale, onChanged: (v) => setState(() => _locale = v)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.read<AppState>().completeOnboarding(country: _country, loc: _locale),
              child: Text(l10n.getStarted),
            ),
          ],
        ),
      );
}
