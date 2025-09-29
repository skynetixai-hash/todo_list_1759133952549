import 'package:flutter/foundation.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String priority; // 'high', 'medium', 'low'
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class TaskManager {
  // Singleton pattern
  static final TaskManager _instance = TaskManager._();
  TaskManager._();
  static TaskManager get instance => _instance;

  final List<Task> _tasks = [];

  // Basic CRUD operations
  Future<List<Task>> getAllTasks() async => _tasks;

  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    }
  }

  // Task filters
  Future<List<Task>> getTodayTasks() async {
    final today = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.year == today.year &&
          task.dueDate!.month == today.month &&
          task.dueDate!.day == today.day;
    }).toList();
  }

  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }

  Future<List<Task>> getUpcomingTasks() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final todayTasks = await getTodayTasks();
    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isAfter(now) &&
          task.dueDate!.isBefore(nextWeek) &&
          !todayTasks.any((t) => t.id == task.id);
    }).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  // Generate unique IDs for tasks
  String generateTaskId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
