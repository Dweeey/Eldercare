import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eldercareapp/firebase_options.dart'; 

class VitalMonitorService {
  static Future<void> initializeBackgroundService() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'system_alerts', 
      'System Alerts',
      description: 'Keeps the Eldercare Monitor running in the background.',
      importance: Importance.high, 
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'system_alerts', 
        initialNotificationTitle: 'Eldercare Monitor Active',
        initialNotificationContent: 'Monitoring patient vitals 24/7...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground, 
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

// --- BULLETPROOF BACKGROUND NOTIFICATION HELPER ---
Future<void> _showBackgroundNotification(int id, String title, String body) async {
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'system_alerts', 'System Alerts',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''), 
    icon: '@mipmap/ic_launcher', // 🚨 ADD THIS LINE: Tells Android what picture to put on the notification
  );
  await plugin.show(id, title, body, const NotificationDetails(android: androidDetails));
}

// ----------------------------------------------------------------------
// THE "BRAIN" 
// ----------------------------------------------------------------------

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cooldown Trackers 
  DateTime? lastHrAlert;
  DateTime? lastFallAlert;
  DateTime? lastBpAlert;
  DateTime? lastBatteryAlert;
  DateTime? lastOffWristAlert;

  const int cooldownMinutes = 0; // 0 for instant testing
  const int batteryCooldownMinutes = 0; 
  const String patientId = 'patient_001';
  bool previousFallState = false;
  bool isCurrentlyOffWrist = false;

  // =====================================================================
  // THE NEW BRAIN: Active Polling every 10 seconds instead of WebSockets
  // =====================================================================
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('patients').doc(patientId).get();
      if (!doc.exists) return;
      
      final data = doc.data() as Map<String, dynamic>;
      final now = DateTime.now();

      // --- HEART RATE ---
      if (data['heartRate'] != null && data['heartRate'] != '--') {
        int hr = int.tryParse(data['heartRate'].toString()) ?? 0;
        if (hr > 100) {
          if (lastHrAlert == null || now.difference(lastHrAlert!).inMinutes >= cooldownMinutes) {
            int percentage = (((hr - 100) / 100) * 100).round();
            _showBackgroundNotification(1, '❤️ Heart Rate Critical: $hr bpm', 'Patient heart rate is elevated (+$percentage%). Please check on them.');
            _saveAlertToDb('Heart Rate Critical', '$hr bpm', 'Current: $hr bpm (+$percentage%).', 'critical');
            lastHrAlert = now;
          }
        }
      }

      // --- FALL DETECTION ---
      // --- FALL DETECTION (Instant Trigger) ---
      // --- FALL DETECTION (Instant & Repeatable) ---
      bool currentFallState = data['fallDetected'] == true || data['fallDetected'].toString().toLowerCase() == 'true';

      // TRIGGER: If it just turned TRUE (meaning a new fall was detected)
      if (currentFallState && !previousFallState) {
        _showBackgroundNotification(
          2, 
          '🚨 FALL DETECTED 🚨', 
          'Smartwatch detected a hard impact. Immediate action required!'
        );
        _saveAlertToDb('Fall Detected', 'Smartwatch detected an impact', 'Check immediately.', 'critical');
      }

      // RESET: This is the key! 
      // As soon as the database is set back to 'false', previousFallState becomes 'false'.
      // This "arms" the trap so it can fire again instantly on the next 'true'.
      previousFallState = currentFallState;

      // --- BLOOD PRESSURE ---
      // --- BLOOD PRESSURE ---
      if (data['bloodPressure'] != null && data['bloodPressure'] != '--') {
        List<String> bpParts = data['bloodPressure'].toString().split('/');
        if (bpParts.length == 2) {
          int sys = int.tryParse(bpParts[0].trim()) ?? 0;
          int dia = int.tryParse(bpParts[1].trim()) ?? 0;
          if (sys >= 120 || dia >= 80) {
            
            // 🚨 THE FIX: Hardcoded to wait exactly 1 minute between BP alerts!
            if (lastBpAlert == null || now.difference(lastBpAlert!).inMinutes >= 1) {
              bool isCritical = (sys >= 140 || dia >= 90);
              String title = isCritical ? '‼️ Blood Pressure: High (Stage 2)' : '🚨 Blood Pressure: Elevated';
              String body = isCritical ? 'Current: $sys/$dia mmHg. Seek medical attention.' : 'Current: $sys/$dia mmHg. Please monitor closely.';
              
              _showBackgroundNotification(5, title, body);
              _saveAlertToDb(title, '$sys/$dia mmHg', 'Please monitor closely.', isCritical ? 'critical' : 'warning');
              lastBpAlert = now; // Resets the timer
            }
            
          }
        }
      }

      // --- BATTERY ---
      if (data['batteryLevel'] != null) {
        int battery = int.tryParse(data['batteryLevel'].toString()) ?? 100;
        if (battery <= 15) {
          if (lastBatteryAlert == null || now.difference(lastBatteryAlert!).inMinutes >= batteryCooldownMinutes) {
            _showBackgroundNotification(3, '🔋 Low Battery Warning', 'The smartwatch battery is at $battery%. Please charge it soon.');
            _saveAlertToDb('Low Battery Warning', 'Battery at $battery%', 'Please remind patient to charge the device.', 'warning');
            lastBatteryAlert = now;
          }
        }
      }
      
      // --- OFF WRIST DETECTION (State-Based, No Spam) ---
      bool watchIsOff = (data['bpStatus'] == 'Watch Off Wrist' || data['statusMessage'] == 'Watch Off Wrist');

      if (watchIsOff && !isCurrentlyOffWrist) {
        // SCENARIO A: It was just taken off!
        _showBackgroundNotification(6, '⌚ Watch Removed', 'The smartwatch has been taken off the patient\'s wrist. Monitoring is paused.');
        _saveAlertToDb('Watch Removed', 'Device off wrist', 'Please ensure the patient is wearing the device.', 'warning');
        
        isCurrentlyOffWrist = true; // Lock the state so it doesn't spam
        
      } else if (!watchIsOff && isCurrentlyOffWrist) {
        // SCENARIO B: It was just put back on!
        _showBackgroundNotification(7, '✅ Watch Connected', 'The smartwatch is back on the patient\'s wrist. Monitoring resumed.');
        _saveAlertToDb('Watch Connected', 'Device on wrist', 'Monitoring has successfully resumed.', 'info');
        
        isCurrentlyOffWrist = false; // Reset the state so it can detect the next removal
      }

    } catch (e) {
      // Fails silently if internet is completely gone, will try again in 10 seconds
    }
  });
}

Future<void> _saveAlertToDb(String title, String subtitle, String details, String severity) async {
  await FirebaseFirestore.instance.collection('alerts').add({
    'title': title, 'subtitle': subtitle, 'details': details, 'severity': severity, 'timestamp': FieldValue.serverTimestamp(),
  });
}