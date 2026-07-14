import 'package:checkpoints/pages/notif_test.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:checkpoints/pages/homepage.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  try {
    // Ensure bindings are initialized before calling async code
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize the timezone database
    tz_data.initializeTimeZones();

    // 2. Get the TimezoneInfo object from the native OS
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    // 3. Use the .identifier property which is the actual String!
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    await Hive.initFlutter();
    var box = await Hive.openBox('MyBox');

    // Initialize local notifications plugin settings before calling permission requests
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure this icon exists!
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

    // Call your new permission helper!
    await requestNotificationPermissions();

    runApp(const MyApp());
  } catch (e, stacktrace) {
    print("❌ CRITICAL INITIALIZATION ERROR: $e");
    print(stacktrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightColorScheme =
            lightDynamic?.harmonized() ??
            ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.light,
            );
        final darkColorScheme =
            darkDynamic?.harmonized() ??
            ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Checkpoints',
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: Homepage(),
        );
      },
    );
  }
}
