import 'package:shared_preferences/shared_preferences.dart';

class BrokerProfile {
  final bool enabled;
  final String name, phone, logoPath;
  const BrokerProfile({this.enabled = false, this.name = '', this.phone = '', this.logoPath = ''});
  BrokerProfile copyWith({bool? enabled, String? name, String? phone, String? logoPath}) => BrokerProfile(
      enabled: enabled ?? this.enabled, name: name ?? this.name, phone: phone ?? this.phone, logoPath: logoPath ?? this.logoPath);
}

class BrokerStore {
  static Future<BrokerProfile> load() async {
    final p = await SharedPreferences.getInstance();
    return BrokerProfile(enabled: p.getBool('broker_on') ?? false, name: p.getString('broker_name') ?? '',
        phone: p.getString('broker_phone') ?? '', logoPath: p.getString('broker_logo') ?? '');
  }

  static Future<void> save(BrokerProfile b) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('broker_on', b.enabled);
    await p.setString('broker_name', b.name);
    await p.setString('broker_phone', b.phone);
    await p.setString('broker_logo', b.logoPath);
  }
}
