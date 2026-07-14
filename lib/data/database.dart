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
    longTerm = [
      ['Tap on the checkbox to mark as completed', false, DateTime.now(), 0],
      ['Swipe left on this task', false, DateTime.now(), 0],
      ['Tap on this task to edit', false, DateTime.now(), 0],
      ['Long press on this task to move it', false, DateTime.now(), 0],
    ];
  }

  void loadToDo() {
    todoList = _myBox.get('TODOLIST');
  }

  void loadLongTerm() {
    longTerm = _myBox.get('LONGTERM');
  }

  void updateToDo() {
    _myBox.put('TODOLIST', todoList);
  }

  void updateLongTerm() {
    _myBox.put('LONGTERM', longTerm);
  }
}
