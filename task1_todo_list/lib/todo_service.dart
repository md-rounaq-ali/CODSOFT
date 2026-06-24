import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo.dart';

class TodoService extends ChangeNotifier {
  static const _key = 'todo_tasks';
  List<TodoTask> _tasks = [];

  List<TodoTask> get tasks => _tasks;

  TodoService() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _tasks = raw.map((s) => TodoTask.fromJson(s)).toList();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_key, raw);
    notifyListeners();
  }

  Future<void> addTask(TodoTask task) async {
    _tasks.add(task);
    await _saveTasks();
  }

  Future<void> updateTask(TodoTask updatedTask) async {
    final idx = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      _tasks[idx] = updatedTask;
      await _saveTasks();
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(isCompleted: !_tasks[idx].isCompleted);
      await _saveTasks();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
  }
}
