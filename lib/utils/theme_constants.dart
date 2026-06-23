import 'package:flutter/material.dart';

class TaskTheme {
  // Priority colors
  static const Color lowPriority = Color(0xFF4CAF50); // Green
  static const Color normalPriority = Color(0xFF2196F3); // Blue
  static const Color highPriority = Color(0xFFF44336); // Red

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return lowPriority;
      case 'high':
        return highPriority;
      case 'normal':
      default:
        return normalPriority;
    }
  }

  // Category colors
  static const Map<String, Color> categoryColors = {
    'General': Color(0xFF9C27B0),
    'Work': Color(0xFFFF5722),
    'Personal': Color(0xFF00BCD4),
    'Shopping': Color(0xFFFFC107),
    'Health': Color(0xFF4CAF50),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['General']!;
  }

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
}
