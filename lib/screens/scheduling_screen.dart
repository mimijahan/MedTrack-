// lib/screens/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/dependent_model.dart';
import '../widgets/dependent_switcher.dart';
import '../models/add_schedule_modal.dart'; // Import for ScheduleModal

// New Import: Dependent Add Modal (to be created)
import '../widgets/add_dependent_modal.dart';

// --- MAIN SCREEN WIDGET ---
class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  // --- STATE ---
  // --- STATE ---
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // --- REFACTORED: Start with 'Me' and no other mock dependents ---
  final List<Dependent> _dependents = [
    Dependent(
      id: 'self',
      name: 'Me',
      type: DependentType.person,
      initial: 'M',
      color: Colors.blue,
    ),
    // REMOVED MOCK DEPENDENTS (claire, luna, coco, mom)
  ];

  // The ID of the currently active dependent. Starts with 'self'.
  String _activeDependentId = 'self';

  // Master list of all schedules, keyed by dependent ID.
  final Map<String, List<ScheduleItem>> _schedules = {
    'self': [],
    // Removed mock schedules for 'claire', 'luna', 'coco', 'mom'
  };

  // --- Helper Getters ---

  // Gets the currently selected dependent object.
  Dependent get _activeDependent =>
      _dependents.firstWhere((dep) => dep.id == _activeDependentId);

  // Gets the schedules for the currently active dependent.
  List<ScheduleItem> _getActiveDependentSchedules() {
    return _schedules[_activeDependentId] ?? [];
  }

  // Gets the adherence logs for the currently active dependent.
  Map<DateTime, List<AdherenceLog>> _getActiveDependentAdherenceLogs() {
    // This is a placeholder as AdherenceLogs are not yet fully implemented.
    return {};
  }

  // --- Dependent & Schedule Management Logic ---

  // Handle dependent switch from DependentSwitcher widget
  void _onDependentChanged(String newId) {
    setState(() {
      _activeDependentId = newId;
    });
  }

  // Adds a new schedule item to the current dependent's list
  void _onScheduleAdded(ScheduleItem item) {
    setState(() {
      // Ensure a list exists for the dependent ID
      if (!_schedules.containsKey(item.dependentId)) {
        _schedules[item.dependentId] = [];
      }
      _schedules[item.dependentId]!.add(item);
    });
    Navigator.of(context).pop(); // Close the modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Schedule "${item.taskName}" added for ${_activeDependent.name}',
        ),
      ),
    );
  }

  // Opens the modal to add a new dependent
  void _openAddDependentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddDependentModal(onDependentAdded: _addNewDependent);
      },
    );
  }

  // The callback when a new dependent is created in the modal
  void _addNewDependent(Dependent newDependent) {
    setState(() {
      _dependents.add(newDependent);
      _schedules[newDependent.id] = []; // Initialize an empty schedule list
      _activeDependentId =
          newDependent.id; // Switch to the newly added dependent
    });
    Navigator.of(context).pop(); // Close the modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newDependent.name} added successfully!')),
    );
  }

  // Opens the modal to add a new schedule
  void _openAddScheduleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddScheduleModal(
          dependent: _activeDependent,
          onScheduleAdded: _onScheduleAdded,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Guard clause in case 'self' is somehow removed
    if (_dependents.isEmpty) {
      return const Center(
        child: Text('No user data. Please log in or restart.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care & Scheduling'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      // NEW: Floating Action Button to add a new schedule
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScheduleModal,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Dependent Switcher ---
            DependentSwitcher(
              dependents: _dependents,
              activeDependentId: _activeDependentId,
              onDependentChanged: _onDependentChanged,
            ),

            // NEW: Button to add a new dependent
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: OutlinedButton.icon(
                onPressed: _openAddDependentModal,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Add New Dependent'),
              ),
            ),

            // --- 2. Calendar View (History) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adherence History for ${_activeDependent.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          // In a real app, this would load logs for the selected day
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Day selected: ${DateFormat('MMM d, yyyy').format(selectedDay)}',
                              ),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        });
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      // Placeholder for actual Adherence Logs (markers)
                      eventLoader: (day) {
                        return _getActiveDependentAdherenceLogs()[DateTime(
                              day.year,
                              day.month,
                              day.day,
                            )] ??
                            [];
                      },
                      calendarStyle: CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. Active Schedules List ---
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Active Schedules for ${_activeDependent.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 10),

            // List of schedules
            if (_getActiveDependentSchedules().isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No active schedules for ${_activeDependent.name}. Tap + to add one!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._getActiveDependentSchedules().map(
                (schedule) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _activeDependent.color.withOpacity(
                          0.1,
                        ),
                        child: Icon(
                          Icons.access_alarm,
                          color: _activeDependent.color,
                        ),
                      ),
                      title: Text(
                        schedule.taskName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Starts at ${DateFormat('hh:mm a').format(schedule.startTime)} | Duration: ${schedule.durationDays} days',
                      ),
                      // NOTE: The extension for frequency.name is defined in add_schedule_modal.dart.
                      trailing: Text(
                        schedule.frequency.index == 0 ? 'Daily' : 'Interval',
                      ),
                      // Add action to view/edit
                      onTap: () {
                        // Placeholder for an edit/detail view
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tapped on ${schedule.taskName}'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
