import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/task_manager.dart';
import './widgets/task_form_widget.dart';

class AddEditTask extends StatefulWidget {
  const AddEditTask({Key? key}) : super(key: key);

  @override
  State<AddEditTask> createState() => _AddEditTaskState();
}

class _AddEditTaskState extends State<AddEditTask> {
  final TaskManager _taskManager = TaskManager.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  String _priority = 'medium';
  DateTime? _dueDate;
  Task? _editingTask;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();

    // Initialize TaskManager
    _taskManager.init();

    // Check if we received a task to edit after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Task) {
        _editingTask = arguments;
        _populateFields();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _populateFields() {
    if (_editingTask != null) {
      _titleController.text = _editingTask!.title;
      _descriptionController.text = _editingTask!.description;
      _categoryController.text = _editingTask!.category;
      _priority = _editingTask!.priority;
      _dueDate = _editingTask!.dueDate;
      setState(() {});
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        id: _editingTask?.id ?? _taskManager.generateTaskId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        dueDate: _dueDate,
        isCompleted: _editingTask?.isCompleted ?? false,
      );

      if (_editingTask != null) {
        await _taskManager.updateTask(task);
      } else {
        await _taskManager.addTask(task);
      }

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingTask != null
                ? 'Task updated successfully!'
                : 'Task created successfully!'),
            backgroundColor: AppTheme.getSuccessColor(true),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    if (_editingTask == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content:
            Text('Are you sure you want to delete "${_editingTask!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _taskManager.deleteTask(_editingTask!.id);
        HapticFeedback.heavyImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully!'),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting task: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_editingTask != null ? 'Edit Task' : 'Add New Task'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_editingTask != null)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _isLoading ? null : _deleteTask,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: TaskFormWidget(
                  task: _editingTask != null ? {
                    'id': _editingTask!.id,
                    'title': _editingTask!.title,
                    'description': _editingTask!.description,
                    'priority': _editingTask!.priority,
                    'category': _editingTask!.category,
                    'dueDate': _editingTask!.dueDate,
                    'isCompleted': _editingTask!.isCompleted,
                  } : null,
                  onSave: (taskData) async {
                    // Convert taskData back to Task object and save
                    final task = Task(
                      id: taskData['id'] ?? _taskManager.generateTaskId(),
                      title: taskData['title'],
                      description: taskData['description'],
                      priority: taskData['priority'],
                      category: taskData['category'],
                      dueDate: taskData['dueDate'],
                      isCompleted: taskData['isCompleted'] ?? false,
                    );

                    try {
                      if (_editingTask != null) {
                        await _taskManager.updateTask(task);
                      } else {
                        await _taskManager.addTask(task);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_editingTask != null
                                ? 'Task updated successfully!'
                                : 'Task created successfully!'),
                            backgroundColor: AppTheme.getSuccessColor(true),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving task: ${e.toString()}'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_editingTask != null ? 'Update Task' : 'Create Task'),
          ),
        ),
      ),
    );
  }
}