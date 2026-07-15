//import 'package:dynamic_color/dynamic_color.dart';
import 'package:checkpoints/pages/notifications.dart';
import 'package:checkpoints/utilities/value_notifier.dart';
import 'package:checkpoints/pages/homepage_checkpoints.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Ensure bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // ignore: unused_local_variable
  var box = await Hive.openBox('MyBox');

  NotifyTasks().initNotification();
  NotifyTasks().requestAndroidPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to your dark mode notifier here
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Checkpoints',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),

            useMaterial3: false,
          ),

          home: const HomepageCheckpoints(),
        );
      },
    );
  }
}

//   Widget build(BuildContext context) {
//     return DynamicColorBuilder(
//       builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
//         final lightColorScheme =
//             lightDynamic?.harmonized() ??
//             ColorScheme.fromSeed(
//               seedColor: Colors.blueGrey,
//               brightness: Brightness.light,
//             );
//         final darkColorScheme =
//             darkDynamic?.harmonized() ??
//             ColorScheme.fromSeed(
//               seedColor: Colors.blueGrey,
//               brightness: Brightness.dark,
//             );

//         // 1. Listen to your dark mode notifier here
//         return ValueListenableBuilder<bool>(
//           valueListenable: isDarkModeNotifier,
//           builder: (context, isDarkMode, child) {
//             return MaterialApp(
//               debugShowCheckedModeBanner: false,
//               title: 'Checkpoints',
//               theme: ThemeData(
//                 colorScheme: lightColorScheme,
//                 useMaterial3: true,
//               ),
//               darkTheme: ThemeData(
//                 colorScheme: darkColorScheme,
//                 useMaterial3: true,
//               ),
//               // 2. Control the theme mode based on the notifier's state
//               themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
//               home: const Homepage(),
//             );
//           },
//         );
//       },
//     );
//   }
// }
