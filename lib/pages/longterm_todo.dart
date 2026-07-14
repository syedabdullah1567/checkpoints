import 'package:checkpoints/data/database.dart';
import 'package:checkpoints/utilities/input_box.dart';
import 'package:checkpoints/utilities/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LaterTodoPage extends StatefulWidget {
  const LaterTodoPage({super.key});

  @override
  State<LaterTodoPage> createState() => _LaterTodoPageState();
}

class _LaterTodoPageState extends State<LaterTodoPage> {
  // Reference the hive box
  final _myBox = Hive.box('MyBox');

  ToDoDataBase db = ToDoDataBase();

  final DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // If this is the 1st time ever opening the app, then create default data
    if (_myBox.get('LONGTERM') == null) {
      db.createInitialLongTerm();
    } else {
      // There already exists data
      db.loadLongTerm();
    }
  }

  final _controller = TextEditingController();

  // Upon tapping the checkbox, this function will be called
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.longTerm[index][1] = !db.longTerm[index][1];
    });
    db.updateLongTerm();
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
                db.longTerm.add([_controller.text, false, selectedTime]);
              });
              Navigator.of(context).pop();
              db.updateLongTerm();
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          pageNum: 1,
        );
      },
    );
  }

  void editTask(int index) {
    _controller.text = db.longTerm[index][0];

    showDialog(
      context: context,
      builder: (context) {
        return InputBox(
          controller: _controller,
          currentTime: db.longTerm[index][2],
          onSave: (selectedTime) {
            if (_controller.text.isNotEmpty) {
              setState(() {
                db.longTerm[index][0] = _controller.text;
                db.longTerm[index][2] = selectedTime;
              });
              Navigator.of(context).pop();
              db.updateLongTerm();
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
          pageNum: 1,
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.longTerm.removeAt(index);
    });
    db.updateLongTerm();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = db.longTerm.removeAt(oldIndex);
      db.longTerm.insert(newIndex, item);
    });
    db.updateLongTerm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
            'Upcoming Horizon',
            style: TextStyle(fontWeight: FontWeight.bold),
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
          itemCount: db.longTerm.length,
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
                  taskName: db.longTerm[index][0],
                  dueTime: db.longTerm[index][2],
                  taskCompleted: db.longTerm[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                  onTap: () => editTask(index),
                  deleteFunction: (context) => deleteTask(index),
                  pageNum : 1
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
