import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

  String _searchQuery = '';
  Timer? _searchDebounce;
  Task? _lastDeletedTask;

  List<Task> get tasks => _box.values.toList();

  /// Returns tasks filtered by the current debounced search query.
  List<Task> get filteredTasks {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return tasks;
    return tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  /// Sets the search query with a short debounce to avoid frequent rebuilds.
  void setSearchQuery(String query) {
    // Cancel previous timer
    _searchDebounce?.cancel();
    // Start a new debounce timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      notifyListeners();
    });
  }

  String get searchQuery => _searchQuery;

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
    Task task, {
    required String title,
    String description = '',
    DateTime? dueDate,
    required String priority,
    required String category,
  }) {
    task.title = title;
    task.description = description;
    task.dueDate = dueDate;
    task.priority = priority;
    task.category = category;
    task.save();
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    task.save();
    notifyListeners();
  }

  void deleteTask(Task task) {
    _lastDeletedTask = task;
    task.delete();
    notifyListeners();
  }

  void restoreDeletedTask() {
    if (_lastDeletedTask != null) {
      _box.add(_lastDeletedTask!);
      _lastDeletedTask = null;
      notifyListeners();
    }
  }

  Task? get lastDeletedTask => _lastDeletedTask;

  Future<void> showEditDialog(BuildContext context, Task task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? selectedDueDate = task.dueDate;
    String selectedPriority = task.priority;
    String selectedCategory = task.category;

    const List<String> priorities = ['Low', 'Normal', 'High'];
    const List<String> categories = [
      'General',
      'Work',
      'Personal',
      'Shopping',
      'Health',
    ];

    final now = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Edit task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: priorities
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) dialogSetState(() => selectedPriority = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) dialogSetState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDueDate ?? now,
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) dialogSetState(() => selectedDueDate = picked);
                            },
                            child: Text(
                              selectedDueDate == null
                                  ? 'Select due date'
                                  : '${selectedDueDate?.year}-${selectedDueDate?.month.toString().padLeft(2, '0')}-${selectedDueDate?.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                        if (selectedDueDate != null) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Remove due date',
                            onPressed: () => dialogSetState(() => selectedDueDate = null),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedTitle = titleController.text.trim();
                    if (updatedTitle.isEmpty) return;

                    updateTask(
                      task,
                      title: updatedTitle,
                      description: descriptionController.text.trim(),
                      dueDate: selectedDueDate,
                      priority: selectedPriority,
                      category: selectedCategory,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }
}