import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactsRepository {
  final FirebaseFirestore _firestore;

  EmergencyContactsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchContacts(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('emergency_contacts')
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> addContact({
    required String userId,
    required String name,
    required String phone,
    required String relationship,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('emergency_contacts')
        .add({
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContact(String userId, String contactId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('emergency_contacts')
        .doc(contactId)
        .delete();
  }
}
