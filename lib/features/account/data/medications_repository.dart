import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationsRepository {
  final SupabaseClient _client;

  MedicationsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMedications(String userId) async {
    final response =
        await _client.from('medications').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addMedication({
    required String userId,
    required String name,
    required String dosage,
    required String frequency,
    required String reason,
  }) async {
    await _client.from('medications').insert({
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'reason': reason,
      'start_date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteMedication(int medicationId) async {
    await _client.from('medications').delete().eq('id', medicationId);
  }
}
