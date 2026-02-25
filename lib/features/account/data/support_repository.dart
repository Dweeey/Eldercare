import 'package:cloud_firestore/cloud_firestore.dart';

class SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFaqs() async {
    final snapshot = await _firestore
        .collection('faqs')
        .orderBy('order', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  Future<void> submitSupportRequest({
    required String userId,
    required String subject,
    required String message,
    required String category,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('support_requests')
        .add({
      'subject': subject,
      'message': message,
      'category': category,
      'status': 'open',
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
