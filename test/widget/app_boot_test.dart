import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/main.dart' as app;

void main() {
  testWidgets('app boots', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp('Loan Calculator|حاسبة التمويل')), findsWidgets);
  });
}
