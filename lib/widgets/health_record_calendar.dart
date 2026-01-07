// lib/widgets/health_record_calendar.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../screens/health_monitor_screen.dart'; // Import to use HealthRecord

class HealthRecordCalendar extends StatefulWidget {
  final Map<DateTime, List<HealthRecord>> recordsByDate; // Changed type
  final Function(DateTime) onDayTapped; // New callback

  const HealthRecordCalendar({
    super.key,
    required this.recordsByDate,
    required this.onDayTapped,
  });

  @override
  State<HealthRecordCalendar> createState() => _HealthRecordCalendarState();
}

class _HealthRecordCalendarState extends State<HealthRecordCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record History',
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
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDayTapped(
                  DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  ),
                );
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              // Get the day key without time component
              final dateKey = DateTime(day.year, day.month, day.day);
              // Return events (records) for the indicator dots
              return widget.recordsByDate[dateKey] ?? [];
            },
            calendarStyle: CalendarStyle(
              // Show a small dot for days with records
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            ),
          ),
        ),
      ],
    );
  }
}
