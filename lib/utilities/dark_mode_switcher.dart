import 'package:checkpoints/utilities/value_notifier.dart';
import 'package:flutter/material.dart';

class DarkModeSwitcher extends StatelessWidget {
  const DarkModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (BuildContext context, dynamic value, Widget? child) {
        return IconButton(
          onPressed: () {
            isDarkModeNotifier.value = !isDarkModeNotifier.value;
          },
          icon: Icon(value ? Icons.dark_mode : Icons.light_mode),
        );
      },
    );
  }
}
