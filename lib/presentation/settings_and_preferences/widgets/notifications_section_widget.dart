import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationsSectionWidget extends StatefulWidget {
  final bool dueDateReminders;
  final bool overdueTaskAlerts;
  final bool dailySummary;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final Function(bool) onDueDateChanged;
  final Function(bool) onOverdueChanged;
  final Function(bool) onDailySummaryChanged;
  final Function(TimeOfDay) onQuietHoursStartChanged;
  final Function(TimeOfDay) onQuietHoursEndChanged;

  const NotificationsSectionWidget({
    Key? key,
    required this.dueDateReminders,
    required this.overdueTaskAlerts,
    required this.dailySummary,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.onDueDateChanged,
    required this.onOverdueChanged,
    required this.onDailySummaryChanged,
    required this.onQuietHoursStartChanged,
    required this.onQuietHoursEndChanged,
  }) : super(key: key);

  @override
  State<NotificationsSectionWidget> createState() =>
      _NotificationsSectionWidgetState();
}

class _NotificationsSectionWidgetState
    extends State<NotificationsSectionWidget> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Check notification permissions
    _checkNotificationPermissions();
  }

  Future<void> _checkNotificationPermissions() async {
    final bool isGranted = await Permission.notification.isGranted;
    setState(() {
      _notificationsEnabled = isGranted;
    });
  }

  Future<void> _requestNotificationPermissions() async {
    final PermissionStatus status = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = status == PermissionStatus.granted;
    });

    if (status == PermissionStatus.granted) {
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
              Text('Push notifications enabled!'),
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

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Push Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),

          // Push Notification Permission
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _notificationsEnabled
                  ? AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      .withAlpha(26)
                  : theme.colorScheme.error.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _notificationsEnabled
                    ? AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    : theme.colorScheme.error,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: _notificationsEnabled ? 'check_circle' : 'warning',
                  color: _notificationsEnabled
                      ? AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      : theme.colorScheme.error,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _notificationsEnabled
                            ? 'Push Notifications Enabled'
                            : 'Push Notifications Disabled',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _notificationsEnabled
                              ? AppTheme.getSuccessColor(
                                  theme.brightness == Brightness.light)
                              : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        _notificationsEnabled
                            ? 'You will receive task reminders and alerts'
                            : 'Enable to receive important task notifications',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!_notificationsEnabled)
                  ElevatedButton(
                    onPressed: _requestNotificationPermissions,
                    child: Text('Enable'),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor),

          _buildNotificationToggle(
            'Due Date Reminders',
            'Get notified when tasks are due',
            'schedule',
            widget.dueDateReminders,
            widget.onDueDateChanged,
            enabled: _notificationsEnabled,
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildNotificationToggle(
            'Overdue Task Alerts',
            'Alerts for tasks past their due date',
            'warning',
            widget.overdueTaskAlerts,
            widget.onOverdueChanged,
            enabled: _notificationsEnabled,
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildNotificationToggle(
            'Daily Summary',
            'Daily overview of your tasks',
            'today',
            widget.dailySummary,
            widget.onDailySummaryChanged,
            enabled: _notificationsEnabled,
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildQuietHoursSection(),
          Divider(height: 1, color: theme.dividerColor),
          _buildTestNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    String iconName,
    bool value,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: iconName,
        color: enabled
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withAlpha(102),
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled ? null : theme.colorScheme.onSurface.withAlpha(102),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: enabled ? null : theme.colorScheme.onSurface.withAlpha(102),
        ),
      ),
      trailing: Switch(
        value: enabled ? value : false,
        onChanged: enabled ? onChanged : null,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'bedtime',
                color: _notificationsEnabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withAlpha(102),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Quiet Hours',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _notificationsEnabled
                      ? null
                      : theme.colorScheme.onSurface.withAlpha(102),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'No notifications during these hours',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _notificationsEnabled
                  ? null
                  : theme.colorScheme.onSurface.withAlpha(102),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  'Start',
                  widget.quietHoursStart,
                  widget.onQuietHoursStartChanged,
                  enabled: _notificationsEnabled,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTimeSelector(
                  'End',
                  widget.quietHoursEnd,
                  widget.onQuietHoursEndChanged,
                  enabled: _notificationsEnabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged, {
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled
          ? () async {
              final TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (selectedTime != null) {
                onChanged(selectedTime);
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? theme.dividerColor
                : theme.dividerColor.withAlpha(102),
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? null : theme.colorScheme.surface.withAlpha(128),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color:
                    enabled ? null : theme.colorScheme.onSurface.withAlpha(102),
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              time.format(context),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color:
                    enabled ? null : theme.colorScheme.onSurface.withAlpha(102),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _notificationsEnabled ? _showTestNotification : null,
          icon: CustomIconWidget(
            iconName: 'notifications_active',
            color: _notificationsEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withAlpha(102),
            size: 20,
          ),
          label: Text(
            'Send Test Push Notification',
            style: TextStyle(
              color: _notificationsEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withAlpha(102),
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            side: BorderSide(
              color: _notificationsEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withAlpha(102),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTestNotification() async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'taskflow_test_channel',
      'TaskFlow Test Notifications',
      channelDescription: 'Test notifications for TaskFlow Pro',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'TaskFlow Pro',
      'Test push notification sent successfully! 🎉',
      platformChannelSpecifics,
      payload: 'test_notification',
    );

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
            Text('Test push notification sent successfully!'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(
          Theme.of(context).brightness == Brightness.light,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
