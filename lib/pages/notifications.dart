import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotifyTasks {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> requestAndroidPermissions() async {
    // Cast the generic plugin down to its native Android representation
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // 1. Request permission to show banners/sounds (Android 13+)
      final bool? allowedNotifications = await androidPlugin
          .requestNotificationsPermission();
      debugPrint("Notification permissions granted: $allowedNotifications");

      // 2. Request permission to schedule EXACT alarms (Android 13/14+)
      final bool? allowedExactAlarms = await androidPlugin
          .requestExactAlarmsPermission();
      debugPrint("Exact alarms permissions granted: $allowedExactAlarms");
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily notifications',
        channelDescription: 'Daily notification channel',
        importance: Importance.max,
        priority: Priority.max,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future scheduleTodoNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
      dueDate,
      tz.local,
    );

    if (scheduledTZDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      SnackBar(content: Text("Cannot schedule a notification in the past!"));
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZDateTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel_id',
          'Todo Reminders',
          channelDescription: 'Notifications for task due dates',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelSingleNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
