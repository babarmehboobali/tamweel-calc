import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local reminders for the loan tracker. Uses inexact scheduling (no exact-alarm permission needed).
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> _init() async {
    if (_ready || kIsWeb) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  /// Android 13+: asks for POST_NOTIFICATIONS. Returns false if denied.
  static Future<bool> requestPermission() async {
    try {
      await _init();
      final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await a?.requestNotificationsPermission() ?? true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> schedule({required int id, required DateTime when, required String title, required String body}) async {
    try {
      await _init();
      if (when.isBefore(DateTime.now())) return;
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(when, tz.UTC), // absolute instant; no device-zone lookup needed
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('loan_reminders', 'Loan reminders',
              channelDescription: 'Instalment due reminders', importance: Importance.high, priority: Priority.high),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
      );
    } catch (e) {
      debugPrint('reminder schedule failed: $e');
    }
  }

  static Future<void> cancel(int id) async {
    try {
      await _init();
      await _plugin.cancel(id: id);
    } catch (_) {}
  }
}
