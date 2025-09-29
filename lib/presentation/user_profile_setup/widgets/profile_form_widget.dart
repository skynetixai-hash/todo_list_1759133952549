import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final String? selectedImagePath;
  final VoidCallback? onImageTap;

  const ProfileFormWidget({
    Key? key,
    required this.nameController,
    this.selectedImagePath,
    this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Your Profile',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'Tell us a bit about yourself to personalize your experience',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 6.h),

          // Profile photo section
          Center(
            child: GestureDetector(
              onTap: onImageTap,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(58),
                        child: Image.file(
                          File(selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'person_add',
                            color: theme.colorScheme.primary,
                            size: 40,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Add Photo',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          Center(
            child: Text(
              selectedImagePath != null
                  ? 'Tap to change photo'
                  : 'Optional - Tap to add a profile photo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Name input section
          Text(
            'Your Name *',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.0),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.onSurface.withAlpha(128),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            textInputAction: TextInputAction.done,
            style: theme.textTheme.bodyLarge,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          Text(
            '* Required field',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),

          SizedBox(height: 4.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Your information is stored securely on your device and is never shared with third parties.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
