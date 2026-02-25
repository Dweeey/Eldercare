import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetricsRepository {
  final FirebaseFirestore _firestore;

  HealthMetricsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getLatestMetric(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_metrics')
        .orderBy('recorded_at', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    return {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id};
  }

  Future<List<Map<String, dynamic>>> getWeeklyMetrics(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_metrics')
        .orderBy('recorded_at', descending: true)
        .limit(7)
        .get();
    return snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  Future<void> generateSampleMetrics(String userId, DateTime now) async {
    for (int i = 6; i >= 0; i--) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_metrics')
          .add({
        'heart_rate': 65 + (i * 5) + (i == 2 ? 15 : 0),
        'blood_pressure_systolic': 120 + i,
        'blood_pressure_diastolic': 80 + i,
        'spo2_level': 95 + (i % 5),
        'recorded_at': now.subtract(Duration(days: i)),
      });
    }
  }
}
