// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:medtrack_app/routes.dart';

// Feature 1: The Welcome Screen UI/UX.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for the icon/logo
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Scale animation: starts small, quickly scales up
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Fade animation: fades in with a slight delay
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Action for the 'Get Started' button
  void _onGetStartedPressed(BuildContext context) {
    // Navigate directly to the Pill Reminder Screen in Guest Mode,
    // using pushReplacementNamed to prevent going back to Welcome.
    // NOTE: This route should map to MainAppShell(isGuest: true) in routes.dart.
    Navigator.of(context).pushReplacementNamed(AppRoutes.guestMode);
  }

  // Action for the 'Sign Up' button
  void _onSignupPressed(BuildContext context) {
    // Navigate to the Signup Screen
    Navigator.of(context).pushNamed(AppRoutes.signup);
  }

  // Action for the 'Login' button
  void _onLoginPressed(BuildContext context) {
    // Navigate to the Login Screen
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Gradient for a more colorful background
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Animated Logo/Icon and Illustration
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // NEW: Use the actual illustration asset
                          Image.asset(
                            'assets/welcome_illustration.png',
                            height: 180, // Adjust height as needed
                            semanticLabel: 'Heart-shaped path illustration',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'MediTrack+',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your Health Companion. Never miss a dose.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),

                  // 2. Action Buttons (Fade in slightly later)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Primary Action: Login Button
                        ElevatedButton(
                          onPressed: () => _onLoginPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Login'),
                        ),

                        const SizedBox(height: 16),

                        // Secondary Action: Sign Up Button
                        OutlinedButton(
                          onPressed: () => _onSignupPressed(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Create an Account (Sign Up)'),
                        ),

                        const SizedBox(height: 30),

                        // Tertiary Action: Guest Mode Link (This is the Guest Mode entry point)
                        TextButton(
                          onPressed: () => _onGetStartedPressed(context),
                          child: Text(
                            'Continue as Guest (View Reminders Only)',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
