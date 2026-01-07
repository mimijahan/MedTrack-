import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// WIDGET IMPORTS
import '../widgets/health_metric_tile.dart';
import '../widgets/health_record_calendar.dart';
import '../widgets/today_health_pie_chart.dart'; // NEW WIDGET IMPORT

// --- Health Metric Data Model ---
class HealthRecord {
  // Use a unique ID for editing/deleting
  final String id;
  final String metricName;
  final String value;
  final DateTime timestamp;

  HealthRecord({
    required this.id,
    required this.metricName,
    required this.value,
    required this.timestamp,
  });

  // Helper to convert date to a simple key (YMD)
  DateTime get dateKey =>
      DateTime(timestamp.year, timestamp.month, timestamp.day);
}

// --- Health Monitor Screen Widget ---
class HealthMonitorScreen extends StatefulWidget {
  const HealthMonitorScreen({super.key});

  @override
  State<HealthMonitorScreen> createState() => _HealthMonitorScreenState();
}

class _HealthMonitorScreenState extends State<HealthMonitorScreen> {
  // Global key to uniquely identify the FormState for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- REFACTORED: Single source of truth for ALL records ---
  // Key: DateTime (Day only) | Value: List of HealthRecord objects for that day
  final Map<DateTime, List<HealthRecord>> _allRecordsHistory = {};

  // State for the currently selected metric for the detailed graph
  String _selectedTrendMetric = 'Weight';

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    // Initialize with mock records
    _addRecord(
      metricName: 'Weight',
      value: '75.5',
      timestamp: now.subtract(const Duration(hours: 2)),
    );
    _addRecord(
      metricName: 'Blood Pressure',
      value: '120/80',
      timestamp: yesterday.add(const Duration(hours: 10)),
    );
    _addRecord(
      metricName: 'Glucose',
      value: '95',
      timestamp: now.subtract(const Duration(hours: 8)),
    );
    _addRecord(
      metricName: 'Hydration',
      value: '2.5',
      timestamp: twoDaysAgo.add(const Duration(hours: 15)),
    );

