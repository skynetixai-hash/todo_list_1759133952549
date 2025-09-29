import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';
import './widgets/task_card_widget.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({Key? key}) : super(key: key);

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allTasks = []; // start empty
  List<Map<String, dynamic>> _filteredTasks = [];
  Map<String, dynamic> _activeFilters = {};
  String _sortBy = 'dueDate';
  bool _sortAscending = true;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _applyFiltersAndSort(); // just to initialize filtered list
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_allTasks);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        final title = (task['title'] as String? ?? '').toLowerCase();
        final description =
            (task['description'] as String? ?? '').toLowerCase();
        return title.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Additional filters can stay, they'll just act on empty list

    // Sorting (optional)
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'dueDate':
          final aDate = a['dueDate'] as DateTime?;
          final bDate = b['dueDate'] as DateTime?;
          if (aDate != null && bDate != null) comparison = aDate.compareTo(bDate);
          break;
        case 'priority':
          final priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
          final aPriority = priorityOrder[a['priority'] as String? ?? 'Low'] ?? 0;
          final bPriority = priorityOrder[b['priority'] as String? ?? 'Low'] ?? 0;
          comparison = aPriority.compareTo(bPriority);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTasks = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSortBy: _sortBy,
        currentSortAscending: _sortAscending,
        onSortChanged: (sortBy, ascending) {
          setState(() {
            _sortBy = sortBy;
            _sortAscending = ascending;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchController.clear();
      _searchQuery = '';
      _applyFiltersAndSort();
    });
  }

  bool get _hasActiveFilters {
    return _activeFilters.isNotEmpty || _searchQuery.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/settings-and-preferences'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search tasks...',
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: CustomIconWidget(
                                iconName: 'search',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                    icon: CustomIconWidget(
                                      iconName: 'close',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      size: 20,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      decoration: BoxDecoration(
                        color: _hasActiveFilters
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasActiveFilters
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: CustomIconWidget(
                          iconName: 'filter_list',
                          color: _hasActiveFilters
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_hasActiveFilters) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_filteredTasks.length} task${_filteredTasks.length != 1 ? 's' : ''} found',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAllFilters,
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? EmptyStateWidget(
                    hasActiveFilters: _hasActiveFilters,
                    onClearFilters: _clearAllFilters,
                    onCreateTask: () =>
                        Navigator.pushNamed(context, '/add-edit-task'),
                  )
                : RefreshIndicator(
                    onRefresh: () async {},
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return TaskCardWidget(
                          task: task,
                          onTap: () =>
                              Navigator.pushNamed(context, '/add-edit-task'),
                          onComplete: () {},
                          onDelete: () {},
                          onSnooze: () {},
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-edit-task'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
