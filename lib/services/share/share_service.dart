import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet offering: send by email (mailto), generic share, and PDF (attachment via system share sheet).
class ShareService {
  static String footer(bool isAr) => isAr
      ? '\n\n— حاسبة التمويل الشخصي والقروض (أرقام تقديرية، تأكد مع البنك)'
      : '\n\n— Loan Calculator: Tamweel & EMI (estimates only; confirm with your bank)';

  static Future<void> sendEmail(String subject, String body) async {
    final uri = Uri(scheme: 'mailto', query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    if (!await launchUrl(uri)) {
      await SharePlus.instance.share(ShareParams(text: body, subject: subject));
    }
  }

  static Future<void> shareText(String subject, String body) =>
      SharePlus.instance.share(ShareParams(text: body, subject: subject));

  static Future<void> showSheet(BuildContext context, {required String subject, required String body, Future<void> Function()? onPdf}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final full = body + footer(isAr);
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(isAr ? 'إرسال بالبريد الإلكتروني' : 'Send by email'),
            onTap: () { Navigator.pop(ctx); sendEmail(subject, full); },
          ),
          if (onPdf != null)
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(isAr ? 'إرسال تقرير PDF (مرفق)' : 'Send PDF report (attachment)'),
              onTap: () { Navigator.pop(ctx); onPdf(); },
            ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(isAr ? 'مشاركة' : 'Share'),
            onTap: () { Navigator.pop(ctx); shareText(subject, full); },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
