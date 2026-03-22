import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../data/motivational_quotes.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Function(String noteId, String type)? onNotificationTap;

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null && payload.contains('|')) {
          final parts = payload.split('|');
          final noteId = parts[0];
          final type = parts.length > 1 ? parts[1] : 'note';
          onNotificationTap?.call(noteId, type);
        }
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleCustom(
      String noteId, String noteTitle, String type, DateTime scheduledTime) async {
    final payload = '$noteId|$type';
    final baseId = (noteId.hashCode.abs() + 9999) % 0x7FFFFFFF;

    const channel = AndroidNotificationDetails(
      'memora_reminders',
      'Memora Reminders',
      channelDescription: 'Reminders to read your saved notes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: channel,
      iOS: DarwinNotificationDetails(),
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      baseId,
      'Reminder: $noteTitle 📖',
      'You set a reminder for this note.',
      tzTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelCustom(String noteId) async {
    final baseId = (noteId.hashCode.abs() + 9999) % 0x7FFFFFFF;
    await _plugin.cancel(baseId);
  }

  static Future<void> scheduleReminders(
      String noteId, String noteTitle, String type) async {
    final rand = Random();
    final usedIndices = <int>{};

    String _pickQuote() {
      int idx;
      do {
        idx = rand.nextInt(motivationalQuotes.length);
      } while (usedIndices.contains(idx));
      usedIndices.add(idx);
      return motivationalQuotes[idx];
    }

    final payload = '$noteId|$type';
    final baseId = noteId.hashCode.abs();

    const channel = AndroidNotificationDetails(
      'memora_reminders',
      'Memora Reminders',
      channelDescription: 'Reminders to read your saved notes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: channel,
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);

    // 1 minute
    await _plugin.zonedSchedule(
      baseId,
      'Hey! You saved something worth reading 📖',
      _pickQuote(),
      now.add(const Duration(minutes: 1)),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 10 minutes
    await _plugin.zonedSchedule(
      baseId + 1,
      'Hey! You saved something worth reading 📖',
      _pickQuote(),
      now.add(const Duration(minutes: 10)),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 1 hour
    await _plugin.zonedSchedule(
      baseId + 2,
      'Hey! You saved something worth reading 📖',
      _pickQuote(),
      now.add(const Duration(hours: 1)),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 24 hours
    await _plugin.zonedSchedule(
      baseId + 3,
      'Hey! You saved something worth reading 📖',
      _pickQuote(),
      now.add(const Duration(hours: 24)),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminders(String noteId) async {
    final baseId = noteId.hashCode.abs();
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 1);
    await _plugin.cancel(baseId + 2);
    await _plugin.cancel(baseId + 3);
  }
}

