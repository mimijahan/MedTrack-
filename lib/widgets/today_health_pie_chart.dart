// lib/widgets/today_health_pie_chart.dart
import 'package:flutter/material.dart';
import '../screens/health_monitor_screen.dart'; // Import HealthRecord

class TodayHealthPieChart extends StatelessWidget {
  final List<HealthRecord> records;

  const TodayHealthPieChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the count of each metric logged today
    final metricCounts = <String, int>{};
    for (var record in records) {
      metricCounts[record.metricName] =
          (metricCounts[record.metricName] ?? 0) + 1;
    }

    final totalRecords = records.length;
    if (totalRecords == 0) return const SizedBox.shrink();

    // Simple mock colors for the pie chart segments
    final Map<String, Color> chartColors = {
      'Weight': Colors.blue,
      'Blood Pressure': Colors.red,
      'Glucose': Colors.orange,
      'Hydration': Colors.green,
    };

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Health Activity (Total $totalRecords Logs)",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                // Mock Pie Chart Area
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$totalRecords\nLogs',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Legend
                Expanded(
                  flex: 2,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: metricCounts.keys.map((metricName) {
                      final count = metricCounts[metricName]!;
                      final percentage = ((count / totalRecords) * 100)
                          .toStringAsFixed(0);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            color: chartColors[metricName] ?? Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$metricName: $count ($percentage%)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
