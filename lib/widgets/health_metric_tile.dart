// lib/widgets/health_metric_tile.dart
import 'package:flutter/material.dart';

class HealthMetricTile extends StatelessWidget {
  final Map<String, List<double>>
  trendData; // Contains only the selected metric now
  final List<String> availableMetrics; // Contains only the selected metric name
  final Color metricColor;

  const HealthMetricTile({
    super.key,
    required this.trendData,
    required this.availableMetrics,
    required this.metricColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the name of the single metric being shown
    final metricName = availableMetrics.firstOrNull ?? 'No Data';
    final data = trendData[metricName] ?? [];

    // Purple theme colors
    final purplePrimary = Colors.purple[700];
    final purpleLight = Colors.purple[100];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: purpleLight!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: purplePrimary!),
      ),
      child: Column(
        children: [
          Text(
            '$metricName Trend Over ${data.length} Records',
            style: TextStyle(
              color: purplePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          // Visual area for the mock graph
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: [
                  // Y-Axis Placeholder
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Value',
                      style: TextStyle(color: purplePrimary),
                    ),
                  ),

                  // X-Axis Placeholder
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Records',
                      style: TextStyle(color: purplePrimary),
                    ),
                  ),

                  // Single Line Graph (Mock Visualization)
                  Align(
                    alignment: const Alignment(0, 0),
                    child: Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: metricColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: metricColor.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Legend (Simplified to just show the current metric)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 10, height: 10, color: metricColor),
              const SizedBox(width: 4),
              Text(metricName, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