    // Add mock trend data (last 7 points)
    _addRecord(
      metricName: 'Weight',
      value: '75.0',
      timestamp: today.subtract(const Duration(days: 6)),
    );
    _addRecord(
      metricName: 'Weight',
      value: '75.2',
      timestamp: today.subtract(const Duration(days: 5)),
    );
    _addRecord(
      metricName: 'Weight',
      value: '75.1',
      timestamp: today.subtract(const Duration(days: 4)),
    );
    _addRecord(
      metricName: 'Weight',
      value: '75.5',
      timestamp: today.subtract(const Duration(days: 3)),
    );
    _addRecord(
      metricName: 'Weight',
      value: '75.3',
      timestamp: today.subtract(const Duration(days: 2)),
    );
    _addRecord(
      metricName: 'Weight',
      value: '75.6',
      timestamp: today.subtract(const Duration(days: 1)),
    );
  }

  // --- METADATA ---
  final Map<String, IconData> _metricIcons = {
    'Weight': Icons.scale,
    'Blood Pressure': Icons.monitor_heart,
    'Glucose': Icons.opacity,
    'Hydration': Icons.water_drop_outlined,
  };
  final Map<String, String> _metricUnits = {
    'Weight': 'kg',
    'Blood Pressure': 'mmHg',
    'Glucose': 'mg/dL',
    'Hydration': 'L',
  };
  final List<String> _metricNames = [
    'Weight',
    'Blood Pressure',
    'Glucose',
    'Hydration',
  ];

  // --- CORE DATA ACCESSORS ---

  // Gets the latest record for display in the cards
  HealthRecord? _getLatestRecord(String metricName) {
    return _allRecordsHistory.values
        .expand((list) => list)
        .where((record) => record.metricName == metricName)
        .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  // Gets the last 7 numeric trend values for the graph
  List<double> _getTrendData(String metricName) {
    if (metricName == 'Blood Pressure') {
      return []; // BP is complex string, skip for simple graph
    }

    return _allRecordsHistory.values
        .expand((list) => list)
        .where((record) => record.metricName == metricName)
        .toList()
        .cast<HealthRecord>() // Cast the list to HealthRecord
        .map((record) => double.tryParse(record.value) ?? 0.0)
        .toList()
        .reversed
        .take(7)
        .toList()
        .reversed
        .toList(); // Take last 7 readings
  }

  // --- CORE DATA MUTATORS ---

  // Used by the initial setup and the input modal
  void _addRecord({
    required String metricName,
    required String value,
    required DateTime timestamp,
  }) {
    final newRecord = HealthRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      metricName: metricName,
      value: value,
      timestamp: timestamp,
    );

    final dateKey = newRecord.dateKey;
    if (!_allRecordsHistory.containsKey(dateKey)) {
      _allRecordsHistory[dateKey] = [];
    }
    _allRecordsHistory[dateKey]!.add(newRecord);

    // Sort the list so the latest is always at the bottom, helpful for display
    _allRecordsHistory[dateKey]!.sort(
      (a, b) => a.timestamp.compareTo(b.timestamp),
    );

    setState(() {}); // Rebuild UI
  }

  // Used by the calendar edit modal
  void _updateRecord(HealthRecord oldRecord, String newValue) {
    final dateKey = oldRecord.dateKey;
    final records = _allRecordsHistory[dateKey];
    if (records != null) {
      final index = records.indexWhere((r) => r.id == oldRecord.id);
      if (index != -1) {
        records[index] = HealthRecord(
          id: oldRecord.id,
          metricName: oldRecord.metricName,
          value: newValue,
          timestamp: DateTime.now(), // Update timestamp on edit
        );
        records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        setState(() {}); // Rebuild UI
      }
    }
  }

  // Used by the calendar edit modal
  void _deleteRecord(HealthRecord recordToDelete) {
    final dateKey = recordToDelete.dateKey;
    final records = _allRecordsHistory[dateKey];
    if (records != null) {
      records.removeWhere((r) => r.id == recordToDelete.id);
      if (records.isEmpty) {
        _allRecordsHistory.remove(dateKey); // Clean up empty day
      }
      setState(() {}); // Rebuild UI
    }
  }

  // --- INPUT MODAL (REUSED FOR ADDING AND EDITING) ---
  void _showRecordForm({
    required String metricToLog,
    HealthRecord? recordToEdit,
  }) {
    TextEditingController valueController = TextEditingController(
      text: recordToEdit?.value ?? _getLatestRecord(metricToLog)?.value ?? '',
    );

    final isEditing = recordToEdit != null;
    final isNumeric = metricToLog != 'Blood Pressure';
    final keyboardType = isNumeric ? TextInputType.number : TextInputType.text;
    final hintText = isNumeric ? 'e.g., 75.5' : 'e.g., 120/80';
    final labelText = '$metricToLog Value (${_metricUnits[metricToLog]})';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing
                      ? 'Edit $metricToLog Record'
                      : 'Log New $metricToLog Record',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                const SizedBox(height: 20),

                // Input Field
                TextFormField(
                  controller: valueController,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    labelText: labelText,
                    hintText: hintText,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    if (isNumeric && double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isEditing) {
                        _updateRecord(recordToEdit, valueController.text);
                      } else {
                        _addRecord(
                          metricName: metricToLog,
                          value: valueController.text,
                          timestamp: DateTime.now(),
                        );
                      }
                      Navigator.of(ctx).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(isEditing ? 'Save Changes' : 'Save Record'),
                ),

                // Delete Button (Only for Editing)
                if (isEditing)
                  TextButton(
                    onPressed: () {
                      _deleteRecord(recordToEdit);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      'Delete Record',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- CALENDAR INTERACTION MODAL ---
  void _showRecordsForDay(DateTime date) {
    final records = _allRecordsHistory[date] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Records on ${DateFormat('MMM dd, yyyy').format(date)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              if (records.isEmpty)
                const Center(child: Text('No records found for this day.')),

              ...records.map(
                (record) => ListTile(
                  leading: Icon(_metricIcons[record.metricName]),
                  title: Text(
                    '${record.metricName} - ${record.value} ${_metricUnits[record.metricName] ?? ''}',
                  ),
                  subtitle: Text(
                    'Logged at ${DateFormat('hh:mm a').format(record.timestamp)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    Navigator.of(ctx).pop(); // Close the list modal
                    _showRecordForm(
                      metricToLog: record.metricName,
                      recordToEdit: record,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper for time formatting (remains the same) ---
  String _getTimeAgo(DateTime dateTime) {
    // ... (logic remains the same)
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // --- Metric Card Builder (updated to use new data access) ---
  Widget _buildMetricCard({
    required String metricName,
    required IconData icon,
  }) {
    final record = _getLatestRecord(metricName);
    final latestValue = record?.value ?? 'N/A';
    final lastRecorded = record?.timestamp ?? DateTime(2000);
    final isAvailable = record != null;

    Color graphColor;
    if (metricName == 'Weight') {
      graphColor = Colors.blue;
    } else if (metricName == 'Blood Pressure')
      graphColor = Colors.red;
    else if (metricName == 'Glucose')
      graphColor = Colors.orange;
    else
      graphColor = Colors.green;

    final trendData = _getTrendData(metricName); // Use real data fetch

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTrendMetric = metricName; // Set metric for graph selection
        });
        _showRecordForm(metricToLog: metricName); // Open input modal
      },
      borderRadius: BorderRadius.circular(8),
      // ... (Card UI logic remains the same) ...
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Icon, Name, and Value
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metricName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$latestValue ${metricName == 'Blood Pressure' ? '' : (_metricUnits[metricName] ?? '')}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. Mini-Graph Placeholder
              const SizedBox(height: 10),
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      graphColor.withOpacity(0.2),
                      graphColor.withOpacity(0.8),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    '${trendData.length} pts',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),

              // 3. Timestamp
              const SizedBox(height: 8),
              Text(
                'Last: ${isAvailable ? _getTimeAgo(lastRecorded) : 'N/A'}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Data for Today's Pie Chart
    final todayRecords =
        _allRecordsHistory[DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        )] ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitor'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW FEATURE 2: Dashboard Summary
            Text(
              'Hello, Track Your Health Progress!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            Text(
              'Your Latest Readings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Metric Card Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: _metricNames.map((metricName) {
                return _buildMetricCard(
                  metricName: metricName,
                  icon: _metricIcons[metricName]!,
                );
              }).toList(),
            ),

            // NEW FEATURE 1: Today's Health Pie Chart
            if (todayRecords.isNotEmpty) ...[
              const SizedBox(height: 30),
              TodayHealthPieChart(records: todayRecords),
            ],

            // --- Metric Trend Section (Now shows a single, selected trend) ---
            const SizedBox(height: 30),
            Text(
              '$_selectedTrendMetric Trend (Last 7 Records)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            HealthMetricTile(
              // PASS ONLY THE SELECTED METRIC'S DATA
              trendData: {
                _selectedTrendMetric: _getTrendData(_selectedTrendMetric),
              },
              availableMetrics: [_selectedTrendMetric],
              metricColor: _selectedTrendMetric == 'Weight'
                  ? Colors.blue
                  : _selectedTrendMetric == 'Blood Pressure'
                  ? Colors.red
                  : _selectedTrendMetric == 'Glucose'
                  ? Colors.orange
                  : Colors.green,
            ),

            // --- Record Calendar Section (Interactive) ---
            const SizedBox(height: 30),
            HealthRecordCalendar(
              recordsByDate: _allRecordsHistory,
              onDayTapped: _showRecordsForDay,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
