import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:safest/models/emergency_contact.dart';

enum AddContactMode { phone, id }

class ContactService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchContacts() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return [];

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (data.containsKey('emergencyContacts')) {
          dynamic rawContacts = data['emergencyContacts'];

          if (rawContacts is List) {
            return rawContacts.map((e) => Map<String, dynamic>.from(e)).toList();
          } 
          else if (rawContacts is Map) {
            return rawContacts.values
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      return [];
    }
  }

  Future<bool> editContact({
    required EmergencyContact oldContact,
    required Map<String, dynamic> newContactData,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot snapshot = await userDoc.get();

      if (!snapshot.exists) return false;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> rawContacts = data['emergencyContacts'] ?? [];

      List<Map<String, dynamic>> contactsList = 
          rawContacts.map((e) => Map<String, dynamic>.from(e)).toList();

      int index = contactsList.indexWhere((c) => 
          c['name'] == oldContact.name && 
          c['phone_number'] == oldContact.phoneNumber
      );

      if (index != -1) {
        contactsList[index] = {
          'name': newContactData['name'],
          'phone_number': newContactData['phone_number'],
          'relationship': newContactData['relationship'],
          'user_id': newContactData['user_id'], 
          'avatarUrl': newContactData['avatarUrl'] ?? 'assets/images/avatar_pink.png',
          'addedAt': Timestamp.now(), 
        };

        await userDoc.update({'emergencyContacts': contactsList});
        return true;
      }

      return false; // Kontak tidak ditemukan
    } catch (e) {
      debugPrint("Error editing contact: $e");
      return false;
    }
  }

  Future<bool> addContact({
    required AddContactMode mode,
    String? name,
    String? phone,
    String? id,
    required String relationship,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      Map<String, dynamic> newContact = {
        'name': name ?? 'Unknown',
        'relationship': relationship,
        'avatarUrl': 'assets/images/avatar_pink.png',
        'phone_number': phone ?? '',
        'user_id': id,
        'addedAt': Timestamp.now(),
      };

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['emergencyContacts'] is Map) {
           await _firestore.collection('users').doc(user.uid).update({
             'emergencyContacts': [newContact]
           });
           return true;
        }
      }

      await _firestore.collection('users').doc(user.uid).update({
        'emergencyContacts': FieldValue.arrayUnion([newContact])
      });

      return true;
    } catch (e) {
      debugPrint("Error adding contact: $e");
      return false;
    }
  }

  Future<bool> deleteContact(String name) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) return false;

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      var rawContacts = data['emergencyContacts'];

      if (rawContacts is List) {
        var contactToDelete = rawContacts.firstWhere(
          (c) => c['name'] == name,
          orElse: () => null,
        );

        if (contactToDelete != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'emergencyContacts': FieldValue.arrayRemove([contactToDelete])
          });
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint("Error deleting contact: $e");
      return false;
    }
  }
}