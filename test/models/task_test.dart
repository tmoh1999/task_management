import 'package:flutter_test/flutter_test.dart';
import 'package:task_management/models/task.dart';

void main() {
  test('Task default values', () {
    final t = Task(title: 'Test');
    expect(t.title, 'Test');
    expect(t.isDone, false);
    expect(t.description, '');
    expect(t.dueDate, null);
    expect(t.priority, 'Normal');
    expect(t.category, 'General');
  });
}
