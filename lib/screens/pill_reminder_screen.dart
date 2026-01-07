// lib/screens/pill_reminder_screen.dart

import 'package:flutter/material.dart';

// --- Enums for Reporting ---
enum AdherenceStatus {
  takenOnTime, // Logged before or within a small window of scheduled time
  takenLate, // Logged after the grace period, but before the next day
  skipped, // Manually marked as skipped
  forgotten, // Automatically calculated (reminder time passed and not taken)
}

// --- Medication Log Data Model ---
class MedicationAdherenceLog {
  final String reminderId;
  final String medicationName;
  final DateTime scheduledTime;
  final DateTime loggedTime;
  final AdherenceStatus status;
  final int dosage; // New field to track dosage for the chart

  MedicationAdherenceLog({
    required this.reminderId,
    required this.medicationName,
    required this.scheduledTime,
    required this.loggedTime,
    required this.status,
    this.dosage = 1, // Default dosage of 1
  });

  // Helper to get the day key without time component
  DateTime get dateKey =>
      DateTime(loggedTime.year, loggedTime.month, loggedTime.day);
}

// --- Pill Reminder Data Model ---
class PillReminder {
  final String id; // NEW: Unique ID for linking to logs
  final String medicationName;
  final String schedule; // e.g., 'Daily', 'Weekly', 'Monthly', 'As Needed'
  final TimeOfDay time;
  final DateTime startDate;
  final int repeatDays;
  final int durationDays;
  final int dosage; // NEW: Dosage per reminder

  PillReminder({
    required this.id, // Must be required now
    required this.medicationName,
    required this.schedule,
    required this.time,
    required this.startDate,
    required this.repeatDays,
    required this.durationDays,
    this.dosage = 1, // Default to 1
  });

  // Helper to create a copy for editing
  PillReminder copyWith({
    String? medicationName,
    String? schedule,
    TimeOfDay? time,
    DateTime? startDate,
    int? repeatDays,
    int? durationDays,
    int? dosage,
  }) {
    return PillReminder(
      id: id,
      medicationName: medicationName ?? this.medicationName,
      schedule: schedule ?? this.schedule,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      repeatDays: repeatDays ?? this.repeatDays,
      durationDays: durationDays ?? this.durationDays,
      dosage: dosage ?? this.dosage,
    );
  }
}

// --- Pill Reminder Screen Widget ---
class PillReminderScreen extends StatefulWidget {
  final bool isGuest;
  // NEW: Make the logs static so the Report Screen can access the data
  static final List<MedicationAdherenceLog> adherenceLogs = [];

  const PillReminderScreen({super.key, required this.isGuest});

  @override
  State<PillReminderScreen> createState() => _PillReminderScreenState();
}

class _PillReminderScreenState extends State<PillReminderScreen> {
  // Simple UUID generator for mock data
  String _generateId() => UniqueKey().toString();

  // Mock data for the reminders list
  final List<PillReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    // Initialize mock data with unique IDs and dosages
    _reminders.addAll([
      PillReminder(
        id: _generateId(),
        medicationName: 'Blood Pressure Med',
        schedule: 'Daily',
        time: const TimeOfDay(hour: 8, minute: 0),
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        repeatDays: 0,
        durationDays: 30,
        dosage: 1,
      ),
      PillReminder(
        id: _generateId(),
        medicationName: 'Vitamin D',
        schedule: 'Every other day',
        time: const TimeOfDay(hour: 12, minute: 30),
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        repeatDays: 2,
        durationDays: 60,
        dosage: 2,
      ),
      PillReminder(
        id: _generateId(),
        medicationName: 'Pain Reliever',
        schedule: 'As Needed',
        time: const TimeOfDay(hour: 17, minute: 0),
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        repeatDays: 0,
        durationDays: 15,
        dosage: 1,
      ),
    ]);

