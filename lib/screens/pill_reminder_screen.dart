import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';
import '../services/database_service.dart';

class PillReminderScreen extends StatefulWidget {
  final bool isGuest;
  const PillReminderScreen({super.key, required this.isGuest});

  @override
  State<PillReminderScreen> createState() => _PillReminderScreenState();
}

class _PillReminderScreenState extends State<PillReminderScreen> {
  final DatabaseService _dbService = DatabaseService();

  void _showAddDialog() async {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text("Add Daily Medicine", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white), // Fixed input visibility
                decoration: const InputDecoration(hintText: "Medicine Name"),
              ),
              ListTile(
                title: Text("Time: ${selectedTime.format(context)}", style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.access_time, color: Colors.blue),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: selectedTime);
                  if (picked != null) setDialogState(() => selectedTime = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _dbService.addMedication(Medication(
                    id: '',
                    name: nameController.text,
                    reminderTime: "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}",
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Reminders")),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.isGuest ? null : _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: _dbService.medications,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final meds = snapshot.data!;
          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              bool isTakenToday = med.lastTaken?.day == DateTime.now().day;

              return Dismissible(
                key: Key(med.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _dbService.deleteMedication(med.id),
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                child: Card(
                  color: isTakenToday ? Colors.green.withOpacity(0.1) : null,
                  child: ListTile(
                    title: Text(med.name, style: TextStyle(decoration: isTakenToday ? TextDecoration.lineThrough : null, color: Colors.white)),
                    subtitle: Text("Daily at ${med.reminderTime}", style: const TextStyle(color: Colors.white70)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _dbService.deleteMedication(med.id)),
                        isTakenToday ? const Icon(Icons.check_circle, color: Colors.green) : ElevatedButton(onPressed: () => _dbService.markAsTaken(med.id), child: const Text("TAKE")),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}