// lib/routes.dart (FINAL FIXED VERSION)

import 'package:flutter/material.dart';

// Import all necessary screens and the shell widget
import 'package:medtrack_app/screens/welcome_screen.dart';
import 'package:medtrack_app/widgets/main_app_shell.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/health_monitor_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/scheduling_screen.dart';
import 'screens/settings_screen.dart'; // REQUIRED: New Settings Import

class AppRoutes {
  // --- Route Name Constants ---
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String login = '/login';

  // These routes now point to the MainAppShell wrapper
  static const String pillReminder =
      '/pill_reminder'; // Authenticated User Home
  static const String guestMode = '/guest_pill_reminder'; // Guest User Home

  static const String healthMonitor = '/health_monitor';
  static const String focusTimer = '/focus_timer';
  static const String scheduling = '/scheduling';
  static const String settings = '/settings'; // REQUIRED: New Settings Route

  // --- Centralized Route Map ---
  static Map<String, WidgetBuilder> get routes => {
    // Mapping the route names to the actual screen widgets
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const SignupScreen(),
    login: (context) => const LoginScreen(),

    // Direct Screen Mappings (for testing/deep links)
    healthMonitor: (context) => const HealthMonitorScreen(),
    focusTimer: (context) => const TimerScreen(),
    scheduling: (context) => const SchedulingScreen(),
    settings: (context) =>
        const SettingsScreen(), // REQUIRED: New Settings Mapping
    // Main Shell Wrappers (Home)
    pillReminder: (context) => const MainAppShell(isGuest: false),
    guestMode: (context) => const MainAppShell(isGuest: true),
  };
}
