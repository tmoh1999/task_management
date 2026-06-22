import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

  List<Task> get tasks => _box.values.toList();

  void addTask(String title) {
    final task = Task(title: title);
    _box.add(task);
    notifyListeners();
  }

  void toggleTask(int index) {
    final task = _box.getAt(index);
    if (task != null) {
      task.isDone = !task.isDone;
      task.save();
      notifyListeners();
    }
  }

  void deleteTask(int index) {
    _box.deleteAt(index);
    notifyListeners();
  }
}