    // Initialize mock adherence logs for demonstration
    _initializeMockLogs();
  }

  void _initializeMockLogs() {
    // Clear existing logs (important for the demo if state is reused)
    PillReminderScreen.adherenceLogs.clear();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Add some logs for the past few days for reporting
    final bpMed = _reminders.firstWhere(
      (r) => r.medicationName == 'Blood Pressure Med',
    );
    final vitD = _reminders.firstWhere((r) => r.medicationName == 'Vitamin D');

    for (int i = 0; i < 7; i++) {
      final logDate = today.subtract(Duration(days: i));

      // Log for Blood Pressure Med (scheduled 8:00 AM)
      if (i < 5) {
        // Log 5 perfect days
        PillReminderScreen.adherenceLogs.add(
          MedicationAdherenceLog(
            reminderId: bpMed.id,
            medicationName: bpMed.medicationName,
            scheduledTime: logDate.add(const Duration(hours: 8)),
            loggedTime: logDate.add(
              const Duration(hours: 8, minutes: 2),
            ), // 2 min late
            status: AdherenceStatus.takenOnTime,
            dosage: bpMed.dosage,
          ),
        );
      } else {
        // Log 2 skipped days
        PillReminderScreen.adherenceLogs.add(
          MedicationAdherenceLog(
            reminderId: bpMed.id,
            medicationName: bpMed.medicationName,
            scheduledTime: logDate.add(const Duration(hours: 8)),
            loggedTime: logDate.add(
              const Duration(hours: 8, minutes: 0),
            ), // Logged time doesn't matter for skipped, but keep it
            status: AdherenceStatus.skipped,
            dosage: bpMed.dosage,
          ),
        );
      }

      // Log for Vitamin D (scheduled 12:30 PM)
      if (i % 2 == 0) {
        // Every other day for "Every other day" schedule
        PillReminderScreen.adherenceLogs.add(
          MedicationAdherenceLog(
            reminderId: vitD.id,
            medicationName: vitD.medicationName,
            scheduledTime: logDate.add(const Duration(hours: 12, minutes: 30)),
            loggedTime: logDate.add(
              const Duration(hours: 14, minutes: 0),
            ), // Late
            status: AdherenceStatus.takenLate,
            dosage: vitD.dosage,
          ),
        );
      }
    }
  }

  // --- Adherence Actions (Updated to log data) ---
  void _markAsTaken(PillReminder reminder) {
    // Prevent logging if already logged for today
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (PillReminderScreen.adherenceLogs.any(
      (log) =>
          log.reminderId == reminder.id && log.dateKey.isAtSameMomentAs(today),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This medication has already been logged for today.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    // Define a punctuality window (e.g., 30 minutes)
    final punctualityThreshold = scheduledDateTime.add(
      const Duration(minutes: 30),
    );

    final status = now.isAfter(punctualityThreshold)
        ? AdherenceStatus.takenLate
        : AdherenceStatus.takenOnTime;

    final log = MedicationAdherenceLog(
      reminderId: reminder.id,
      medicationName: reminder.medicationName,
      scheduledTime: scheduledDateTime,
      loggedTime: now,
      status: status,
      dosage: reminder.dosage,
    );

    setState(() {
      PillReminderScreen.adherenceLogs.add(log);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${reminder.medicationName} marked as completed! Status: ${status == AdherenceStatus.takenOnTime ? "On Time" : "Late"}',
        ),
      ),
    );
  }

  void _skipReminder(PillReminder reminder) {
    // Prevent logging if already logged for today
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (PillReminderScreen.adherenceLogs.any(
      (log) =>
          log.reminderId == reminder.id && log.dateKey.isAtSameMomentAs(today),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This medication has already been logged for today.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    final log = MedicationAdherenceLog(
      reminderId: reminder.id,
      medicationName: reminder.medicationName,
      scheduledTime: scheduledDateTime,
      loggedTime: now,
      status: AdherenceStatus.skipped,
      dosage: reminder.dosage, // Log dosage even if skipped
    );

    setState(() {
      PillReminderScreen.adherenceLogs.add(log);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${reminder.medicationName} skipped/snoozed.')),
    );
  }

  // Reschedule functionality is currently a mock for snooze, no log needed yet.
  void _rescheduleReminder(PillReminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminder.medicationName} rescheduled (snoozed).'),
      ),
    );
  }

  // --- Data Modification Functions (Updated to include ID and Dosage) ---

  void _sortReminders() {
    _reminders.sort((a, b) {
      final aTime = a.time.hour * 60 + a.time.minute;
      final bTime = b.time.hour * 60 + b.time.minute;
      return aTime.compareTo(bTime);
    });
  }

  PillReminder? _findNextActiveReminder() {
    _sortReminders();
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (var reminder in _reminders) {
      final reminderMinutes = reminder.time.hour * 60 + reminder.time.minute;
      if (reminderMinutes >= currentMinutes) {
        return reminder;
      }
    }
    return _reminders.isNotEmpty ? _reminders.first : null;
  }

  void _addReminder(PillReminder newReminder) {
    setState(() {
      _reminders.add(newReminder);
      _sortReminders();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newReminder.medicationName} reminder added!')),
    );
  }

  void _editReminder(PillReminder oldReminder, PillReminder newReminder) {
    setState(() {
      final index = _reminders.indexOf(oldReminder);
      if (index != -1) {
        _reminders[index] = newReminder;
        _sortReminders();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newReminder.medicationName} updated!')),
    );
  }

  void _deleteReminder(PillReminder reminder) {
    setState(() {
      _reminders.remove(reminder);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${reminder.medicationName} deleted.')),
    );
  }

  // --- Modal to add/edit a reminder (Updated for Dosage input) ---
  void _showReminderModal({PillReminder? reminderToEdit}) {
    final bool isEditing = reminderToEdit != null;

    final List<String> scheduleOptions = [
      'Daily',
      'Every other day',
      'As Needed',
      'Weekly',
    ];

    showModalBottomSheet<PillReminder>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Local state for the modal
        String tempMedName = isEditing ? reminderToEdit.medicationName : '';
        TimeOfDay selectedTime = isEditing
            ? reminderToEdit.time
            : TimeOfDay.now();
        String selectedSchedule = isEditing
            ? reminderToEdit.schedule
            : scheduleOptions.first;
        // NEW: Dosage state
        int selectedDosage = isEditing ? reminderToEdit.dosage : 1;

        final controller = TextEditingController(text: tempMedName);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            void showTimePickerAndUpdate() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (picked != null) {
                modalSetState(() {
                  selectedTime = picked;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'Edit Reminder' : 'Add New Reminder',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),

                    // 1. Medication Name Input
                    TextField(
                      controller: controller,
                      onChanged: (value) => tempMedName = value,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 2. Functional Time Picker (Clock)
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Reminder Time'),
                      subtitle: Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: showTimePickerAndUpdate,
                    ),
                    const SizedBox(height: 10),

                    // NEW: Dosage Picker
                    ListTile(
                      leading: const Icon(Icons.medical_services_outlined),
                      title: const Text('Dosage (Pills/Dose)'),
                      subtitle: Text(
                        '$selectedDosage pill${selectedDosage > 1 ? 's' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final newDosage = await showDialog<int>(
                          context: context,
                          builder: (BuildContext context) {
                            int tempDosage = selectedDosage;
                            return AlertDialog(
                              title: const Text('Select Dosage'),
                              content: StatefulBuilder(
                                builder:
                                    (
                                      BuildContext context,
                                      StateSetter dialogSetState,
                                    ) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Pills/Dose: $tempDosage'),
                                          Slider(
                                            value: tempDosage.toDouble(),
                                            min: 1,
                                            max: 10,
                                            divisions: 9,
                                            label: tempDosage.toString(),
                                            onChanged: (double value) {
                                              dialogSetState(() {
                                                tempDosage = value.round();
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(tempDosage),
                                ),
                              ],
                            );
                          },
                        );
                        if (newDosage != null) {
                          modalSetState(() {
                            selectedDosage = newDosage;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // 3. Functional Schedule Dropdown
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.black54),
                        const SizedBox(width: 15),
                        const Text(
                          'Schedule: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedSchedule,
                            icon: const Icon(Icons.arrow_downward),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                modalSetState(() {
                                  selectedSchedule = newValue;
                                });
                              }
                            },
                            items: scheduleOptions
                                .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4. Save Button
                    ElevatedButton(
                      onPressed: () {
                        final finalMedName = controller.text.trim().isEmpty
                            ? (isEditing
                                  ? reminderToEdit.medicationName
                                  : 'New Pill')
                            : controller.text.trim();

                        final newReminderData =
                            reminderToEdit?.copyWith(
                              medicationName: finalMedName,
                              time: selectedTime,
                              schedule: selectedSchedule,
                              dosage: selectedDosage, // <-- Use selected dosage
                            ) ??
                            PillReminder(
                              id: _generateId(), // NEW ID for new reminders
                              medicationName: finalMedName,
                              schedule: selectedSchedule,
                              time: selectedTime,
                              startDate: DateTime.now(),
                              repeatDays: 0,
                              durationDays: 7,
                              dosage: selectedDosage, // <-- Use selected dosage
                            );
                        Navigator.of(context).pop(newReminderData);
                      },
                      child: Text(isEditing ? 'Save Changes' : 'Save Reminder'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((newReminder) {
      if (newReminder != null) {
        if (isEditing) {
          _editReminder(reminderToEdit, newReminder);
        } else {
          _addReminder(newReminder);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the next active reminder to highlight it
    final nextActiveReminder = _findNextActiveReminder();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGuest ? 'Guest View: Reminders' : 'Pill Reminders',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Text(
                widget.isGuest
                    ? 'No reminders found. Tap + to add a temporary demo reminder.'
                    : 'Tap + to add your first reminder!',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                // Pass the new flag to the card
                final isNextActive = reminder == nextActiveReminder;

                // Determine if a log already exists for this reminder today
                final today = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                );
                final alreadyLogged = PillReminderScreen.adherenceLogs.any(
                  (log) =>
                      log.reminderId == reminder.id &&
                      log.dateKey.isAtSameMomentAs(today),
                );

                return PillReminderCard(
                  reminder: reminder,
                  onTaken: _markAsTaken,
                  onSkip: _skipReminder,
                  onReschedule: _rescheduleReminder,
                  onEdit: (r) => _showReminderModal(reminderToEdit: r),
                  onDelete: _deleteReminder,
                  isGuest: widget.isGuest,
                  isNextActive: isNextActive,
                  isLoggedToday: alreadyLogged, // NEW: Pass logging status
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderModal(),
        tooltip: 'Add New Reminder',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Pill Reminder Card Widget ---
class PillReminderCard extends StatelessWidget {
  final PillReminder reminder;
  final Function(PillReminder) onTaken;
  final Function(PillReminder) onSkip;
  final Function(PillReminder) onReschedule;
  final Function(PillReminder) onEdit;
  final Function(PillReminder) onDelete;
  final bool isGuest;
  final bool isNextActive; // Flag to indicate the next active schedule
  final bool isLoggedToday; // NEW: To conditionally disable actions

  const PillReminderCard({
    super.key,
    required this.reminder,
    required this.onTaken,
    required this.onSkip,
    required this.onReschedule,
    required this.onEdit,
    required this.onDelete,
    required this.isGuest,
    required this.isNextActive,
    required this.isLoggedToday, // REQUIRE NEW PROP
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    // Define colors for the active card
    final activeColor = isGuest ? Colors.orange : primary;
    final cardColor = isNextActive
        ? activeColor.withOpacity(0.1)
        : Colors.white;

    final isDisabled = isLoggedToday; // Disable if already taken or skipped

    return Card(
      // Increase elevation for active card
      elevation: isNextActive ? 8 : 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // Use a prominent border color for the active card
          color: isNextActive
              ? activeColor
              : isDisabled
              ? Colors
                    .green
                    .shade700 // Green border for logged
              : Colors.grey.shade200,
          width: isNextActive || isDisabled ? 3 : 2,
        ),
      ),
      child: Container(
        color: isDisabled
            ? Colors.green.shade50.withOpacity(0.5)
            : cardColor, // Subtle green for completed
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time, Medication Name, and Action Icons
            Row(
              children: [
                Icon(
                  isDisabled
                      ? Icons.check_circle
                      : Icons.access_time_filled, // Checkmark for completed
                  color: isDisabled
                      ? Colors.green.shade700
                      : (isNextActive ? activeColor : primary),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  reminder.time.format(context),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Use color based on status
                    color: isDisabled
                        ? Colors.green.shade700
                        : (isNextActive ? activeColor : primary),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    reminder.medicationName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isDisabled
                          ? TextDecoration.lineThrough
                          : null, // Strikethrough for completed
                      color: isDisabled ? Colors.grey : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Edit Button (Always enabled for demo)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => onEdit(reminder),
                  tooltip: 'Edit Reminder',
                ),
                // Delete Button (Always enabled for demo)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(reminder),
                  tooltip: 'Delete Reminder',
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Schedule, Duration, Dosage
            Text(
              'Schedule: ${reminder.schedule} | Dosage: ${reminder.dosage} pill${reminder.dosage > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: isDisabled ? Colors.grey.shade700 : Colors.black54,
              ),
            ),

            // Log Status Indicator
            if (isLoggedToday)
              Text(
                'STATUS: LOGGED FOR TODAY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),

            // Display Start Date (Moved for cleaner layout)
            if (!isLoggedToday)
              Text(
                'Start Date: ${reminder.startDate.day}/${reminder.startDate.month}/${reminder.startDate.year}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

            const Divider(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isDisabled ? null : () => onReschedule(reminder),
                  child: const Text('Reschedule'), // This acts as 'Snooze'
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isDisabled ? null : () => onSkip(reminder),
                  child: const Text('Skip'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isDisabled
                      ? null
                      : () => onTaken(reminder), // Disable if logged
                  // Use active color for the primary action button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDisabled
                        ? Colors.grey
                        : (isNextActive ? activeColor : primary),
                  ),
                  child: Text(
                    'COMPLETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isDisabled
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // Add a subtle hint that alarms are disabled for guests
            if (isGuest)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Pill alarm functionality is disabled in Guest Mode.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
