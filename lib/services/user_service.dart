import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updatePersonalInfo({
    required String uid,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String country,
    required String address,
    required String postCode,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        'city': city,
        'country': country,
        'streetAddress': address,
        'postCode': postCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to update personal info: $e");
    }
  }

  Future<Map<String, dynamic>?> findUserByPhone(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where(
            'details.phoneNumber',
            isEqualTo: phoneNumber,
          ) // Asumsi struktur data profile
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        final queryRoot = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (queryRoot.docs.isNotEmpty) {
          final data = queryRoot.docs.first.data();
          data['customId'] =
              data['customId'] ??
              queryRoot.docs.first.id.substring(0, 6).toUpperCase();
          return data;
        }
      } else {
        final data = query.docs.first.data();
        data['customId'] =
            data['customId'] ??
            query.docs.first.id.substring(0, 6).toUpperCase();
        return data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images/$uid.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      await _firestore.collection('users').doc(uid).update({
        'avatarUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload profile picture: $e");
    }
  }

  String _generateShortId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> generateAndSaveUserShortId(String uid, String email) async {
    String shortId = _generateShortId();
    bool isUnique = false;
    int attempts = 0;
    while (!isUnique && attempts < 5) {
      final query = await _firestore
          .collection('users')
          .where('customId', isEqualTo: shortId)
          .get();

      if (query.docs.isEmpty) {
        isUnique = true;
      } else {
        shortId = _generateShortId(); // Generate ulang jika kembar
        attempts++;
      }
    }

    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'customId': shortId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> findUserByCustomId(String customId) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('customId', isEqualTo: customId.toUpperCase().trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception("Error finding user: $e");
    }
  }

  Future<void> updateAvatar(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'avatarUrl': imageUrl,
      });
    } catch (e) {
      throw Exception("Failed to update avatar: $e");
    }
  }

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
        'position': GeoPoint(0.0, 0.0),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save profile: $e");
    }
  }

  Future<Map<String, dynamic>?> findUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception("Error finding user: $e");
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
