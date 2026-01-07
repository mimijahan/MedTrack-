// lib/screens/medication_report_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'pill_reminder_screen.dart'; // Import to use data models

// --- Widget to display the dosage trend chart ---
class DosageTrendChart extends StatelessWidget {
  final List<MedicationAdherenceLog> logs;

  const DosageTrendChart({super.key, required this.logs});

  // Calculate total dosage taken per day
  Map<DateTime, int> _calculateDailyDosage() {
    final dailyDosage = <DateTime, int>{};
    for (var log in logs.where(
      (l) =>
          l.status != AdherenceStatus.skipped &&
          l.status != AdherenceStatus.forgotten,
    )) {
      final dateKey = log.dateKey;
      dailyDosage[dateKey] = (dailyDosage[dateKey] ?? 0) + log.dosage;
    }
    return dailyDosage;
  }

  @override
  Widget build(BuildContext context) {
    final dailyDosage = _calculateDailyDosage();
    if (dailyDosage.isEmpty) {
      return const Center(child: Text("No dosage data recorded for chart."));
    }

    // Sort by date and get the last 7 days for a simple trend view
    final sortedDates = dailyDosage.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Use last 7 days or all days if less than 7
    final displayDates = sortedDates.length > 7
        ? sortedDates.sublist(sortedDates.length - 7)
        : sortedDates;

    // Safety check for maxDosage to prevent division by zero, min 1 for scaling
    final maxDosage = dailyDosage.values
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final effectiveMax = maxDosage > 0 ? maxDosage : 1.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 Days Total Dosage Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: displayDates.map((date) {
                  final dosage = dailyDosage[date]!.toDouble();
                  final normalizedHeight = dosage / effectiveMax;
                  final dayLabel = DateFormat(
                    'E',
                  ).format(date); // Mon, Tue, etc.

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        dosage.round().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 20,
                        height:
                            120 *
                            normalizedHeight, // Max height is 120 for the bar
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(dayLabel, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Main Report Screen Widget ---
class MedicationReportScreen extends StatefulWidget {
  final bool isGuest;

  const MedicationReportScreen({super.key, required this.isGuest});

  @override
  State<MedicationReportScreen> createState() => _MedicationReportScreenState();
}

class _MedicationReportScreenState extends State<MedicationReportScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String _selectedReportType = 'Daily';
  final List<String> _reportOptions = ['Daily', 'Monthly', 'Annual'];

  // Get logs from the static list in PillReminderScreen
  List<MedicationAdherenceLog> get _logs => PillReminderScreen.adherenceLogs;

  // Helper to group logs by day for the calendar markers
  Map<DateTime, List<MedicationAdherenceLog>> _getLogsByDay() {
    final Map<DateTime, List<MedicationAdherenceLog>> map = {};
    for (var log in _logs) {
      // Use the date key for grouping
      final dateKey = log.dateKey;
      map.putIfAbsent(dateKey, () => []).add(log);
    }
    return map;
  }

  // Helper to determine the color for the calendar dot
  Color _getAdherenceColor(DateTime day) {
    final logsForDay = _getLogsByDay()[day] ?? [];
    if (logsForDay.isEmpty) return Colors.transparent;

    // Check for any 'skipped' or 'takenLate' logs (simple color coding for demo)
    final hasSkipped = logsForDay.any(
      (log) => log.status == AdherenceStatus.skipped,
    );
    final hasLate = logsForDay.any(
      (log) => log.status == AdherenceStatus.takenLate,
    );

    if (hasSkipped) return Colors.red;
    if (hasLate) return Colors.orange;

    // If only 'takenOnTime', mark as perfect
    return Colors.green;
  }

  // Generate the list report for the selected type and day/period
  Widget _generateReportList() {
    List<MedicationAdherenceLog> filteredLogs = [];
    String title;

    // Use the focused day for Month/Year context and selected day for Daily
    final targetDate = _selectedReportType == 'Daily'
        ? _selectedDay
        : _focusedDay;

    if (_selectedReportType == 'Daily') {
      title =
          'Daily Report for ${DateFormat('MMMM d, yyyy').format(targetDate)}';
      filteredLogs = _logs
          .where(
            (log) => log.dateKey.isAtSameMomentAs(
              DateTime(targetDate.year, targetDate.month, targetDate.day),
            ),
          )
          .toList();
    } else if (_selectedReportType == 'Monthly') {
      title =
          'Monthly Report for ${DateFormat('MMMM yyyy').format(targetDate)}';
      filteredLogs = _logs
          .where(
            (log) =>
                log.scheduledTime.year == targetDate.year &&
                log.scheduledTime.month == targetDate.month,
          )
          .toList();
    } else {
      // Annual
      title = 'Annual Report for ${targetDate.year}';
      filteredLogs = _logs
          .where((log) => log.scheduledTime.year == targetDate.year)
          .toList();
    }

    // Group logs by medication name for the report
    final Map<String, List<MedicationAdherenceLog>> logsByMedication = {};
    for (var log in filteredLogs) {
      logsByMedication.putIfAbsent(log.medicationName, () => []).add(log);
    }

    if (logsByMedication.isEmpty) {
      return const Center(
        child: Text('No adherence records found for this period.'),
      );
    }

    // Generate a summary for the current report view
    // NOTE: This logic is still a mock for "scheduled" as it requires complex
    // schedule processing not fully built (e.g., checking if 'Every other day' applies).
    int totalReminders = PillReminderScreen.adherenceLogs
        .map((e) => e.reminderId)
        .toSet()
        .length;
    int totalScheduled;

    if (_selectedReportType == 'Daily') {
      totalScheduled = totalReminders;
    } else if (_selectedReportType == 'Monthly') {
      totalScheduled = totalReminders * 30; // Rough average
    } else {
      // Annual
      totalScheduled = totalReminders * 365; // Rough average
    }

    final totalTaken = filteredLogs
        .where(
          (l) =>
              l.status == AdherenceStatus.takenOnTime ||
              l.status == AdherenceStatus.takenLate,
        )
        .length;
    final totalSkipped = filteredLogs
        .where((l) => l.status == AdherenceStatus.skipped)
        .length;
    final totalLate = filteredLogs
        .where((l) => l.status == AdherenceStatus.takenLate)
        .length;
    final totalAdherenceActions = totalTaken + totalSkipped;

    final adherenceRate = totalScheduled > 0
        ? ((totalAdherenceActions / totalScheduled) * 100).toStringAsFixed(1)
        : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Card(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Taken', totalTaken.toString(), Colors.green),
                _buildSummaryItem('Late', totalLate.toString(), Colors.orange),
                _buildSummaryItem(
                  'Skipped',
                  totalSkipped.toString(),
                  Colors.red,
                ),
                _buildSummaryItem('Rate', '$adherenceRate%', Colors.blue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Detailed List
        ...logsByMedication.entries.map((entry) {
          final medName = entry.key;
          final logs = entry.value;
          final lastLog = logs.reduce(
            (a, b) => a.loggedTime.isAfter(b.loggedTime) ? a : b,
          );

          return ExpansionTile(
            title: Text(
              medName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Last Log: ${DateFormat('MMM d, hh:mm a').format(lastLog.loggedTime)} | Total Logs: ${logs.length}',
            ),
            children: logs
                .map(
                  (log) => ListTile(
                    leading: Icon(
                      log.status == AdherenceStatus.takenOnTime
                          ? Icons.check_circle
                          : log.status == AdherenceStatus.takenLate
                          ? Icons.timer_off
                          : Icons.close,
                      color: log.status == AdherenceStatus.takenOnTime
                          ? Colors.green
                          : log.status == AdherenceStatus.takenLate
                          ? Colors.orange
                          : Colors.red,
                    ),
                    title: Text(
                      '${log.status.toString().split('.').last.replaceAll('taken', 'Taken')} (${log.dosage} pills)',
                    ),
                    trailing: Text(
                      DateFormat('hh:mm a').format(log.loggedTime),
                    ),
                  ),
                )
                .toList(),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medication Reports'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  'Access Denied',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Medication reports and private data tracking are unavailable in Guest Mode. Please log in or sign up for full access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Authenticated User View
    final logsByDay = _getLogsByDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reports'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Dosage Chart ---
            const Text(
              'Dosage & Punctuality Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DosageTrendChart(logs: _logs),
            const SizedBox(height: 30),

            // --- Calendar View ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Adherence Calendar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedReportType =
                              'Daily'; // Auto-switch to daily when day is tapped
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        setState(
                          () {},
                        ); // Update to trigger re-render for month/year report
                      },
                      eventLoader: (day) {
                        final dateKey = DateTime(day.year, day.month, day.day);
                        return logsByDay[dateKey] ??
                            []; // Show dots for days with records
                      },
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red, // Default to red
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getAdherenceColor(
                                    DateTime(day.year, day.month, day.day),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                width: 8.0,
                                height: 8.0,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.green, 'On Time'),
                        _buildLegendItem(Colors.orange, 'Late'),
                        _buildLegendItem(Colors.red, 'Skipped'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Report Selection ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report View',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<String>(
                  value: _selectedReportType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReportType = newValue!;
                    });
                  },
                  items: _reportOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // --- Detailed Report List ---
            _generateReportList(),
          ],
        ),
      ),
    );
  }
}
