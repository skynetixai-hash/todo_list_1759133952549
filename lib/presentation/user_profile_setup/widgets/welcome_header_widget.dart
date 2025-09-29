import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const WelcomeHeaderWidget({
    Key? key,
    this.onGetStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'task_alt',
                color: theme.colorScheme.onPrimary,
                size: 64,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Welcome message
          Text(
            'Welcome to TaskFlow Pro!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'Your ultimate productivity companion for organizing and tracking tasks efficiently.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Feature highlights
          _buildFeatureItem(
            context,
            'task_alt',
            'Smart Task Management',
            'Organize your tasks with priorities and categories',
          ),

          SizedBox(height: 2.h),

          _buildFeatureItem(
            context,
            'notifications_active',
            'Push Notifications',
            'Never miss important deadlines and reminders',
          ),

          SizedBox(height: 2.h),

          _buildFeatureItem(
            context,
            'analytics',
            'Progress Analytics',
            'Track your productivity with detailed insights',
          ),

          SizedBox(height: 6.h),

          Text(
            'Let\'s set up your profile to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withAlpha(204),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String iconName,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.primary,
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
      ],
    );
  }
}
