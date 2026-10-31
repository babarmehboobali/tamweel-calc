import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/engine/regulations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/number_parser.dart';
import '../../data/tracker_store.dart';
import '../../services/notifications/notification_service.dart';
import '../../state/calculator_state.dart';
import '../widgets/number_field.dart';

bool _isAr(BuildContext c) => Localizations.localeOf(c).languageCode == 'ar';
String _cur(BuildContext c) {
  final calc = c.read<CalculatorState?>();
  return calc == null ? 'SAR' : RegulationRules.forCountry(calc.inputs.country).currency;
}

String _date(BuildContext c, DateTime d) =>
    Formatters.digits(DateFormat('d MMM yyyy', _isAr(c) ? 'ar' : 'en').format(d), isArabic: _isAr(c));

Future<void> scheduleReminder(TrackedLoan l, {required bool ar}) async {
  await NotificationService.cancel(l.notificationId);
  final k = l.nextUnpaid;
  if (k == null || l.reminderDays <= 0) return;
  final d = l.due(k);
  final when = DateTime(d.year, d.month, d.day, 10).subtract(Duration(days: l.reminderDays));
  await NotificationService.schedule(
    id: l.notificationId,
    when: when,
    title: ar ? 'تذكير بالقسط: ${l.name}' : 'Instalment reminder: ${l.name}',
    body: ar ? 'القسط رقم $k مستحق بعد ${l.reminderDays} أيام' : 'Instalment #$k is due in ${l.reminderDays} days',
  );
}

class LoanTrackerScreen extends StatefulWidget {
  const LoanTrackerScreen({super.key});
  @override
  State<LoanTrackerScreen> createState() => _LoanTrackerScreenState();
}

