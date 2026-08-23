import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // USER PROFILE
  // ============================================================

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

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? requestId,
    String? listingId,
    String? chatId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'message': message,
      'type': type,
      'requestId': requestId,
      'listingId': listingId,
      'chatId': chatId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all notifications for a user.
  Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream(
      String userId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark one notification as read.
  Future<void> markNotificationAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // Mark all notifications as read.
  Future<void> markAllNotificationsAsRead(
      String userId,
      ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(
        document.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

  // Count unread notifications.
  Stream<int> unreadNotificationCount(
      String userId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}