import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerBanner extends StatelessWidget {
  final DateTime currentTime;
  final ValueChanged<DateTime> onTimeChanged;

  const DateTimePickerBanner({
    super.key,
    required this.currentTime,
    required this.onTimeChanged,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentTime),
      );

      print(currentTime);

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onTimeChanged(newDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pickDateTime(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text('Due date: '),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                DateFormat('MMMM d, yyyy • h:mm a').format(currentTime),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            Icon(
              Icons.edit,
              size: 20,
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class TimePickerBanner extends StatelessWidget {
  final DateTime currentTime;
  final ValueChanged<DateTime> onTimeChanged;

  const TimePickerBanner({
    super.key,
    required this.currentTime,
    required this.onTimeChanged,
  });

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
    );

    if (pickedTime != null) {
      final newDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      onTimeChanged(newDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pickTime(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text('Due Time: '),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${currentTime.hour}:${currentTime.minute}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            Icon(
              Icons.edit,
              size: 20,
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
