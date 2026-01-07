// lib/models/dependent_model.dart

import 'package:flutter/material.dart';

enum DependentType { person, pet }

enum ScheduleFrequency { daily, interval, specificDays }

enum AdherenceStatus { perfect, pending, missed }

// --- 1. Dependent Model ---
class Dependent {
  final String id;
  final String name;
  final DependentType type;
  final String initial;
  final Color color;

  Dependent({
    required this.id,
    required this.name,
    required this.type,
    required this.initial,
    required this.color,
  });
}

// --- 2. Schedule Item Model ---
class ScheduleItem {
  final String id;
  final String dependentId;
  final String taskName;
  final DateTime startTime;
  final ScheduleFrequency frequency;
  final int durationDays;
  final DateTime dateCreated;

  // Example complex fields (for future use)
  final int? intervalHours; // Used if frequency is interval

  ScheduleItem({
    required this.id,
    required this.dependentId,
    required this.taskName,
    required this.startTime,
    required this.frequency,
    required this.durationDays,
    required this.dateCreated,
    this.intervalHours,
  });

  // Helper to get the day key (used for calendar)
  DateTime get dateKey =>
      DateTime(startTime.year, startTime.month, startTime.day);
}

// --- 3. Mock Log Model (for Calendar Adherence) ---
// This represents an actual recorded action (e.g., 'Take Now' or 'Skipped')
class AdherenceLog {
  final String scheduleItemId;
  final DateTime loggedTime;
  final AdherenceStatus status;

  AdherenceLog({
    required this.scheduleItemId,
    required this.loggedTime,
    required this.status,
  });

  DateTime get dateKey =>
      DateTime(loggedTime.year, loggedTime.month, loggedTime.day);
}
