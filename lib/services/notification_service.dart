import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static Future<void> init() async {
    print("NotificationService: Init skipped/simulated for Web.");
  }

  static Future<void> scheduleNotification(int id, String title, String body, int hour, int minute) async {
    print("LOG: Notification scheduled for $title at $hour:$minute");
  }

  static Future<void> cancelNotification(int id) async {
    print("LOG: Notification $id cancelled.");
  }
}