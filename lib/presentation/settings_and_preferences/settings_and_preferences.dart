import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_section_widget.dart';
import './widgets/language_section_widget.dart';
import './widgets/notifications_section_widget.dart';
import './widgets/privacy_section_widget.dart';

class SettingsAndPreferences extends StatefulWidget {
  const SettingsAndPreferences({Key? key}) : super(key: key);

  @override
  State<SettingsAndPreferences> createState() => _SettingsAndPreferencesState();
}

class _SettingsAndPreferencesState extends State<SettingsAndPreferences> {
  // Notification settings
  bool _dueDateReminders = true;
  bool _overdueTaskAlerts = true;
  bool _dailySummary = false;
  TimeOfDay _quietHoursStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = TimeOfDay(hour: 7, minute: 0);

  // Account settings
  String _syncStatus = "Synced";
  DateTime _lastSyncTime = DateTime.now().subtract(Duration(minutes: 15));
  String _storageUsed = "2.3 MB";

  // Privacy settings
  bool _biometricAuth = false;
  String _dataRetention = "1_year";
  bool _analyticsEnabled = true;

  // Language settings
  String _currentLanguage = "en";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildUserProfileHeader(),
            SizedBox(height: 2.h),

            // Notifications Section (enhanced for push notifications)
            NotificationsSectionWidget(
              dueDateReminders: _dueDateReminders,
              overdueTaskAlerts: _overdueTaskAlerts,
              dailySummary: _dailySummary,
              quietHoursStart: _quietHoursStart,
              quietHoursEnd: _quietHoursEnd,
              onDueDateChanged: (value) =>
                  setState(() => _dueDateReminders = value),
              onOverdueChanged: (value) =>
                  setState(() => _overdueTaskAlerts = value),
              onDailySummaryChanged: (value) =>
                  setState(() => _dailySummary = value),
              onQuietHoursStartChanged: (time) =>
                  setState(() => _quietHoursStart = time),
              onQuietHoursEndChanged: (time) =>
                  setState(() => _quietHoursEnd = time),
            ),

            AccountSectionWidget(
              syncStatus: _syncStatus,
              lastSyncTime: _lastSyncTime,
              storageUsed: _storageUsed,
              onManualSync: _handleManualSync,
              onExportData: _handleExportData,
              onSignOut: _handleSignOut,
              onDeleteAccount: _handleDeleteAccount,
            ),
            PrivacySectionWidget(
              biometricAuth: _biometricAuth,
              dataRetention: _dataRetention,
              analyticsEnabled: _analyticsEnabled,
              onBiometricChanged: (value) =>
                  setState(() => _biometricAuth = value),
              onDataRetentionChanged: (value) =>
                  setState(() => _dataRetention = value),
              onAnalyticsChanged: (value) =>
                  setState(() => _analyticsEnabled = value),
            ),
            LanguageSectionWidget(
              currentLanguage: _currentLanguage,
              onLanguageChanged: (language) =>
                  setState(() => _currentLanguage = language),
            ),
            _buildAppInfoSection(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        'Settings',
        style: theme.appBarTheme.titleTextStyle,
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showHelpDialog,
          icon: CustomIconWidget(
            iconName: 'help_outline',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildUserProfileHeader() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaskFlow User',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'user@taskflow.app',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.getSuccessColor(
                            Theme.of(context).brightness == Brightness.light)
                        .withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Active User',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.getSuccessColor(
                          Theme.of(context).brightness == Brightness.light),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'edit',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
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
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'apps',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'App Version',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'TaskFlow Pro v1.0.0 (Build 2025.01.29)',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'feedback',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'Send Feedback',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Help us improve TaskFlow Pro',
              style: theme.textTheme.bodySmall,
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showFeedbackDialog,
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'star_rate',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'Rate App',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Rate us on the App Store',
              style: theme.textTheme.bodySmall,
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onTap: _handleRateApp,
          ),
        ],
      ),
    );
  }

  Future<void> _handleManualSync() async {
    setState(() {
      _syncStatus = "Syncing";
      _lastSyncTime = DateTime.now();
    });

    // Simulate sync process
    await Future.delayed(Duration(seconds: 2));

    setState(() => _syncStatus = "Synced");
  }

  void _handleExportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'download',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Data export started...'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _handleSignOut() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/user-profile-setup',
      (route) => false,
    );
  }

  void _handleDeleteAccount() {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Account deletion initiated'),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  void _showHelpDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'help',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with TaskFlow Pro?',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '• Check our FAQ section\n• Contact support team\n• Browse user guides\n• Join our community forum',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening support center...'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            child: Text('Get Help'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think about TaskFlow Pro...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text('Rate your experience:'),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: CustomIconWidget(
                      iconName: 'star_border',
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: AppTheme.getSuccessColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleRateApp() {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'star',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Opening App Store...'),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
