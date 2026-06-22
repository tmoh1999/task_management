import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

  List<Task> get tasks => _box.values.toList();

  void addTask(
    String title, {
    String description = '',
    DateTime? dueDate,
    String priority = 'Normal',
    String category = 'General',
  }) {
    final task = Task(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      category: category,
    );
    _box.add(task);
    notifyListeners();
  }

  void updateTask(
    int index, {
    required String title,
    String description = '',
    DateTime? dueDate,
    required String priority,
    required String category,
  }) {
    final task = _box.getAt(index);
    if (task != null) {
      task.title = title;
      task.description = description;
      task.dueDate = dueDate;
      task.priority = priority;
      task.category = category;
      task.save();
      notifyListeners();
    }
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