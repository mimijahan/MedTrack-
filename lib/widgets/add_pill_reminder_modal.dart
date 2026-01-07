// lib/widgets/add_pill_reminder_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/pill_reminder_screen.dart'; // Import PillReminder model

// Define a callback function signature for when the form is submitted
typedef OnPillReminderAdded = void Function(PillReminder item);

class AddPillReminderModal extends StatefulWidget {
  final OnPillReminderAdded onReminderAdded;

  const AddPillReminderModal({super.key, required this.onReminderAdded});

  @override
  State<AddPillReminderModal> createState() => _AddPillReminderModalState();
}

class _AddPillReminderModalState extends State<AddPillReminderModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicationNameController =
      TextEditingController();

  // --- Form Data State ---
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSchedule = 'Daily'; // Simple schedule: Daily, Weekly, etc.
  DateTime _startDate = DateTime.now();
  double _durationDays = 7.0; // Default duration of 7 days

  @override
  void dispose() {
    _medicationNameController.dispose();
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

  // Shows the Date Picker dialog
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      var id = '';
      final newReminder = PillReminder(
        medicationName: _medicationNameController.text.trim(),
        schedule: _selectedSchedule,
        time: _selectedTime,
        startDate: _startDate,
        repeatDays: 0, // Placeholder
        durationDays: _durationDays.round(),
        id: id,
      );

      // Pass the new item back to the parent screen
      widget.onReminderAdded(newReminder);

      // Close the modal
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Title ---
              Text(
                'Add New Pill Reminder',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Divider(),
              const SizedBox(height: 20),

              // --- 1. Medication Name Input ---
              TextFormField(
                controller: _medicationNameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name (e.g., Ibuprofen, Daily Vitamin)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a medication name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- 2. Time Picker ---
              ListTile(
                leading: Icon(Icons.access_time, color: primaryColor),
                title: const Text('Reminder Time'),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selectTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 10),

              // --- 3. Start Date Picker ---
              ListTile(
                leading: Icon(Icons.calendar_month, color: primaryColor),
                title: const Text('Start Date'),
                subtitle: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_startDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 20),

              // --- 4. Schedule/Frequency Dropdown ---
              DropdownButtonFormField<String>(
                initialValue: _selectedSchedule,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: <String>['Daily', 'Weekly', 'As Needed']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSchedule = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- 5. Duration Slider ---
              Text(
                'Duration: ${_durationDays.round()} days',
                style: const TextStyle(fontWeight: FontWeight.bold),
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

              // --- 6. Submit Button ---
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Add Reminder',
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
