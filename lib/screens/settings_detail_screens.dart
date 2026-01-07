// lib/screens/settings_detail_screens.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_state_model.dart';

// --- Shared Detail Screen Structure ---
class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(padding: const EdgeInsets.all(16.0), children: children),
    );
  }
}

// ===================================
// 1. Appearance Screen (FUNCTIONAL)
// ===================================
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  Widget _buildColorOption(
    BuildContext context,
    SettingsStateModel settings,
    Color color,
    String name,
  ) {
    bool isSelected = settings.backgroundColor == color;
    return GestureDetector(
      onTap: () => settings.setBackgroundColor(color),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsStateModel>(
      builder: (context, settings, child) {
        return SettingsDetailScreen(
          title: 'Appearance',
          children: [
            // Theme Mode: Light, Dark, Auto
            ListTile(
              title: const Text('Theme Mode'),
              subtitle: Text(settings.themeMode.name.toUpperCase()),
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                items: ThemeMode.values.map((ThemeMode mode) {
                  return DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(mode.name),
                  );
                }).toList(),
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    settings.setThemeMode(newValue);
                  }
                },
              ),
            ),

            const Divider(),

            // Font Size Adjustment (Slider)
            ListTile(
              title: Text(
                'Font Size (${(settings.fontSizeScale * 100).toInt()}%)',
              ),
              subtitle: const Text('Accessibility-friendly adjustments'),
            ),
            Slider(
              value: settings.fontSizeScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: settings.fontSizeScale.toStringAsFixed(1),
              onChanged: (double value) {
                settings.setFontSizeScale(value);
              },
            ),

            const Divider(),

            // Background Color Picker (Simplified Preset Selection)
            const ListTile(
              title: Text('Background Color'),
              subtitle: Text('Choose from presets'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildColorOption(context, settings, Colors.white, 'Default'),
                  _buildColorOption(
                    context,
                    settings,
                    const Color(0xFFF0F8FF),
                    'Sky',
                  ),
                  _buildColorOption(
                    context,
                    settings,
                    Colors.grey[200]!,
                    'Light',
                  ),
                ],
              ),
            ),

            // Layout Density (Placeholder)
            const Divider(),
            ListTile(
              title: const Text('Layout Density'),
              subtitle: const Text(
                'Compact vs. comfortable spacing (Placeholder)',
              ),
              trailing: const Icon(Icons.compare_arrows),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}

// ===================================
// 2. Date & Time Screen (FUNCTIONAL)
// ===================================
class DateTimeScreen extends StatelessWidget {
  const DateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsStateModel>(
      builder: (context, settings, child) {
        return SettingsDetailScreen(
          title: 'Date & Time',
          children: [
            // Time Format: 12-hour or 24-hour.
            SwitchListTile(
              title: const Text('Time Format'),
              subtitle: Text(
                settings.is24HourFormat
                    ? '24-Hour (e.g., 14:00)'
                    : '12-Hour (e.g., 2:00 PM)',
              ),
              value: settings.is24HourFormat,
              onChanged: (bool value) => settings.toggleTimeFormat(),
              secondary: const Icon(Icons.timer_outlined),
            ),

            const Divider(),

            // Start Day of Week: Sunday or Monday.
            ListTile(
              title: const Text('Start Day of Week'),
              subtitle: Text(
                settings.startDayOfWeek == DateTime.monday
                    ? 'Monday'
                    : 'Sunday',
              ),
              trailing: DropdownButton<int>(
                value: settings.startDayOfWeek,
                items: const [
                  DropdownMenuItem(
                    value: DateTime.monday,
                    child: Text('Monday'),
                  ),
                  DropdownMenuItem(
                    value: DateTime.sunday,
                    child: Text('Sunday'),
                  ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    settings.setStartDayOfWeek(newValue);
                  }
                },
              ),
            ),

            // Time Zone (Placeholder)
            const Divider(),
            ListTile(
              title: const Text('Time Zone'),
              subtitle: const Text(
                'Manual selection or auto-detect (Placeholder)',
              ),
              trailing: const Icon(Icons.language),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Time zone selection not implemented yet.'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===================================
// 3. Simple Placeholders for Other Screens (REQUIRED BY settings_screen.dart)
// ===================================

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final List<String> features;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsDetailScreen(
      title: title,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'The following features for "$title" are planned. Tap any item to acknowledge the feature.',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        ...features.map(
          (feature) => ListTile(
            title: Text(feature),
            onTap: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Feature: $feature'))),
            trailing: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
