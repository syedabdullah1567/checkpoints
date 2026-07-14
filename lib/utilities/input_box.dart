import 'package:checkpoints/utilities/buttons.dart';
import 'package:checkpoints/utilities/custom_date_time.dart';
import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  final TextEditingController controller;
  final DateTime currentTime;
  final ValueChanged<DateTime> onSave;
  final VoidCallback onCancel;
  final int pageNum;

  const InputBox({
    super.key,
    required this.controller,
    required this.currentTime,
    required this.onSave,
    required this.onCancel,
    required this.pageNum,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = widget.currentTime;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        widget.controller.text.isEmpty ? 'New Checkpoint' : 'Edit Checkpoint',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      // 💡 Use contentPadding to give breathing room around the interior elements
      contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
      content: SizedBox(
        width: 320, // Keep width fixed to prevent dialog structural distortion
        // 💡 Use Column with MainAxisSize.min so the dialog layout fits its contents tightly
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 💡 Wrap the text field block inside a Flexible wrapper to allow organic growth
            Flexible(
              child: TextField(
                controller: widget.controller,
                maxLines:
                    4, // 💡 Sets a clean max height ceiling before scrolling inside the dialog
                minLines:
                    2, // 💡 Starts off tall enough to invite multiline entries clearly
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(120),
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  // Adjusted paddings so text alignment looks balanced right from the start
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            if (widget.pageNum == 0)
              TimePickerBanner(
                currentTime: currentTime,
                onTimeChanged: (newTime) {
                  setState(() {
                    currentTime = newTime;
                  });
                },
              )
            else
              DateTimePickerBanner(
                currentTime: currentTime,
                onTimeChanged: (newTime) {
                  setState(() {
                    currentTime = newTime;
                  });
                },
              ),
          ],
        ),
      ),
      // 💡 Moving your buttons to the explicit 'actions' element pins them neatly at the base
      actionsPadding: const EdgeInsets.only(right: 24.0, bottom: 20.0),
      actions: [
        MyButton(text: 'Cancel', onPressed: widget.onCancel),
        const SizedBox(width: 4),
        MyButton(text: 'Save', onPressed: () => widget.onSave(currentTime)),
      ],
    );
  }
}
