import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationPermissionWidget extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPermissionRequest;

  const NotificationPermissionWidget({
    Key? key,
    required this.isEnabled,
    this.onPermissionRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Notification icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      .withAlpha(26)
                  : theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: isEnabled
                    ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        .withAlpha(77)
                    : theme.colorScheme.primary.withAlpha(77),
                width: 2,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: isEnabled ? 'notifications_active' : 'notifications',
                color: isEnabled
                    ? AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    : theme.colorScheme.primary,
                size: 64,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            isEnabled ? 'Notifications Enabled!' : 'Enable Push Notifications',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isEnabled
                  ? AppTheme.getSuccessColor(
                      theme.brightness == Brightness.light)
                  : theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            isEnabled
                ? 'Perfect! You\'ll receive important reminders and task notifications.'
                : 'Stay on top of your tasks with timely reminders and alerts.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 6.h),

          // Benefits list
          _buildBenefitItem(
            context,
            'schedule',
            'Due Date Reminders',
            'Get notified before task deadlines',
            isEnabled,
          ),

          SizedBox(height: 3.h),

          _buildBenefitItem(
            context,
            'warning',
            'Overdue Alerts',
            'Never miss important tasks',
            isEnabled,
          ),

          SizedBox(height: 3.h),

          _buildBenefitItem(
            context,
            'today',
            'Daily Summary',
            'Review your daily progress',
            isEnabled,
          ),

          SizedBox(height: 6.h),

          if (!isEnabled) ...[
            ElevatedButton.icon(
              onPressed: onPermissionRequest,
              icon: CustomIconWidget(
                iconName: 'notifications_active',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Enable Push Notifications'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'You can change this later in Settings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    .withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      .withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light),
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'All set! You\'ll receive push notifications for important task updates.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String iconName,
    String title,
    String subtitle,
    bool isEnabled,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isEnabled
                    ? AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    : theme.colorScheme.primary)
                .withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: isEnabled
                  ? AppTheme.getSuccessColor(
                      theme.brightness == Brightness.light)
                  : theme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
        if (isEnabled)
          CustomIconWidget(
            iconName: 'check_circle',
            color:
                AppTheme.getSuccessColor(theme.brightness == Brightness.light),
            size: 20,
          ),
      ],
    );
  }
}
