import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:checkpoints/pages/homepage.dart';

import 'package:checkpoints/pages/notifications.dart';

void main() async {
  // Ensure bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // ignore: unused_local_variable
  var box = await Hive.openBox('MyBox');

  NotifyTasks().initNotification();

  runApp(const MyApp());
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
