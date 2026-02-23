import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyContactsRepository {
  final SupabaseClient _client;

  EmergencyContactsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchContacts(String userId) async {
    final response = await _client
        .from('emergency_contacts')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addContact({
    required String userId,
    required String name,
    required String phone,
    required String relationship,
  }) async {
    await _client.from('emergency_contacts').insert({
      'user_id': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    });
  }

  Future<void> deleteContact(int contactId) async {
    await _client.from('emergency_contacts').delete().eq('id', contactId);
  }
}
