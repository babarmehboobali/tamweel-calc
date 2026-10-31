import 'package:flutter/material.dart';
import '../../core/engine/flat_rate.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/number_field.dart';
import '../widgets/result_card.dart';

class FlatRateScreen extends StatefulWidget {
  const FlatRateScreen({super.key});

  @override
  State<FlatRateScreen> createState() => _FlatRateScreenState();
}

class _FlatRateScreenState extends State<FlatRateScreen> {
  final _flat = TextEditingController(text: '3.0');
  final _years = TextEditingController(text: '5');
  double? apr;

  void _calc() {
    final flat = double.tryParse(_flat.text) ?? 0;
    final years = int.tryParse(_years.text) ?? 5;
    setState(() => apr = FlatRateEngine.flatToApr(100000, flat, years));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flatToApr)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          NumberField(controller: _flat, label: l10n.flatRate),
          NumberField(controller: _years, label: l10n.years),
          ElevatedButton(onPressed: _calc, child: Text(l10n.calculate)),
          if (apr != null) ResultCard(title: l10n.effectiveApr, value: '${apr!.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }
}
