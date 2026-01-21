import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String reminderTime;
  final DateTime? lastTaken;

  Medication({
    required this.id,
    required this.name,
    required this.reminderTime,
    this.lastTaken,
  });

  factory Medication.fromFirestore(Map<String, dynamic> data, String id) {
    return Medication(
      id: id,
      name: data['name'] ?? '',
      reminderTime: data['reminderTime'] ?? '00:00',
      lastTaken: data['lastTaken'] != null ? (data['lastTaken'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'reminderTime': reminderTime,
      'lastTaken': lastTaken != null ? Timestamp.fromDate(lastTaken!) : null,
    };
  }
}