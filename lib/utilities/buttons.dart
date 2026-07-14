import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  MyButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 12),
      ),
    );
  }
}
