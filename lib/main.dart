import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrack_app/routes.dart';

// --- FIREBASE IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
// ------------------------

import 'models/settings_state_model.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Connected to Firebase Project: ${Firebase.app().options.projectId}");

  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsStateModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsStateModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MedTrack+',
          themeMode: settings.themeMode,
          
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: settings.fontSizeScale,
            ),
          ),

          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: settings.fontSizeScale,
            ),
          ),

          initialRoute: AppRoutes.welcome,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}