// import 'dart:convert';
// import 'package:flutter/material.dart';

enum AddContactMode { phone, id }

class ContactService {
  static const String _baseUrl = 'https://api.yourdomain.com/v1/contacts';

  // Data Dummy static agar persisten selama sesi aplikasi
  static final List<Map<String, dynamic>> _contacts = [
    {'name': 'Cleopatra', 'relationship': 'Sister', 'avatarUrl': 'assets/avatar_pink.png', 'phone_number': '+62812345678', 'user_id': 'CLEO1'},
    {'name': 'Sangkuriang', 'relationship': 'Father', 'avatarUrl': 'assets/avatar_pink.png', 'phone_number': '+62898765432', 'user_id': 'SANG1'},
  ];

  Future<List<Map<String, dynamic>>> fetchContacts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_contacts);
  }

  Future<bool> addContact({
    required AddContactMode mode,
    String? name,
    String? phone,
    String? id,
    required String relationship,
  }) async {
  await Future.delayed(const Duration(seconds: 1));
  try {
    if (mode == AddContactMode.phone && name != null && phone != null) {
      _contacts.add({
        'name': name,
        'relationship': relationship,
        'avatarUrl': 'assets/images/avatar_pink.png', // Default asset
        'phone_number': phone, // Key ini harus sama dengan di _loadContacts
        'user_id': null,
      });
      return true; // Berhasil
    }
      return false;
    } catch (e) {
      return false;
    }
  }

  // FUNGSI BARU: Hapus Kontak
  Future<bool> deleteContact(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _contacts.removeWhere((contact) => contact['name'] == name);
    return true;
  }
}