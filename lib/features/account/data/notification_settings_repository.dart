import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettingsRepository {
  final SupabaseClient _client;

  NotificationSettingsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchSettings(String userId) async {
    final response = await _client
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) {
      return null;
    }
    return Map<String, dynamic>.from(response);
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
    await _client.from('notification_settings').upsert({
      'user_id': userId,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'medication_reminders': medicationReminders,
      'appointment_reminders': appointmentReminders,
      'emergency_alerts': emergencyAlerts,
      'health_updates': healthUpdates,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
