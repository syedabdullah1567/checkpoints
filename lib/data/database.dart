import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  // List of tasks
  List todoList = [];

  List longTerm = [];

  // Reference the box
  final _myBox = Hive.box('MyBox');

  void createInitialDaily() {
    todoList = [
      ['Tap on the checkbox to mark as completed', false, DateTime.now(), 0],
      ['Swipe left on this task', false, DateTime.now(), 0],
      ['Tap on this task to edit', false, DateTime.now(), 0],
      ['Long press on this task to move it', false, DateTime.now(), 0],
    ];
  }

  void createInitialLongTerm() {
    longTerm = [];
  }

  void loadToDo() {
    todoList = _myBox.get('TODOLIST');
  }

  void loadLongTerm() {
    longTerm = _myBox.get('LONGTERM');
  }

  void moveLongtermToDaily() {
    int length = longTerm.length;
    for (int i = length - 1; i >= 0; i--) {
      if (longTerm[i][2].year == DateTime.now().year) {
        if (longTerm[i][2].month == DateTime.now().month) {
          if (longTerm[i][2].day == DateTime.now().day) {
            final thisItem = longTerm[i];
            longTerm.removeAt(i);
            todoList.add(thisItem);
          }
        }
      }
    }

    updateToDo();
    updateLongTerm();
  }

  void updateToDo() {
    _myBox.put('TODOLIST', todoList);
  }

  void updateLongTerm() {
    _myBox.put('LONGTERM', longTerm);
  }
}
