import 'package:flutter/material.dart';
import 'todo_service.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final todoService = TodoService();

  runApp(TodoApp(todoService: todoService));
}

class TodoApp extends StatelessWidget {
  final TodoService todoService;

  const TodoApp({
    super.key,
    required this.todoService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: HomeScreen(todoService: todoService),
    );
  }
}
