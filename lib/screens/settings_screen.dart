import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/settings_state_model.dart';
import 'settings_detail_screens.dart'; 
import 'package:medtrack_app/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildHeader('ACCOUNT & PRIVACY'),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user?.displayName ?? 'Alexander M.', style: const TextStyle(color: Colors.white)),
            subtitle: Text(user?.email ?? 'alex.m@medtrack.com', style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white30),
          ),
          
          _buildHeader('APP EXPERIENCE'),
          _buildSettingTile(context, Icons.palette, 'Appearance', 'Theme mode, color, font style', const AppearanceScreen()),
          _buildSettingTile(context, Icons.accessibility, 'Accessibility', 'Screen reader, high contrast', null),

          _buildHeader('DATA & SYNC'),
          _buildSettingTile(context, Icons.access_time, 'Date & Time', 'Time format, start day', const DateTimeScreen()),

          _buildHeader('SESSION'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              // This triggers the StreamBuilder in main.dart to show the WelcomeScreen
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title, String subtitle, Widget? destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white30)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: destination != null ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)) : null,
    );
  }
}