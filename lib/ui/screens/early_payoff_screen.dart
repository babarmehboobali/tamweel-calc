import 'package:flutter/material.dart';
import '../../core/engine/early_payoff.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/number_field.dart';
import '../widgets/result_card.dart';

class EarlyPayoffScreen extends StatefulWidget {
  const EarlyPayoffScreen({super.key});

  @override
  State<EarlyPayoffScreen> createState() => _EarlyPayoffScreenState();
}

class _EarlyPayoffScreenState extends State<EarlyPayoffScreen> {
  final _extra = TextEditingController(text: '500');
  EarlyPayoffResult? result;

  void _calc() {
    final extra = double.tryParse(_extra.text) ?? 0;
    setState(() {
      result = EarlyPayoffEngine.simulate(principal: 100000, annualRate: 6, originalMonths: 60, extraMonthly: extra);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.earlyPayoff)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          NumberField(controller: _extra, label: l10n.extraMonthly),
          ElevatedButton(onPressed: _calc, child: Text(l10n.calculate)),
          if (result != null) ...[
            ResultCard(title: l10n.monthsSaved, value: result!.monthsSaved.toString()),
            ResultCard(title: l10n.profitSaved, value: result!.profitSaved.toStringAsFixed(2)),
          ],
        ],
      ),
    );
  }
}
