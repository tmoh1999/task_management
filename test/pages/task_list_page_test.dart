import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/state/task_provider.dart';
import 'package:task_management/pages/task_list_page.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasks');
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  testWidgets('shows no tasks message when empty', (WidgetTester tester) async {
    final provider = TaskProvider();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TaskProvider>.value(
          value: provider,
          child: const TaskListPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // provider.addTask('Hello', description: 'Desc');
    expect(find.text('No tasks yet'), findsOneWidget);
  });

testWidgets('shows task in list UI', (tester) async {
  await tester.runAsync(() async {
    final provider = TaskProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TaskProvider>.value(
          value: provider,
          child: const TaskListPage(),
        ),
      ),
    );

    // initial state
    expect(find.text('No tasks yet'), findsOneWidget);

    // add task
    provider.addTask(
      'Hello',
      description: 'Desc',
      dueDate: DateTime(2026, 6, 30),
      category: 'Work',
    );

    await tester.pump(); // rebuild UI

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Desc'), findsOneWidget);
  });
});
}
