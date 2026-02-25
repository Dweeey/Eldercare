import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsRepository {
  final FirebaseFirestore _firestore;

  NotificationSettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchSettings(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .get();
    if (!doc.exists) {
      return null;
    }
    return doc.data();
  }

  Future<void> saveSettings({
    required String userId,
    required bool emailNotifications,
    required bool pushNotifications,
    required bool medicationReminders,
    required bool appointmentReminders,
    required bool emergencyAlerts,
    required bool healthUpdates,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .set({
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'medication_reminders': medicationReminders,
      'appointment_reminders': appointmentReminders,
      'emergency_alerts': emergencyAlerts,
      'health_updates': healthUpdates,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
