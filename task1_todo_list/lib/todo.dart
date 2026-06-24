import 'dart:convert';

enum TaskPriority { low, medium, high }

class TodoTask {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;

  TodoTask({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  TodoTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      priority: TaskPriority.values[map['priority'] ?? 1],
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoTask.fromJson(String source) => TodoTask.fromMap(json.decode(source));
}
