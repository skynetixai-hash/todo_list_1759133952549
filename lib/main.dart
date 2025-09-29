import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import './widgets/custom_error_widget.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = '/';

  @override
  void initState() {
    super.initState();
    _checkProfileSetup();
  }

  Future<void> _checkProfileSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isSetupComplete =
          prefs.getBool('profile_setup_complete') ?? false;

      setState(() {
        _initialRoute = isSetupComplete ? '/main-task-dashboard' : '/';
      });
    } catch (e) {
      // If there's an error, default to profile setup
      setState(() {
        _initialRoute = '/';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'TaskFlow Pro',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light, // Removed dark mode
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: _initialRoute,
      );
    });
  }
}
