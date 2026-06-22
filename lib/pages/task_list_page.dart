import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/task_provider.dart';
import '../routes.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  String _formatDueDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

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
      body: tasks.isEmpty
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
                    provider.deleteTask(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted "${task.title}"')),
                    );
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => provider.toggleTask(index),
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
                            await provider.showEditDialog(context, task, index);
                          },
                          tooltip: 'Edit task',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => provider.deleteTask(index),
                          tooltip: 'Delete task',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
