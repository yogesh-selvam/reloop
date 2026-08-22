import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String college,
    required String department,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'college': college,
      'department': department,
      'profileImage': '',
      'ecoPoints': 0,
      'itemsReused': 0,
      'exchanges': 0,
      'donations': 0,
      'co2Saved': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
      String uid,
      ) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}
