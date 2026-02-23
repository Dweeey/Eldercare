import 'package:supabase_flutter/supabase_flutter.dart';

class HealthMetricsRepository {
  final SupabaseClient _client;

  HealthMetricsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> getLatestMetric(String userId) async {
    final response = await _client
        .from('health_metrics')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(response.first);
  }

  Future<List<Map<String, dynamic>>> getWeeklyMetrics(String userId) async {
    final response = await _client
        .from('health_metrics')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(7);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> generateSampleMetrics(String userId, DateTime now) async {
    for (int i = 6; i >= 0; i--) {
      await _client.from('health_metrics').insert({
        'user_id': userId,
        'heart_rate': 65 + (i * 5) + (i == 2 ? 15 : 0),
        'blood_pressure_systolic': 120 + i,
        'blood_pressure_diastolic': 80 + i,
        'spo2_level': 95 + (i % 5),
        'recorded_at': now.subtract(Duration(days: i)).toIso8601String(),
      });
    }
  }
}
