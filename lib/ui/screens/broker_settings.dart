import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/broker_store.dart';

class BrokerSettingsTile extends StatefulWidget {
  const BrokerSettingsTile({super.key});
  @override
  State<BrokerSettingsTile> createState() => _BrokerSettingsTileState();
}

class _BrokerSettingsTileState extends State<BrokerSettingsTile> {
  BrokerProfile _b = const BrokerProfile();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    BrokerStore.load().then((b) {
      if (!mounted) return;
      setState(() => _b = b);
      _name.text = b.name;
      _phone.text = b.phone;
    });
  }

  Future<void> _save(BrokerProfile b) async {
    setState(() => _b = b);
    await BrokerStore.save(b);
  }

  Future<void> _pickLogo() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final f = await File(x.path).copy('${dir.path}/broker_logo_${DateTime.now().millisecondsSinceEpoch}${x.path.contains('.png') ? '.png' : '.jpg'}');
    await _save(_b.copyWith(logoPath: f.path));
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Column(children: [
      SwitchListTile(
        secondary: const Icon(Icons.badge_outlined),
        title: Text(ar ? 'إظهار بياناتي في رأس التقرير' : 'Show my details in the PDF header'),
        value: _b.enabled,
        onChanged: (v) => _save(_b.copyWith(enabled: v)),
      ),
      if (_b.enabled)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
          child: Column(children: [
            TextField(controller: _name, decoration: InputDecoration(labelText: ar ? 'الاسم / الجهة' : 'Name / company'),
                onChanged: (v) => _save(_b.copyWith(name: v.trim()))),
            const SizedBox(height: 8),
            TextField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: ar ? 'رقم الجوال' : 'Phone'),
                onChanged: (v) => _save(_b.copyWith(phone: v.trim()))),
            const SizedBox(height: 8),
            Row(children: [
              if (_b.logoPath.isNotEmpty && File(_b.logoPath).existsSync())
                Padding(padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Image.file(File(_b.logoPath), width: 40, height: 40, fit: BoxFit.contain)),
              Expanded(child: OutlinedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: Text(ar ? 'اختيار الشعار من المعرض' : 'Choose logo from gallery', overflow: TextOverflow.ellipsis),
                onPressed: _pickLogo)),
              if (_b.logoPath.isNotEmpty)
                IconButton(tooltip: ar ? 'إزالة الشعار' : 'Remove logo', icon: const Icon(Icons.close),
                    onPressed: () => _save(_b.copyWith(logoPath: ''))),
            ]),
          ]),
        ),
    ]);
  }
}
