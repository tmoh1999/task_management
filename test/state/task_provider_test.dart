import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/state/task_provider.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasks');
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('addTask adds to box and provider.tasks', () {
    final provider = TaskProvider();
    provider.addTask('New task', description: 'desc');
    expect(provider.tasks.length, 1);
    final task = provider.tasks.first;
    expect(task.title, 'New task');
    expect(task.description, 'desc');
  });

  test('toggleTask toggles isDone', () {
    final provider = TaskProvider();
    provider.addTask('T1');
    final task = provider.tasks.first;
    expect(task.isDone, false);
    provider.toggleTask(task);
    expect(task.isDone, true);
    provider.toggleTask(task);
    expect(task.isDone, false);
  });

  test('delete and restore', () {
    final provider = TaskProvider();
    provider.addTask('T1');
    final task = provider.tasks.first;
    provider.deleteTask(task);
    expect(provider.tasks.length, 0);
    provider.restoreDeletedTask();
    expect(provider.tasks.length, 1);
  });

  test('setSearchQuery debounces and filters', () async {
    final provider = TaskProvider();
    provider.addTask('Apple');
    provider.addTask('Banana');
    provider.setSearchQuery('app');
    // Wait longer than debounce
    await Future.delayed(const Duration(milliseconds: 350));
    expect(provider.searchQuery, 'app');
    expect(provider.filteredTasks.length, 1);
  });
}
