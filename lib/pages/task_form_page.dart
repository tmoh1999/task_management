import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/task_provider.dart';
import '../utils/theme_constants.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedPriority = 'Normal';
  String _selectedCategory = 'General';
  late AnimationController _animationController;

  static const List<String> _priorities = ['Low', 'Normal', 'High'];
  static const List<String> _categories = [
    'General',
    'Work',
    'Personal',
    'Shopping',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: TaskTheme.mediumAnimationDuration,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Provider.of<TaskProvider>(context, listen: false).addTask(
      title,
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      category: _selectedCategory,
    );

    Navigator.of(context).pop();
  }

  String _formatDueDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        elevation: 0,
      ),
      body: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title Field
                _buildFormSection(
                  title: 'Task Title',
                  child: TextField(
                    controller: _taskController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      prefixIcon: const Icon(Icons.edit_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description Field
                _buildFormSection(
                  title: 'Description (Optional)',
                  child: TextField(
                    controller: _descriptionController,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Add more details about your task...',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 20),

                // Priority & Category Row
                _buildFormSection(
                  title: 'Priority & Category',
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPriorityDropdown(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCategoryDropdown(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Due Date Field
                _buildFormSection(
                  title: 'Due Date (Optional)',
                  child: InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDueDate == null
                                  ? 'Select a due date'
                                  : _formatDueDate(_selectedDueDate!),
                              style: TextStyle(
                                fontSize: 15,
                                color: _selectedDueDate == null
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (_selectedDueDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDueDate = null;
                                });
                              },
                              child: Icon(Icons.close,
                                  color: Colors.grey.shade400, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: TaskTheme.shortAnimationDuration,
                    child: ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPriority,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.flag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
      items: _priorities
          .map((priority) => DropdownMenuItem(
                value: priority,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TaskTheme.getPriorityColor(priority),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(priority),
                  ],
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
      items: _categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TaskTheme.getCategoryColor(category),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(category),
                  ],
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }
}
