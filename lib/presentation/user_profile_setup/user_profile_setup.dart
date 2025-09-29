
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/notification_permission_widget.dart';
import './widgets/profile_form_widget.dart';
import './widgets/welcome_header_widget.dart';

class UserProfileSetup extends StatefulWidget {
  const UserProfileSetup({Key? key}) : super(key: key);

  @override
  State<UserProfileSetup> createState() => _UserProfileSetupState();
}

class _UserProfileSetupState extends State<UserProfileSetup>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _currentStep = 0;
  String? _selectedImagePath;
  bool _notificationsEnabled = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
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

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Choose Profile Photo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  'Camera',
                  'camera_alt',
                  () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImagePath = image.path;
                      });
                    }
                  },
                ),
                _buildImageOption(
                  'Gallery',
                  'photo_library',
                  () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImagePath = image.path;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(String title, String iconName, VoidCallback onTap) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(77),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermissions() async {
    final PermissionStatus status = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = status == PermissionStatus.granted;
    });
  }

  Future<void> _completeSetup() async {
    if (_nameController.text.trim().isEmpty) {
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
              Text('Please enter your name to continue'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      // Save profile data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setBool('profile_setup_complete', true);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);

      if (_selectedImagePath != null) {
        await prefs.setString('profile_image_path', _selectedImagePath!);
      }

      // Show completion success
      if (_notificationsEnabled) {
        await _flutterLocalNotificationsPlugin.show(
          0,
          'Welcome to TaskFlow Pro!',
          'Your profile has been set up successfully. Start organizing your tasks now!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'taskflow_welcome_channel',
              'TaskFlow Welcome Notifications',
              channelDescription: 'Welcome notifications for new users',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }

      // Navigate to main dashboard after short delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main-task-dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Failed to complete setup. Please try again.'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // Prevent back navigation until setup is complete
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withAlpha(51),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(),
                    _buildProfileStep(),
                    _buildNotificationStep(),
                  ],
                ),
              ),

              // Navigation buttons
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isCompleting ? null : _previousStep,
                          child: Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: 4.w),
                    Expanded(
                      flex: _currentStep == 0 ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _isCompleting
                            ? null
                            : () {
                                if (_currentStep == 2) {
                                  _completeSetup();
                                } else {
                                  _nextStep();
                                }
                              },
                        child: _isCompleting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(_currentStep == 2
                                ? 'Complete Setup'
                                : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return WelcomeHeaderWidget(
      onGetStarted: _nextStep,
    );
  }

  Widget _buildProfileStep() {
    return ProfileFormWidget(
      nameController: _nameController,
      selectedImagePath: _selectedImagePath,
      onImageTap: _selectImage,
    );
  }

  Widget _buildNotificationStep() {
    return NotificationPermissionWidget(
      isEnabled: _notificationsEnabled,
      onPermissionRequest: _requestNotificationPermissions,
    );
  }
}
