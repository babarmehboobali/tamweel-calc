import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a Play rating once, right after the user's 2nd PDF export.
class RateUsService {
  static Future<void> onPdfExported() async {
    try {
      final p = await SharedPreferences.getInstance();
      final n = (p.getInt('pdf_exports') ?? 0) + 1;
      await p.setInt('pdf_exports', n);
      if (n != 2 || (p.getBool('review_asked') ?? false)) return;
      final r = InAppReview.instance;
      if (await r.isAvailable()) {
        await p.setBool('review_asked', true);
        await r.requestReview();
      }
    } catch (_) {}
  }
}
