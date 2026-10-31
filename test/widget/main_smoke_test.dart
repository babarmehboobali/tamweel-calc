import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamweel_calc/main.dart' as app;

void main() {
  testWidgets('main() boots without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    app.main();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
