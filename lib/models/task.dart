import 'package:hive/hive.dart';

part 'task.g.dart'; //flutter pub run build_runner build

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  String priority;

  @HiveField(5)
  String category;

  Task({
    required this.title,
    this.isDone = false,
    this.description = '',
    this.dueDate,
    this.priority = 'Normal',
    this.category = 'General',
  });
}