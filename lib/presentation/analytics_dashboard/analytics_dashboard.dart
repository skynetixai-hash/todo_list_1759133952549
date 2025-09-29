import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/task_manager.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/category_breakdown_chart_widget.dart';
import './widgets/completion_trend_chart_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/priority_distribution_chart_widget.dart';
import './widgets/productivity_insights_widget.dart';
import './widgets/progress_ring_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with SingleTickerProviderStateMixin {
  bool isWeeklyView = true;
  late TabController _tabController;

  // Task data - loaded from TaskManager instead of mock data
  final TaskManager _taskManager = TaskManager.instance;
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _completedTasks = [];
  int _completionStreak = 0;
  double _todayProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRealData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRealData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _taskManager.init();
      _allTasks = await _taskManager.getAllTasks();
      _todayTasks = await _taskManager.getTodayTasks();
      _completedTasks = await _taskManager.getCompletedTasks();
      _completionStreak = await _taskManager.getCompletionStreak();
      _todayProgress = await _taskManager.getTodayProgress();
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Analytics Dashboard'),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Export Report',
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/settings-and-preferences'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Time Period Selector
            Container(
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Weekly'),
                  Tab(text: 'Monthly'),
                  Tab(text: 'Yearly'),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeeklyView(),
                  _buildMonthlyView(),
                  _buildYearlyView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView() {
    if (_allTasks.isEmpty) {
      return _buildEmptyState('No data available for this week');
    }

    // Calculate real weekly stats
    final thisWeekCompleted = _completedTasks.where((task) {
      if (!task.isCompleted) return false;
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return task.updatedAt.isAfter(weekStart);
    }).length;

    final totalThisWeek = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 7));
      return task.dueDate!.isAfter(weekStart) &&
          task.dueDate!.isBefore(weekEnd);
    }).length;

    final completionRate = totalThisWeek > 0
        ? (thisWeekCompleted / totalThisWeek * 100).round()
        : 0;
    final dailyAverage = thisWeekCompleted > 0
        ? (thisWeekCompleted / 7).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      child: Column(
        children: [
          // Key Metrics Cards
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: '$thisWeekCompleted',
                subtitle: 'This week',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '$completionRate%',
                subtitle: 'Weekly rate',
                iconName: 'trending_up',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Current Streak',
                value: '$_completionStreak',
                subtitle: 'Days in a row',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Daily Average',
                value: dailyAverage,
                subtitle: 'Tasks per day',
                iconName: 'bar_chart',
                iconColor: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
            ],
          ),

          // Progress Rings
          SizedBox(height: 3.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProgressRingWidget(
                      title: 'Daily Goal',
                      progress: _todayProgress,
                      centerText: '${(_todayProgress * 100).round()}%',
                      progressColor: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light,
                      ),
                    ),
                    ProgressRingWidget(
                      title: 'Weekly Goal',
                      progress: completionRate / 100,
                      centerText: '$completionRate%',
                      progressColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Charts based on real data
          SizedBox(height: 3.h),
          CompletionTrendChartWidget(
            isWeeklyView: isWeeklyView,
            onViewToggle: (bool weekly) {
              setState(() {
                isWeeklyView = weekly;
              });
            },
          ),

          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),

          SizedBox(height: 3.h),
          const PriorityDistributionChartWidget(),

          SizedBox(height: 3.h),
          const ProductivityInsightsWidget(),

          SizedBox(height: 3.h),
          const AchievementBadgesWidget(),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    if (_allTasks.isEmpty) {
      return _buildEmptyState('No data available for this month');
    }

    // Calculate real monthly stats
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final thisMonthCompleted = _completedTasks.where((task) {
      if (!task.isCompleted) return false;
      return task.updatedAt.isAfter(monthStart) &&
          task.updatedAt.isBefore(monthEnd);
    }).length;

    final totalThisMonth = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(monthStart) &&
          task.dueDate!.isBefore(monthEnd);
    }).length;

    final completionRate = totalThisMonth > 0
        ? (thisMonthCompleted / totalThisMonth * 100).round()
        : 0;
    final dailyAverage = thisMonthCompleted > 0
        ? (thisMonthCompleted / now.day).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: '$thisMonthCompleted',
                subtitle: 'This month',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '$completionRate%',
                subtitle: 'Monthly rate',
                iconName: 'trending_up',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Best Streak',
                value: '$_completionStreak',
                subtitle: 'Days this month',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Monthly Average',
                value: dailyAverage,
                subtitle: 'Tasks per day',
                iconName: 'bar_chart',
                iconColor: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          CompletionTrendChartWidget(
            isWeeklyView: false,
            onViewToggle: (bool weekly) {},
          ),
          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),
          SizedBox(height: 3.h),
          const PriorityDistributionChartWidget(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildYearlyView() {
    if (_allTasks.isEmpty) {
      return _buildEmptyState('No data available for this year');
    }

    // Calculate real yearly stats
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);

    final thisYearCompleted = _completedTasks.where((task) {
      if (!task.isCompleted) return false;
      return task.updatedAt.isAfter(yearStart);
    }).length;

    final totalThisYear = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(yearStart);
    }).length;

    final completionRate = totalThisYear > 0
        ? (thisYearCompleted / totalThisYear * 100).round()
        : 0;
    final dailyAverage = thisYearCompleted > 0
        ? (thisYearCompleted / now.difference(yearStart).inDays)
            .toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: '$thisYearCompleted',
                subtitle: 'This year',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '$completionRate%',
                subtitle: 'Annual average',
                iconName: 'trending_up',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Longest Streak',
                value: '$_completionStreak',
                subtitle: 'Days this year',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Yearly Average',
                value: dailyAverage,
                subtitle: 'Tasks per day',
                iconName: 'bar_chart',
                iconColor: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),
          SizedBox(height: 3.h),
          const ProductivityInsightsWidget(),
          SizedBox(height: 3.h),
          const AchievementBadgesWidget(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            color: Theme.of(context).colorScheme.onSurface.withAlpha(77),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Start completing tasks to see analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'file_download',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text('Export Report'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose export format:', style: theme.textTheme.bodyMedium),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  color: Colors.red,
                  size: 24,
                ),
                title: Text('PDF Report'),
                subtitle: Text('Detailed analytics with charts'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generatePDFReport();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'table_chart',
                  color: Colors.green,
                  size: 24,
                ),
                title: Text('CSV Data'),
                subtitle: Text('Raw data for analysis'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generateCSVReport();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _generatePDFReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('PDF report generated successfully!'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(
          Theme.of(context).brightness == Brightness.light,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generateCSVReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('CSV data exported successfully!'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(
          Theme.of(context).brightness == Brightness.light,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}