import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/task_provider.dart';
import '../routes.dart';

enum TaskFilter { all, pending, completed }
enum SortOption { dueDate, priority }

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskFilter _activeFilter = TaskFilter.all;
  SortOption _activeSort = SortOption.dueDate;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();

  String _formatDueDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Task> _applyFilterAndSort(List<Task> tasks) {
    final filtered = tasks.where((task) {
      switch (_activeFilter) {
        case TaskFilter.pending:
          return !task.isDone;
        case TaskFilter.completed:
          return task.isDone;
        case TaskFilter.all:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      int result;
      if (_activeSort == SortOption.dueDate) {
        if (a.dueDate == null && b.dueDate == null) {
          result = 0;
        } else if (a.dueDate == null) {
          result = 1;
        } else if (b.dueDate == null) {
          result = -1;
        } else {
          result = a.dueDate!.compareTo(b.dueDate!);
        }
      } else {
        final order = ['Low', 'Normal', 'High'];
        final aIndex = order.indexOf(a.priority);
        final bIndex = order.indexOf(b.priority);
        result = aIndex.compareTo(bIndex);
      }
      
      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.all:
        return 'All';
    }
  }

  String _sortLabel(SortOption option) {
    switch (option) {
      case SortOption.priority:
        return 'Priority';
      case SortOption.dueDate:
        return 'Due date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = _applyFilterAndSort(provider.filteredTasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, Routes.form),
            tooltip: 'Add task',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => provider.setSearchQuery(v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                hintText: 'Search by title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TaskFilter.values.map((filter) {
                        final selected = filter == _activeFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_filterLabel(filter)),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _activeFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<SortOption>(
                  initialValue: _activeSort,
                  onSelected: (option) {
                    setState(() => _activeSort = option);
                  },
                  itemBuilder: (context) => SortOption.values
                      .map(
                        (option) => PopupMenuItem(
                          value: option,
                          child: Text(_sortLabel(option)),
                        ),
                      )
                      .toList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_sortLabel(_activeSort)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() => _sortAscending = !_sortAscending);
                          },
                          child: Icon(
                            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tasks yet',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text('Add a task to get started.'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final taskKey = task.key ?? index;

                      return Dismissible(
                        key: ValueKey(taskKey),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          provider.deleteTask(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted "${task.title}"'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  provider.restoreDeletedTask();
                                },
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (_) => provider.toggleTask(task),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: task.isDone
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      )
                                    : const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.description,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(task.priority),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Chip(
                                    label: Text(task.category),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  if (task.dueDate != null)
                                    Chip(
                                      label: Text('Due: ${_formatDueDate(task.dueDate!)}'),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  await provider.showEditDialog(context, task);
                                },
                                tooltip: 'Edit task',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => provider.deleteTask(task),
                                tooltip: 'Delete task',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
