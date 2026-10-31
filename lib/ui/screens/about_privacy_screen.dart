import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutPrivacy)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Text(l10n.appName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(l10n.disclaimerFull),
          const SizedBox(height: 16),
          Text(l10n.privacyPolicySummary),
          const SizedBox(height: 16),
          Text(l10n.fontCredit),
          const SizedBox(height: 16),
          Text(l10n.aboutDisclaimer),
        ],
      ),
    );
  }
}
