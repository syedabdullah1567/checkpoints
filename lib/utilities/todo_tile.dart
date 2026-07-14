import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ToDoTile extends StatefulWidget {
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final String taskName;
  final Function(BuildContext)? deleteFunction;
  final VoidCallback? onTap;
  final DateTime dueTime;
  final int pageNum;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.dueTime,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    this.onTap,
    required this.pageNum,
  });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  Timer? _longPressTimer;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _startLongPressFeedback() {
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _cancelLongPressFeedback() {
    _longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: widget.deleteFunction,
              icon: Icons.delete,
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Listener(
          onPointerDown: (_) => _startLongPressFeedback(),
          onPointerUp: (_) => _cancelLongPressFeedback(),
          onPointerCancel: (_) => _cancelLongPressFeedback(),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(230),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withAlpha(90),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: widget.taskCompleted,
                    onChanged: widget.onChanged,
                    activeColor: colorScheme.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.taskName,
                          softWrap: true,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            decoration: widget.taskCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Text(
                              widget.pageNum == 0
                                  ? 'Due time: ${DateFormat('h:mm a').format(widget.dueTime)}'
                                  : 'Due date: ${DateFormat('MMMM d, yyyy • h:mm a').format(widget.dueTime)}',
                              style: TextStyle(
                                color: widget.dueTime.isBefore(DateTime.now())
                                    ? Colors.red
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
