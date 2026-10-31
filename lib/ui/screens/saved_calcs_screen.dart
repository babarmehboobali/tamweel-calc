import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/history_store.dart';
import '../../state/calculator_state.dart';

class SavedCalcsScreen extends StatefulWidget {
  const SavedCalcsScreen({super.key});
  @override
  State<SavedCalcsScreen> createState() => _SavedCalcsScreenState();
}

class _SavedCalcsScreenState extends State<SavedCalcsScreen> {
  List<SavedCalc>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryStore.list();
    if (mounted) setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'الحسابات المحفوظة' : 'Saved calculations')),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.bookmark_border, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(isAr ? 'لا توجد حسابات محفوظة بعد. احفظ من شاشة الأهلية.' : 'No saved calculations yet. Save one from the Eligibility screen.', textAlign: TextAlign.center),
                    ]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final c = items[i];
                    return Card(
                      child: ListTile(
                        title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text([DateFormat.yMMMd(isAr ? 'ar' : 'en').add_jm().format(c.date), ...c.results.entries.map((e) => '${e.key}: ${e.value}')].join('\n')),
                        isThreeLine: true,
                        onTap: () {
                          context.read<CalculatorState>().restore(c.inputs);
                          Navigator.pop(context, true);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: isAr ? 'حذف' : 'Delete',
                          onPressed: () async {
                            await HistoryStore.delete(c.id);
                            _load();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
