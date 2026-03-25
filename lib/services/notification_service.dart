import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'zegocloud_voip_service.dart'; // Needed so the notification button can call the watch!

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Ask the caregiver for permission to send notifications
    await Permission.notification.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      // This listens for when the Caregiver taps the "Call Now" button on the notification
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'call_now') {
          ZegocloudVoipService.startCall(
            calleeId: "patient_001", 
            calleeName: "Patient Watch",
            isVideoCall: false,
          );
        }
      },
    );
  }

  // --- 1. THE STANDARD ALERT (For Battery & Offline Status) ---
  static Future<void> showStandardAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'system_alerts',
      'System Alerts',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFFFA000), // Warning Orange
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  // --- 2. THE RICH ALERT (For Heart Rate & Falls) ---
  static Future<void> showRichVitalAlert({
    required int id,
    required String title,
    required String subtitle,
    required String expandedBody,
  }) async {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      expandedBody,
      contentTitle: title,
      summaryText: subtitle,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'vital_alerts_channel',
      'Emergency Vital Alerts',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigTextStyleInformation,
      color: const Color(0xFFE53935), // Emergency Red
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'call_now',
          'Call Now',
          showsUserInterface: true,
        ),
      ],
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, subtitle, platformDetails);
  }
}