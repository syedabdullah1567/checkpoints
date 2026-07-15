import 'package:checkpoints/utilities/dark_mode_switcher.dart';
import 'package:checkpoints/data/database.dart';
import 'package:checkpoints/utilities/input_box.dart';
import 'package:checkpoints/utilities/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:checkpoints/pages/notifications.dart';

class ToDoPage extends StatefulWidget {
  final int pageId;
  const ToDoPage({super.key, required this.pageId});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _myBox = Hive.box('MyBox');

  ToDoDataBase db = ToDoDataBase();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 1. First, make sure BOTH lists are initialized in Hive with defaults if they don't exist
    if (_myBox.get('TODOLIST') == null) {
      db.createInitialDaily();
      db.updateToDo(); // Save the default tasks immediately
    } else {
      db.loadToDo();
    }

    if (_myBox.get('LONGTERM') == null) {
      db.createInitialLongTerm();
      db.updateLongTerm(); // Save the empty list immediately
    } else {
      db.loadLongTerm();
    }

    // 2. Now that we are guaranteed to have valid data in memory,
    // we can safely run our migration logic.
    _syncTasks();
  }

  void _syncTasks() {
    setState(() {
      db.loadToDo();
      db.loadLongTerm();
      db.moveLongtermToDaily(); // This handles moving and saving automatically
    });
  }

  void checkBoxChanged(bool? value, int index) {
    if (widget.pageId == 0) {
      setState(() {
        db.todoList[index][1] = !db.todoList[index][1];
      });
      db.updateToDo();

      final int taskId = db.todoList[index][3];
      if (db.todoList[index][1] == false) {
        NotifyTasks().scheduleTodoNotification(
          id: taskId,
          title: 'You have a task pending',
          body: db.todoList[index][0],
          dueDate: db.todoList[index][2],
        );
      } else {
        NotifyTasks().cancelSingleNotification(taskId);
      }
    } else {
      setState(() {
        db.longTerm[index][1] = !db.longTerm[index][1];
      });
      db.updateLongTerm();

      final int taskId = db.longTerm[index][3];
      if (db.longTerm[index][1] == false) {
        NotifyTasks().scheduleTodoNotification(
          id: taskId,
          title: 'You have a long-term task pending',
          body: db.longTerm[index][0],
          dueDate: db.longTerm[index][2],
        );
      } else {
        NotifyTasks().cancelSingleNotification(taskId);
      }
    }
  }

  void createNewTask() {
    final DateTime freshCurrentTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
    );
    showDialog(
      context: context,
      builder: (context) {
        _controller.clear();

        return InputBox(
          controller: _controller,
          currentTime: widget.pageId == 0
              ? freshCurrentTime
              : freshCurrentTime.add(Duration(days: 1)),
          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(
                10000000,
              );

              if (widget.pageId == 0) {
                setState(() {
                  db.todoList.add([
                    _controller.text,
                    false,
                    selectedTime,
                    uniqueId,
                  ]);
                });
                db.updateToDo();

                NotifyTasks().scheduleTodoNotification(
                  id: uniqueId,
                  title: 'You have a task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              } else {
                setState(() {
                  db.longTerm.add([
                    _controller.text,
                    false,
                    selectedTime,
                    uniqueId,
                  ]);
                });
                db.updateLongTerm();

                NotifyTasks().scheduleTodoNotification(
                  id: uniqueId,
                  title: 'You have a long-term task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              }

              Navigator.of(context).pop();
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          pageNum: widget.pageId,
        );
      },
    );
  }

  void editTask(int index) {
    if (widget.pageId == 0) {
      _controller.text = db.todoList[index][0];
    } else {
      _controller.text = db.longTerm[index][0];
    }

    showDialog(
      context: context,
      builder: (context) {
        return InputBox(
          controller: _controller,
          currentTime: widget.pageId == 0
              ? db.todoList[index][2]
              : db.longTerm[index][2],
          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              if (widget.pageId == 0) {
                final int taskId = db.todoList[index][3];
                setState(() {
                  db.todoList[index][0] = _controller.text;
                  db.todoList[index][2] = selectedTime;
                });
                db.updateToDo();

                NotifyTasks().scheduleTodoNotification(
                  id: taskId,
                  title: 'You have a task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              } else {
                final int taskId = db.longTerm[index][3];
                setState(() {
                  db.longTerm[index][0] = _controller.text;
                  db.longTerm[index][2] = selectedTime;
                });
                db.updateLongTerm();

                NotifyTasks().scheduleTodoNotification(
                  id: taskId,
                  title: 'You have a long-term task pending',
                  body: _controller.text,
                  dueDate: selectedTime,
                );
              }

              Navigator.of(context).pop();
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          pageNum: widget.pageId,
        );
      },
    );
  }

  void deleteTask(int index) {
    if (widget.pageId == 0) {
      final int taskId = db.todoList[index][3];
      setState(() {
        db.todoList.removeAt(index);
      });
      db.updateToDo();
      NotifyTasks().cancelSingleNotification(taskId);
    } else {
      final int taskId = db.longTerm[index][3];
      setState(() {
        db.longTerm.removeAt(index);
      });
      db.updateLongTerm();
      NotifyTasks().cancelSingleNotification(taskId);
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (widget.pageId == 0) {
      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = db.todoList.removeAt(oldIndex);
        db.todoList.insert(newIndex, item);
      });
      db.updateToDo();
    } else {
      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = db.longTerm.removeAt(oldIndex);
        db.longTerm.insert(newIndex, item);
      });
      db.updateLongTerm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: widget.pageId == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Today\'s Checkpoints',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : const Text(
                'Upcoming Horizon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [DarkModeSwitcher()],
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 25.0),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: widget.pageId == 0
              ? db.todoList.length
              : db.longTerm.length,
          // ignore: deprecated_member_use
          onReorder: reorderTasks,
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 8,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: child,
              ),
            );
          },
          itemBuilder: (context, index) {
            return KeyedSubtree(
              key: ValueKey(index),
              child: ReorderableDelayedDragStartListener(
                index: index,
                child: ToDoTile(
                  taskName: widget.pageId == 0
                      ? db.todoList[index][0]
                      : db.longTerm[index][0],
                  dueTime: widget.pageId == 0
                      ? db.todoList[index][2]
                      : db.longTerm[index][2],
                  taskCompleted: widget.pageId == 0
                      ? db.todoList[index][1]
                      : db.longTerm[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                  onTap: () => editTask(index),
                  deleteFunction: (context) => deleteTask(index),
                  pageNum: widget.pageId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
