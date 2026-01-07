// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:medtrack_app/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Placeholder function for login logic
  void _handleLogin(BuildContext context) {
    // In a real application, this is where you would call Firebase Auth:
    // 1. Validate email/password
    // 2. Call signInWithEmailAndPassword
    // 3. Handle success or failure

    // --- SIMULATION: Navigate to the full, authenticated app experience ---
    Navigator.of(context).pushReplacementNamed(AppRoutes.pillReminder);
  }

  // NEW: Placeholder function for social login logic
  void _handleSocialLogin(BuildContext context, String provider) {
    // In a real application, this would call a social sign-in method
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulating login with $provider...')),
    );
    // Simulate successful navigation
    Navigator.of(context).pushReplacementNamed(AppRoutes.pillReminder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to MediTrack+'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Email Input
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password Input
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      // IMPROVEMENT: Add a toggle icon here in a real app
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Forgot Password?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Placeholder for navigation
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Standard Login Button
                  ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),

                  // NEW: Divider for Social Login
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // NEW: Social Login Button (Simulated Google Sign-in)
                  OutlinedButton.icon(
                    onPressed: () => _handleSocialLogin(context, 'Google'),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 30,
                    ), // Placeholder icon
                    label: const Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                  ),

                  // End of New Section
                  const SizedBox(height: 20),

                  // Link to Sign Up Screen
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.signup);
                    },
                    child: const Text("Don't have an account? Sign Up"),
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
