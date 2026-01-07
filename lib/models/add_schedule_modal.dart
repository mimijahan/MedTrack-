// lib/models/add_schedule_modal.dart

import 'package:flutter/material.dart';
import '../models/dependent_model.dart';

// Define a callback function signature for when the form is submitted
typedef OnScheduleAdded = void Function(ScheduleItem item);

class AddScheduleModal extends StatefulWidget {
  final Dependent dependent;
  final OnScheduleAdded onScheduleAdded;

  const AddScheduleModal({
    super.key,
    required this.dependent,
    required this.onScheduleAdded,
  });

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  // NEW: Controller for the Schedule ID input field
  final TextEditingController _scheduleIdController = TextEditingController();

  // --- Form Data State ---
  TimeOfDay _selectedTime = TimeOfDay.now();
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.daily;
  double _durationDays = 7.0; // Default duration of 7 days
  int _intervalHours = 4; // Used only if frequency is interval

  @override
  void dispose() {
    _taskNameController.dispose();
    // NEW: Dispose the ID controller
    _scheduleIdController.dispose();
    super.dispose();
  }

  // --- Helper Functions ---

  // Shows the Time Picker dialog
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Handles form submission and calls the callback
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 1. Convert TimeOfDay to DateTime
      final now = DateTime.now();
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // 2. Create the new ScheduleItem
      final newSchedule = ScheduleItem(
        // MODIFIED: Use the user-inputted ID
        id: _scheduleIdController.text.trim(),
        dependentId: widget.dependent.id,
        taskName: _taskNameController.text.trim(),
        startTime: startTime,
        frequency: _selectedFrequency,
        durationDays: _durationDays.toInt(),
        dateCreated: now,
        intervalHours: _selectedFrequency == ScheduleFrequency.interval
            ? _intervalHours
            : null,
      );

      // 3. Pass the new item back to the parent screen
      widget.onScheduleAdded(newSchedule);

      // 4. Close the modal
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          // Add padding for the keyboard
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Header ---
              Text(
                'New Schedule for ${widget.dependent.name}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),

              // NEW: Schedule ID Input Field
              TextFormField(
                controller: _scheduleIdController,
                decoration: const InputDecoration(
                  labelText: 'Schedule ID (Unique)',
                  hintText: 'e.g., BloodPress-Daily',
                  prefixIcon: Icon(Icons.vpn_key), // Icon for ID/Key
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unique schedule ID.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- 1. Task Name Input ---
              TextFormField(
                controller: _taskNameController,
                decoration: const InputDecoration(
                  labelText: 'Task/Medication Name',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- 2. Start Time Picker ---
              ListTile(
                leading: Icon(Icons.access_time, color: primaryColor),
                title: const Text('Start Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.edit),
                onTap: _selectTime,
              ),
              const Divider(),

              // --- 3. Schedule Frequency Dropdown ---
              DropdownButtonFormField<ScheduleFrequency>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: ScheduleFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency.name),
                  );
                }).toList(),
                onChanged: (ScheduleFrequency? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFrequency = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 15),

              // --- Conditional: Interval Hours Input ---
              if (_selectedFrequency == ScheduleFrequency.interval) ...[
                TextFormField(
                  initialValue: _intervalHours.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repeat Every (Hours)',
                    prefixIcon: Icon(Icons.more_time),
                  ),
                  onChanged: (value) {
                    final hours = int.tryParse(value);
                    if (hours != null && hours > 0) {
                      _intervalHours = hours;
                    }
                  },
                ),
                const SizedBox(height: 15),
              ],

              // --- 4. Duration Slider ---
              Text(
                'Duration: ${_durationDays.toInt()} Days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Slider(
                value: _durationDays,
                min: 1,
                max: 90,
                divisions: 89,
                label: _durationDays.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _durationDays = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- 5. Submit Button ---
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Add Schedule',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NOTE: The extension method below is used to convert the enum name
// into a readable string for the Dropdown.
extension ScheduleFrequencyExtension on ScheduleFrequency {
  String get name {
    switch (this) {
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.interval:
        return 'Every X Hours';
      case ScheduleFrequency.specificDays:
        return 'Specific Days of the Week';
    }
  }
}
