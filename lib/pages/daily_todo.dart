import 'package:checkpoints/data/database.dart';
import 'package:checkpoints/utilities/input_box.dart';
import 'package:checkpoints/utilities/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:checkpoints/pages/notif_test.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  // Reference the hive box
  final _myBox = Hive.box('MyBox');

  ToDoDataBase db = ToDoDataBase();

  final DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // If this is the 1st time ever opening the app, then create default data
    if (_myBox.get('TODOLIST') == null) {
      db.createInitialDaily();
    } else {
      // There already exists data
      db.loadToDo();
    }
  }

  final _controller = TextEditingController();

  // Upon tapping the checkbox, this function will be called
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateToDo();
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
          currentTime: freshCurrentTime,
          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              setState(() {
                db.todoList.add([_controller.text, false, selectedTime]);
              });
              scheduleTodoNotification(id: db.todoList.length - 1, title: 'You have a task due', body: _controller.text, dueDate: selectedTime);
              Navigator.of(context).pop();
              db.updateToDo();
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          pageNum: 0,
        );
      },
    );
  }

  void editTask(int index) {
    _controller.text = db.todoList[index][0];

    showDialog(
      context: context,
      builder: (context) {
        return InputBox(
          controller: _controller,
          currentTime: db.todoList[index][2],
          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              setState(() {
                db.todoList[index][0] = _controller.text;
                db.todoList[index][2] = selectedTime;
              });
              scheduleTodoNotification(id: db.todoList.length - 1, title: 'You have a task due', body: _controller.text, dueDate: selectedTime);
              Navigator.of(context).pop();
              db.updateToDo();
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          pageNum: 0,
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });
    db.updateToDo();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = db.todoList.removeAt(oldIndex);
      db.todoList.insert(newIndex, item);
    });
    db.updateToDo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // appBar: AppBar(
      //   title: const Text('Daily Checkpoints'),
      //   elevation: 0,
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   foregroundColor: Theme.of(context).colorScheme.onPrimary,
      //   centerTitle: true,
      // ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Today\'s Checkpoints',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(
              DateFormat('MMMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
          itemCount: db.todoList.length,
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
                  taskName: db.todoList[index][0],
                  dueTime: db.todoList[index][2],
                  taskCompleted: db.todoList[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                  onTap: () => editTask(index),
                  deleteFunction: (context) => deleteTask(index),
                  pageNum: 0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
