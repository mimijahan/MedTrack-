MediTrack+

Never miss a dose. Stay healthy, stay on track.

MediTrack+ is a medication and health tracking app designed to simplify your wellness routine. Whether you're managing your own schedule or caring for loved ones, MediTrack+ helps you stay organized, informed, and on time.

📱 Features

1. Welcome Screen (Updated)

Initial Screen: This screen is the application's entry point.

Clean UI with motivational tagline and heart-shaped path illustration (assets/welcome_illustration.png).

Quick access buttons:

Get Started (Primary Action): Initiates Guest Mode, navigating directly to the Pill Reminder screen without requiring login.

Create an Account (Secondary Action): Navigates to the full Sign Up screen.

2. Login Page

Secure login with email and password.

“Forgot password?” recovery option.

3. Pill Reminder & Alarm (Updated)

Functionality: Users can view, add, and manage multiple medication schedules.

Scheduled Alerts: Time, dosage, and pill icons are displayed.

Action Buttons (When Reminder is Due): Take Now, Skipped, Reschedule.

Reminder Setup Flow (New Inputs):

Medication Name (Text Input)

Time: Set via a Clock Picker dialog ($\text{showTimePicker}$).

Date: Set via a Calendar Picker dialog ($\text{showDatePicker}$).

Schedule: Set via a Dropdown (e.g., Daily, Weekly, Monthly).

Duration: Set via an interactive Slider (e.g., 1 to 90 days).

4. Health Monitor

Trackers for:
  - Weight (scale icon)
  - Blood Pressure (digital meter)
  - Glucose (droplet icon)
  - Hydration (water droplet)

Frequency labels: “Daily 1 time”, “Every 4 hours”, etc.

5. Anti-Procrastination Timer

Motivational character with speech bubble.

Countdown timer with +1 min delay option.

Interactive line graph with data points.

6. Records, Pet & Child Care, Complex Scheduling

Calendar view with adherence color codes.

Dependent profiles: Claire, Luna, Coco, Mom.

Frequency options: Daily, As Needed, Specific Days, Every X Hours.

🛠️ Tech Stack

Platform: Android / iOS / Web (Flutter)

Design: Figma / Flutter Widgets

Language: Flutter (Dart)

Database: Room / Firebase

Notifications: AlarmManager / WorkManager

📦 Folder Structure

MediTrackPlus/
├── assets/
├── screens/
│ ├── WelcomeScreen.dart
│ ├── LoginScreen.dart
│ ├── SignupScreen.dart
│ ├── PillReminderScreen.dart
│ ├── HealthMonitorScreen.dart
│ ├── TimerScreen.dart
│ └── SchedulingScreen.dart
├── models/
├── utils/
└── main.dart