import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_state_model.dart';

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsDetailScreen({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(padding: const EdgeInsets.all(16.0), children: children),
    );
  }
}

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  Widget _buildColorOption(BuildContext context, SettingsStateModel settings, Color color, String name) {
    bool isSelected = settings.backgroundColor == color;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => settings.setBackgroundColor(color),
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.blue : Colors.grey, width: 2)),
          ),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(color: isSelected ? Colors.blue : (isDark ? Colors.white : Colors.black))),
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
            ListTile(
              title: const Text('Theme Mode'),
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                items: ThemeMode.values.map((mode) => DropdownMenuItem(value: mode, child: Text(mode.name))).toList(),
                onChanged: (val) => settings.setThemeMode(val!),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorOption(context, settings, Colors.white, 'Default'),
                _buildColorOption(context, settings, const Color(0xFFF0F8FF), 'Sky'),
                _buildColorOption(context, settings, Colors.grey[200]!, 'Light'),
              ],
            )
          ],
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final List<String> features;
  const PlaceholderScreen({super.key, required this.title, required this.features});

  @override
  Widget build(BuildContext context) {
    return SettingsDetailScreen(title: title, children: features.map((f) => ListTile(title: Text(f))).toList());
  }
}

class DateTimeScreen extends StatelessWidget {
  const DateTimeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SettingsDetailScreen(title: "Date & Time", children: [const Text("Date & Time Settings")]);
  }
}