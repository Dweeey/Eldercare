import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationsRepository {
  final FirebaseFirestore _firestore;

  MedicationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchMedications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> addMedication({
    required String userId,
    required String name,
    required String dosage,
    required String frequency,
    required String reason,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .add({
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'reason': reason,
      'start_date': DateTime.now().toIso8601String(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMedication(String userId, String medicationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .doc(medicationId)
        .delete();
  }
}
