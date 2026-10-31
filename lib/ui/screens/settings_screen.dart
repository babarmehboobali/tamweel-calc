import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../state/app_state.dart';
import '../../services/ads/consent_service.dart';
import 'broker_settings.dart';
import '../../l10n/app_localizations.dart';
import 'about_privacy_screen.dart';
import 'saved_calcs_screen.dart';
import '../../data/history_store.dart';
import '../../core/engine/general_mode.dart';
import '../../state/calculator_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = context.watch<AppState>();
    final consent = context.read<ConsentService>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    Widget header(String t) => Padding(padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8), child: Text(t, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          header(isAr ? 'التفضيلات' : 'Preferences'),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale?>(
              value: app.locale,
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.system)),
                const DropdownMenuItem(value: Locale('en'), child: Text('English')),
                const DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
              ],
              onChanged: (v) => app.setLocale(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: app.themeMode,
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.system)),
                DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
              ],
              onChanged: (v) => v != null ? app.setThemeMode(v) : null,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.islamicTerminology),
            value: app.islamicMode,
            onChanged: (v) => app.setIslamicMode(v),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(isAr ? 'العملة (الوضع العام)' : 'Currency (General mode)'),
            trailing: DropdownButton<String>(
              value: GeneralSettings.commonCurrencies.contains(GeneralSettings.currency) ? GeneralSettings.currency : null,
              hint: Text(GeneralSettings.currency),
              items: GeneralSettings.commonCurrencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v == null) return;
                GeneralSettings.currency = v;
                final calc = context.read<CalculatorState>();
                calc.saveGeneral();
                calc.recompute();
                (context as Element).markNeedsBuild();
              },
            ),
          ),
          if (isAr)
            SwitchListTile(
              secondary: const Icon(Icons.pin_outlined),
              title: const Text('الأرقام الهندية (١٢٣)'),
              subtitle: const Text('عرض الأرقام بالشكل ١٢٣ بدلًا من 123'),
              value: app.arabicDigits,
              onChanged: (v) => app.setArabicDigits(v),
            )
          else
            SwitchListTile(
              secondary: const Icon(Icons.pin_outlined),
              title: const Text('Arabic-Indic digits in Arabic'),
              subtitle: const Text('Show ١٢٣ instead of 123 when the app is in Arabic'),
              value: app.arabicDigits,
              onChanged: (v) => app.setArabicDigits(v),
            ),
          header(isAr ? 'البيانات المحفوظة' : 'Saved data'),
          ListTile(
            leading: const Icon(Icons.bookmarks_outlined),
            title: Text(isAr ? 'الحسابات المحفوظة' : 'Saved calculations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedCalcsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.delete_sweep_outlined, color: Theme.of(context).colorScheme.error),
            title: Text(isAr ? 'مسح البيانات المحفوظة' : 'Clear saved data'),
            subtitle: Text(isAr ? 'يحذف الحسابات المحفوظة والمدخلات لكل دولة' : 'Deletes saved calculations and per-country inputs'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isAr ? 'مسح البيانات المحفوظة؟' : 'Clear saved data?'),
                  content: Text(isAr ? 'لا يمكن التراجع عن هذا الإجراء.' : 'This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isAr ? 'مسح' : 'Clear')),
                  ],
                ),
              );
              if (ok != true) return;
              await HistoryStore.clearAll();
              final p = await SharedPreferences.getInstance();
              await p.remove('last_inputs');
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'تم مسح البيانات' : 'Saved data cleared')));
            },
          ),
          header(isAr ? 'وضع الوسيط (تقارير PDF)' : 'Broker mode (PDF reports)'),
          const BrokerSettingsTile(),
          header(isAr ? 'الخصوصية والمزيد' : 'Privacy & more'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyOptions),
            onTap: () => consent.showPrivacyOptions(),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(l10n.rateUs),
            onTap: () async {
              final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.tamweel.calculator');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutPrivacy),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPrivacyScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.tag),
            title: Text(isAr ? 'الإصدار' : 'Version'),
            trailing: const Text('1.0.0 (9)'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
