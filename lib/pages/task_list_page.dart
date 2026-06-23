import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/task_provider.dart';
import '../routes.dart';
import '../utils/theme_constants.dart';

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
        elevation: 0,
      ),  
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                          child: AnimatedContainer(
                            duration: TaskTheme.shortAnimationDuration,
                            child: ChoiceChip(
                              label: Text(_filterLabel(filter)),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _activeFilter = filter;
                                });
                              },
                            ),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_sortLabel(_activeSort)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() => _sortAscending = !_sortAscending);
                          },
                          child: AnimatedRotation(
                            turns: _sortAscending ? 0 : 0.5,
                            duration: TaskTheme.shortAnimationDuration,
                            child: const Icon(
                              Icons.unfold_more,
                              size: 18,
                            ),
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
                    child: ScaleTransition(
                      scale: AlwaysStoppedAnimation(1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a task to get started.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final taskKey = task.key ?? index;

                      return Dismissible(
                        key: ValueKey(taskKey),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        child: _TaskCardWidget(
                          task: task,
                          onToggle: () => provider.toggleTask(task),
                          onEdit: () async {
                            await provider.showEditDialog(context, task);
                          },
                          onDelete: () => provider.deleteTask(task),
                          formatDueDate: _formatDueDate,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: TaskTheme.shortAnimationDuration,
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, Routes.form),
          tooltip: 'Add task',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TaskCardWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDueDate;

  const _TaskCardWidget({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.formatDueDate,
  });

  @override
  State<_TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<_TaskCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TaskTheme.shortAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: widget.task.isDone
                        ? Colors.grey.shade200
                        : TaskTheme.getPriorityColor(widget.task.priority)
                            .withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: TaskTheme.shortAnimationDuration,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.task.isDone
                          ? TaskTheme.normalPriority
                          : Colors.transparent,
                      border: Border.all(
                        color: TaskTheme.normalPriority,
                        width: 2,
                      ),
                    ),
                    width: 24,
                    height: 24,
                    child: widget.task.isDone
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.task.isDone ? Colors.grey : null,
                      ),
                    ),
                    if (widget.task.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: TaskTheme.getPriorityColor(
                              widget.task.priority,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.task.priority,
                            style: TextStyle(
                              color: TaskTheme.getPriorityColor(
                                widget.task.priority,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: TaskTheme.getCategoryColor(widget.task.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.task.category,
                            style: TextStyle(
                              color: TaskTheme.getCategoryColor(
                                widget.task.category,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (widget.task.dueDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Due: ${widget.formatDueDate(widget.task.dueDate!)}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: widget.onEdit,
                        tooltip: 'Edit task',
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: widget.onDelete,
                        tooltip: 'Delete task',
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
