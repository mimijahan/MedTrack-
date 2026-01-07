import 'package:flutter/material.dart';

// Import the core feature screens
import '../screens/health_monitor_screen.dart';
import 'package:medtrack_app/screens/pill_reminder_screen.dart';
import 'package:medtrack_app/screens/timer_screen.dart';
// 1. New Import: The top-level screen for Feature 7
import 'package:medtrack_app/screens/scheduling_screen.dart';

class MainAppShell extends StatefulWidget {
  final bool isGuest;

  const MainAppShell({super.key, required this.isGuest});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  // Now 4 indices: 0, 1, 2, 3
  int _selectedIndex = 0;

  // List of screens available in the Bottom Navigation Bar
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // 2. Add the SchedulingScreen to the list of major screens
    _widgetOptions = <Widget>[
      PillReminderScreen(isGuest: widget.isGuest), // Index 0: Reminders
      const HealthMonitorScreen(), // Index 1: Monitor
      const TimerScreen(), // Index 2: Focus Timer
      const SchedulingScreen(), // Index 3: Complex Scheduling (The SCREEN)
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
      // Display the selected screen
      body: _widgetOptions.elementAt(_selectedIndex),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
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
          // 3. Add the new navigation item for the SchedulingScreen
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Care/Sched',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