class _LoanTrackerScreenState extends State<LoanTrackerScreen> {
  final _store = TrackerStore();
  List<TrackedLoan> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final l = await _store.list();
    if (mounted) setState(() {
      _loans = l;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final ar = _isAr(context);
    final loan = await showDialog<TrackedLoan>(context: context, builder: (_) => const _AddLoanDialog());
    if (loan == null) return;
    _loans.add(loan);
    await _store.saveAll(_loans);
    final ok = await NotificationService.requestPermission();
    await scheduleReminder(loan, ar: ar);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ar ? 'لن تصلك التذكيرات حتى تسمح بالإشعارات من الإعدادات' : 'Reminders are off until you allow notifications in Settings')));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isAr(context);
    final cur = _cur(context);
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'متابعة التمويل' : 'Loan tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add, icon: const Icon(Icons.add), label: Text(ar ? 'إضافة تمويل' : 'Add loan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(ar ? 'أضف تمويلك لمتابعة الأقساط والتذكير بمواعيدها' : 'Add your loan to track instalments and get due-date reminders',
                      textAlign: TextAlign.center)))
              : ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 96),
                  children: [
                    for (final l in _loans)
                      Card(
                        child: ListTile(
                          title: Text(l.name),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 6),
                            LinearProgressIndicator(value: l.progress),
                            const SizedBox(height: 6),
                            Text('${ar ? 'المتبقي' : 'Remaining'}: ${Formatters.currency(l.remainingBalance, cur, isArabic: ar)}'),
                            if (l.nextUnpaid != null)
                              Text('${ar ? 'القسط القادم' : 'Next due'}: ${_date(context, l.due(l.nextUnpaid!))}'),
                          ]),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => _LoanDetail(loan: l, all: _loans, store: _store)));
                            _reload();
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _AddLoanDialog extends StatefulWidget {
  const _AddLoanDialog();
  @override
  State<_AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<_AddLoanDialog> {
  final _name = TextEditingController();
  final _p = TextEditingController(text: '200000');
  final _r = TextEditingController(text: '6');
  final _n = TextEditingController(text: '60');
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month + 1, 27);

  @override
  Widget build(BuildContext context) {
    final ar = _isAr(context);
    return AlertDialog(
      title: Text(ar ? 'تمويل جديد' : 'New loan'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _name, decoration: InputDecoration(labelText: ar ? 'الاسم (مثل: تمويل شخصي)' : 'Name (e.g. Personal loan)')),
          const SizedBox(height: 12),
          NumberField(controller: _p, label: ar ? 'مبلغ التمويل' : 'Financing amount'),
          NumberField(controller: _r, label: ar ? 'معدل الربح السنوي (%)' : 'Annual rate (%)'),
          NumberField(controller: _n, label: ar ? 'المدة (بالأشهر)' : 'Tenure (months)'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(ar ? 'تاريخ أول قسط' : 'First due date'),
            subtitle: Text(_date(context, _start)),
            trailing: const Icon(Icons.event),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d != null) setState(() => _start = d);
            },
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(ar ? 'إلغاء' : 'Cancel')),
        FilledButton(
          onPressed: () {
            final p = NumberParser.parse(_p.text) ?? 0, r = NumberParser.parse(_r.text) ?? 0;
            final n = (NumberParser.parse(_n.text) ?? 0).round();
            if (p <= 0 || n <= 0) return;
            Navigator.pop(context, TrackedLoan(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: _name.text.trim().isEmpty ? (ar ? 'تمويلي' : 'My loan') : _name.text.trim(),
              principal: p, rate: r, months: n, start: _start));
          },
          child: Text(ar ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
}

class _LoanDetail extends StatefulWidget {
  final TrackedLoan loan;
  final List<TrackedLoan> all;
  final TrackerStore store;
  const _LoanDetail({required this.loan, required this.all, required this.store});
  @override
  State<_LoanDetail> createState() => _LoanDetailState();
}

class _LoanDetailState extends State<_LoanDetail> {
  Future<void> _persist() async {
    await widget.store.saveAll(widget.all);
    if (mounted) await scheduleReminder(widget.loan, ar: _isAr(context));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isAr(context);
    final cur = _cur(context);
    final l = widget.loan;
    final rows = l.schedule;
    String m(double v) => Formatters.currency(v, cur, isArabic: ar);
    return Scaffold(
      appBar: AppBar(title: Text(l.name), actions: [
        IconButton(
          tooltip: ar ? 'حذف' : 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            widget.all.removeWhere((x) => x.id == l.id);
            await NotificationService.cancel(l.notificationId);
            await widget.store.saveAll(widget.all);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ]),
      body: ListView(padding: const EdgeInsetsDirectional.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${ar ? 'القسط الشهري' : 'Monthly instalment'}: ${m(l.emi)}'),
              Text('${ar ? 'الرصيد المتبقي' : 'Remaining balance'}: ${m(l.remainingBalance)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: l.progress, minHeight: 8),
              const SizedBox(height: 4),
              Text(Formatters.digits('${l.paid.length} / ${l.months} ${ar ? 'قسط مدفوع' : 'paid'}', isArabic: ar)),
              Text('${ar ? 'تاريخ السداد النهائي' : 'Payoff date'}: ${_date(context, l.due(l.months))}'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text(ar ? 'التذكير قبل الاستحقاق' : 'Remind me before due')),
                DropdownButton<int>(
                  value: l.reminderDays,
                  items: [0, 1, 3, 7].map((d) => DropdownMenuItem(value: d,
                      child: Text(d == 0 ? (ar ? 'إيقاف' : 'Off') : Formatters.digits(ar ? '$d يوم' : '$d days', isArabic: ar)))).toList(),
                  onChanged: (d) async {
                    l.reminderDays = d ?? 0;
                    if (l.reminderDays > 0) await NotificationService.requestPermission();
                    await _persist();
                  },
                ),
              ]),
            ]),
          ),
        ),
        for (final r in rows)
          CheckboxListTile(
            dense: true,
            value: l.paid.contains(r.month),
            onChanged: (v) {
              // Marking k paid marks all earlier ones; unmarking k unmarks all later ones.
              if (v == true) {
                for (var k = 1; k <= r.month; k++) {
                  l.paid.add(k);
                }
              } else {
                l.paid.removeWhere((k) => k >= r.month);
              }
              _persist();
            },
            title: Text(Formatters.digits('#${r.month} · ${_date(context, l.due(r.month))}', isArabic: ar)),
            subtitle: Text('${m(r.installment)} · ${ar ? 'الرصيد' : 'bal.'} ${m(r.closing)}'),
          ),
      ]),
    );
  }
}
