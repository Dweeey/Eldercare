import 'package:supabase_flutter/supabase_flutter.dart';

class SupportRepository {
  final SupabaseClient _client;

  SupportRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchFaqs() async {
    final response = await _client.from('faqs').select().order(
          'order',
          ascending: true,
        );
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> submitSupportRequest({
    required String userId,
    required String subject,
    required String message,
    required String category,
  }) async {
    await _client.from('support_requests').insert({
      'user_id': userId,
      'subject': subject,
      'message': message,
      'category': category,
      'status': 'open',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
