import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:medtrack_app/routes.dart';
import 'package:medtrack_app/widgets/main_app_shell.dart';
import 'package:medtrack_app/screens/welcome_screen.dart';
import 'firebase_options.dart';
import 'models/settings_state_model.dart';
import 'services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init(); 
  
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
          title: 'MediTrack+',
          themeMode: settings.themeMode,
          // DARK THEME FIX: Restores the black/dark background from your screenshots
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
          ),
          // AUTOMATIC NAVIGATION: Listens to Firebase logout events
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData) {
                return const MainAppShell(isGuest: false);
              }
              return const WelcomeScreen();
            },
          ),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}