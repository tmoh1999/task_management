import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'state/task_provider.dart';
import 'routes.dart';
import 'pages/task_list_page.dart';
import 'pages/task_form_page.dart';
import 'utils/theme_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: ColorScheme.fromSeed(seedColor: Colors.blue).surface,
        ),
      ),
      initialRoute: Routes.list,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.list:
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TaskListPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: TaskTheme.shortAnimationDuration,
            );
          case Routes.form:
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TaskFormPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween =
                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: TaskTheme.mediumAnimationDuration,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const TaskListPage(),
            );
        }
      },
    );
  }
}
