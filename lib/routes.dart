import 'package:flutter/material.dart';

// Import all necessary screens and the shell widget
import 'package:medtrack_app/screens/welcome_screen.dart';
import 'package:medtrack_app/widgets/main_app_shell.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/health_monitor_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/scheduling_screen.dart';
import 'screens/settings_screen.dart'; 

class AppRoutes {
  // --- Route Name Constants ---
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String mainAppShell = '/mainAppShell';
  static const String pillReminder = '/pill_reminder';
  static const String guestMode = '/guest_pill_reminder';
  static const String healthMonitor = '/health_monitor';
  static const String focusTimer = '/focus_timer';
  static const String scheduling = '/scheduling';
  static const String settings = '/settings';

  // --- Centralized Route Map ---
  static Map<String, WidgetBuilder> get routes => {
    signup: (context) => const SignupScreen(),
    login: (context) => const LoginScreen(),
    healthMonitor: (context) => const HealthMonitorScreen(),
    focusTimer: (context) => const TimerScreen(),
    scheduling: (context) => const SchedulingScreen(),
    settings: (context) => const SettingsScreen(),
    
    // Main Shell Wrappers
    pillReminder: (context) => const MainAppShell(isGuest: false),
    guestMode: (context) => const MainAppShell(isGuest: true),
    mainAppShell: (context) => const MainAppShell(isGuest: false),
  };
} // This is the closing brace the compiler was missing!