import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfileData({
    required String uid,
    required String displayName,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'displayName': displayName,
        'details': details,
        'isLive': false, // default false
        'position': GeoPoint(0.0, 0.0), // default posisi 0,0
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save profile: $e");
    }
  }

  Future<void> saveEmergencyContact({
    required String uid,
    required Map<String, dynamic> emergencyContacts,
  }) async {
    try {
      await _firestore.collection("users").doc(uid).update({
        "emergencyContacts": emergencyContacts,
      });
    } catch (e) {
      throw Exception("Failed to save emergency contact: $e");
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      throw Exception("Failed to load profile: $e");
    }
  }
}
