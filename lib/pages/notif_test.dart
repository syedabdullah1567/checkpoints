import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'dart:io';

Future<void> requestNotificationPermissions() async {
  if (Platform.isAndroid) {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // 1. Request standard permission to actually SHOW notifications (Pops up dialog on Android 13+)
      final bool? grantedNotifications = 
          await androidImplementation.requestNotificationsPermission();
      
      if (grantedNotifications == true) {
        print("✅ Notification display permission granted.");
      } else {
        print("❌ Notification display permission denied.");
      }

      // 2. Request permission to schedule EXACT alarms (Redirects to Settings on Android 14+)
      final bool? grantedExactAlarms = 
          await androidImplementation.requestExactAlarmsPermission();
      
      if (grantedExactAlarms == true) {
        print("✅ Exact alarm permission granted.");
      } else {
        print("⚠️ Exact alarm permission denied or pending user setting toggle.");
      }
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

Future scheduleTodoNotification({
  required int id,
  required String title,
  required String body,
  required DateTime dueDate, // Standard DateTime from your Todo object!
}) async {
  // Convert standard DateTime to TZDateTime using the local timezone
  final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(dueDate, tz.local);

  // (Optional Safety Check) Ensure we aren't scheduling a date in the past
  if (scheduledTZDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
    print("Cannot schedule a notification in the past!");
    return;
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: scheduledTZDateTime, // Pass the converted TZDateTime here
    notificationDetails:  NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_channel_id',
        'Todo Reminders',
        channelDescription: 'Notifications for task due dates',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Fires exactly on time
  );
}