import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmartwatchData {
  final String bloodPressure;
  final String bpStatus;
  final bool fallDetected;
  final String heartRate;
  final String spo2;
  final String statusMessage;
  final int timestamp;

  SmartwatchData({
    required this.bloodPressure,
    required this.bpStatus,
    required this.fallDetected,
    required this.heartRate,
    required this.spo2,
    required this.statusMessage,
    required this.timestamp,
  });

  factory SmartwatchData.fromMap(Map<String, dynamic> map) {
    return SmartwatchData(
      bloodPressure: map['bloodPressure'] ?? 'N/A',
      bpStatus: map['bpStatus'] ?? 'Unknown',
      fallDetected: map['fallDetected'] ?? false,
      heartRate: map['heartRate'] ?? 'N/A',
      spo2: map['spo2'] ?? 'N/A',
      statusMessage: map['statusMessage'] ?? 'Scanning...',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodPressure': bloodPressure,
      'bpStatus': bpStatus,
      'fallDetected': fallDetected,
      'heartRate': heartRate,
      'spo2': spo2,
      'statusMessage': statusMessage,
      'timestamp': timestamp,
    };
  }
}

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get smartwatch data for a patient
  Future<SmartwatchData?> getSmartwatchData(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (doc.exists) {
        return SmartwatchData.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching smartwatch data: $e');
      return null;
    }
  }

  /// Stream smartwatch data for real-time updates
  Stream<SmartwatchData?> streamSmartwatchData(String patientId) {
    return _firestore
        .collection('patients')
        .doc(patientId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return SmartwatchData.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get smartwatch history
  Future<List<SmartwatchData>> getSmartwatchHistory(String patientId,
      {int limit = 50}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SmartwatchData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching smartwatch history: $e');
      return [];
    }
  }

  /// Stream smartwatch history
  Stream<List<SmartwatchData>> streamSmartwatchHistory(String patientId,
      {int limit = 50}) {
    return _firestore
        .collection('patients')
        .doc(patientId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SmartwatchData.fromMap(doc.data()))
            .toList());
  }

  /// Link smartwatch to user by patient ID
  Future<void> linkSmartwatchToUser(
      String userId, String patientId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'linkedPatientId': patientId,
        'linkedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error linking smartwatch: $e');
      rethrow;
    }
  }

  /// Get user's linked patient ID
  Future<String?> getLinkedPatientId(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc['linkedPatientId'];
      }
      return null;
    } catch (e) {
      print('Error getting linked patient ID: $e');
      return null;
    }
  }

  /// Stream user's linked patient ID
  Stream<String?> streamLinkedPatientId(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc['linkedPatientId'];
      }
      return null;
    });
  }

  /// Get user document by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update pairing request when mobile app scans smartwatch QR
  /// This notifies the smartwatch that pairing is complete
  Future<void> updatePairingRequest(
    String pairingId,
    String patientId,
    String userId,
  ) async {
    try {
      await _firestore
          .collection('pairing_requests')
          .doc(pairingId)
          .update({
        'status': 'paired',
        'patientId': patientId,
        'pairedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating pairing request: $e');
      rethrow;
    }
  }

  /// Set user's patient ID in Firestore
  Future<void> setUserPatientId(String userId, String patientId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'linkedPatientId': patientId,
        'linkedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting user patient ID: $e');
      rethrow;
    }
  }
}
