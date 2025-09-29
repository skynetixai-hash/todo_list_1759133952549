import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/task_manager.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_add_fab_widget.dart';
import './widgets/statistics_bar_widget.dart';
import './widgets/task_section_widget.dart';

class MainTaskDashboard extends StatefulWidget {
  const MainTaskDashboard({Key? key}) : super(key: key);

  @override
  State<MainTaskDashboard> createState() => _MainTaskDashboardState();
}

class _MainTaskDashboardState extends State<MainTaskDashboard>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TaskManager _taskManager = TaskManager.instance;
  bool _isRefreshing = false;
  bool _isLoading = true;

  // User data
  final String _userName = "User";

  // Task data - now loaded from TaskManager
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _overdueTasks = [];
  List<Task> _upcomingTasks = [];
  List<Task> _completedTasks = [];
  int _completionStreak = 0;
  double _todayProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTasks();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _taskManager.init();
      _allTasks = await _taskManager.getAllTasks();
      _todayTasks = await _taskManager.getTodayTasks();
      _overdueTasks = await _taskManager.getOverdueTasks();
      _upcomingTasks = await _taskManager.getUpcomingTasks();
      _completedTasks = await _taskManager.getCompletedTasks();
      _completionStreak = await _taskManager.getCompletionStreak();
      _todayProgress = await _taskManager.getTodayProgress();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onScroll() {
    // Handle scroll events for potential future features
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Reload tasks from storage
    await _loadTasks();

    setState(() {
      _isRefreshing = false;
    });

    HapticFeedback.mediumImpact();
  }

  void _onTaskTap(Task task) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/add-edit-task',
      arguments: task,
    ).then((_) => _loadTasks()); // Reload after returning
  }

  Future<void> _onTaskComplete(Task task) async {
    await _taskManager.toggleTaskCompletion(task.id);
    HapticFeedback.mediumImpact();
    await _loadTasks();
  }

  Future<void> _onTaskDelete(Task task) async {
    await _taskManager.deleteTask(task.id);
    HapticFeedback.heavyImpact();
    await _loadTasks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.title}" deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await _taskManager.addTask(task);
              await _loadTasks();
            },
          ),
        ),
      );
    }
  }

  void _onTaskEdit(Task task) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/add-edit-task',
      arguments: task,
    ).then((_) => _loadTasks()); // Reload after returning
  }

  void _onSearchTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/search-and-filter');
  }

  void _onProfileTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/settings-and-preferences');
  }

  void _onAddTask() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/add-edit-task')
        .then((_) => _loadTasks()); // Reload after returning
  }

  void _onVoiceInput() {
    HapticFeedback.mediumImpact();
    // Voice input functionality can be implemented later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input feature coming soon!'),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        HapticFeedback.lightImpact();
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Navigator.pushNamed(context, '/task-list-view')
                .then((_) => _loadTasks());
            break;
          case 2:
            Navigator.pushNamed(context, '/calendar-view')
                .then((_) => _loadTasks());
            break;
          case 3:
            Navigator.pushNamed(context, '/analytics-dashboard');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'list',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Analytics',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    final hasAnyTasks = _todayTasks.isNotEmpty ||
        _overdueTasks.isNotEmpty ||
        _upcomingTasks.isNotEmpty ||
        _completedTasks.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: hasAnyTasks
            ? RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          DashboardHeaderWidget(
                            userName: _userName,
                            onSearchTap: _onSearchTap,
                            onProfileTap: _onProfileTap,
                          ),
                          StatisticsBarWidget(
                            completionStreak: _completionStreak,
                            todayProgress: _todayProgress,
                            completedTasks: _completedTasks.length,
                            totalTasks: _allTasks.length,
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        _overdueTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Overdue',
                                tasks: _overdueTasks
                                    .map((task) => _taskToMap(task))
                                    .toList(),
                                accentColor: const Color(0xFFDC2626),
                                onTaskTap: (taskMap) =>
                                    _onTaskTap(_mapToTask(taskMap)),
                                onTaskComplete: (taskMap) =>
                                    _onTaskComplete(_mapToTask(taskMap)),
                                onTaskDelete: (taskMap) =>
                                    _onTaskDelete(_mapToTask(taskMap)),
                                onTaskEdit: (taskMap) =>
                                    _onTaskEdit(_mapToTask(taskMap)),
                              )
                            : const SizedBox.shrink(),
                        _todayTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Today',
                                tasks: _todayTasks
                                    .map((task) => _taskToMap(task))
                                    .toList(),
                                accentColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                onTaskTap: (taskMap) =>
                                    _onTaskTap(_mapToTask(taskMap)),
                                onTaskComplete: (taskMap) =>
                                    _onTaskComplete(_mapToTask(taskMap)),
                                onTaskDelete: (taskMap) =>
                                    _onTaskDelete(_mapToTask(taskMap)),
                                onTaskEdit: (taskMap) =>
                                    _onTaskEdit(_mapToTask(taskMap)),
                              )
                            : const SizedBox.shrink(),
                        _upcomingTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Upcoming',
                                tasks: _upcomingTasks
                                    .map((task) => _taskToMap(task))
                                    .toList(),
                                accentColor: const Color(0xFFD97706),
                                onTaskTap: (taskMap) =>
                                    _onTaskTap(_mapToTask(taskMap)),
                                onTaskComplete: (taskMap) =>
                                    _onTaskComplete(_mapToTask(taskMap)),
                                onTaskDelete: (taskMap) =>
                                    _onTaskDelete(_mapToTask(taskMap)),
                                onTaskEdit: (taskMap) =>
                                    _onTaskEdit(_mapToTask(taskMap)),
                              )
                            : const SizedBox.shrink(),
                        _completedTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Recently Completed',
                                tasks: _completedTasks
                                    .take(5)
                                    .map((task) => _taskToMap(task))
                                    .toList(),
                                accentColor: const Color(0xFF4CAF50),
                                onTaskTap: (taskMap) =>
                                    _onTaskTap(_mapToTask(taskMap)),
                                onTaskComplete: (taskMap) =>
                                    _onTaskComplete(_mapToTask(taskMap)),
                                onTaskDelete: (taskMap) =>
                                    _onTaskDelete(_mapToTask(taskMap)),
                                onTaskEdit: (taskMap) =>
                                    _onTaskEdit(_mapToTask(taskMap)),
                              )
                            : const SizedBox.shrink(),
                        SizedBox(height: 10.h), // Space for FAB
                      ]),
                    ),
                  ],
                ),
              )
            : EmptyStateWidget(
                title: 'Welcome to TaskFlow Pro!',
                subtitle:
                    'Start organizing your life by adding your first task. Tap the button below to get started.',
                buttonText: 'Add Your First Task',
                onButtonTap: _onAddTask,
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: QuickAddFabWidget(
        onAddTask: _onAddTask,
        onVoiceInput: _onVoiceInput,
      ),
    );
  }

  // Helper methods to convert between Task objects and Maps for compatibility
  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'category': task.category,
      'dueDate': task.dueDate,
      'isCompleted': task.isCompleted,
    };
  }

  Task _mapToTask(Map<String, dynamic> taskMap) {
    return Task(
      id: taskMap['id'].toString(),
      title: taskMap['title'] ?? '',
      description: taskMap['description'] ?? '',
      priority: taskMap['priority'] ?? 'medium',
      category: taskMap['category'] ?? 'general',
      dueDate: taskMap['dueDate'] as DateTime?,
      isCompleted: taskMap['isCompleted'] ?? false,
    );
  }
}
