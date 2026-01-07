// lib/widgets/main_app_shell.dart (FINAL CODE: Provider integration AND Guest Fix)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import the core feature screens
import '../screens/health_monitor_screen.dart';
import 'package:medtrack_app/screens/pill_reminder_screen.dart';
import 'package:medtrack_app/screens/timer_screen.dart';
import 'package:medtrack_app/screens/scheduling_screen.dart';
import '../screens/settings_screen.dart';
import '../models/focus_timer_state_model.dart';

class MainAppShell extends StatefulWidget {
  final bool isGuest;
  const MainAppShell({super.key, required this.isGuest});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      PillReminderScreen(isGuest: widget.isGuest), // Index 0: Reminders
      const HealthMonitorScreen(), // Index 1: Monitor
      // Index 2: Focus Timer (Wrapped with its own state model)
      ChangeNotifierProvider(
        create: (context) => FocusTimerStateModel(),
        child: const TimerScreen(),
      ),

      const SchedulingScreen(), // Index 3: Care/Sched
      const SettingsScreen(), // Index 4: Settings
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the screen corresponding to the selected index
      body: _widgetOptions.elementAt(_selectedIndex),

      // FIX: Conditionally hide the BottomNavigationBar if the user is a guest.
      bottomNavigationBar: widget.isGuest
          ? null // Return null to hide the navigation bar in guest mode
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time_filled),
                  label: 'Reminders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monitor_heart),
                  label: 'Monitor',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer_outlined),
                  label: 'Focus Timer',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt),
                  label: 'Care/Sched',
                ),
                // 3. NEW NAVIGATION ITEM: Settings
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              currentIndex: _selectedIndex,
              // Customize appearance
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              // Ensure all labels are visible for 5 items
              type: BottomNavigationBarType.fixed,
              // Handle tab selection
              onTap: _onItemTapped,
            ),
    );
  }
}
