import 'dart:convert';
import 'package:flutter/material.dart';

// Enum untuk mode pengisian form
enum AddContactMode { phone, id }

class ContactService {
  // Simulasi endpoint URL (Ganti dengan URL API Anda)
  static const String _baseUrl = 'https://api.yourdomain.com/v1/contacts';

  // Daftar kontak saat ini (Simulasi data di memory)
  final List<Map<String, dynamic>> _contacts = [
    {'name': 'Cleopatra', 'relationship': 'Sister', 'avatarUrl': 'assets/avatar_pink.png'},
    {'name': 'Sangkuriang', 'relationship': 'Father', 'avatarUrl': 'assets/avatar_pink.png'},
  ];

  // Metode untuk mengambil kontak
  Future<List<Map<String, dynamic>>> fetchContacts() async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_contacts);
  }

  // Metode untuk menambahkan kontak (Simulasi POST API)
  Future<bool> addContact({
    required AddContactMode mode,
    String? name,
    String? phone,
    String? id,
    required String relationship,
  }) async {
    debugPrint('Simulating API call to add contact via ${mode.name}');

    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (mode == AddContactMode.phone && name != null && phone != null) {
        // Data yang akan dikirim ke API /add/phone
        final requestBody = jsonEncode({
          'name': name,
          'phone_number': phone,
          'relationship': relationship,
        });
        debugPrint('Request Body (Phone): $requestBody');

        // Simulasi sukses dan tambahkan ke data lokal
        _contacts.add({'name': name, 'relationship': relationship, 'avatarUrl': 'assets/avatar_pink.png'});
        return true;

      } else if (mode == AddContactMode.id && id != null) {
        // Data yang akan dikirim ke API /add/id
        final requestBody = jsonEncode({
          'user_id': id,
          'relationship': relationship,
        });
        debugPrint('Request Body (ID): $requestBody');

        // Simulasi sukses dan tambahkan ke data lokal
        _contacts.add({'name': 'New User ID', 'relationship': relationship, 'avatarUrl': 'assets/avatar_pink.png'});
        return true;

      } else {
        throw Exception('Data tidak lengkap untuk mode ${mode.name}');
      }
    } catch (e) {
      debugPrint('Error adding contact: $e');
      return false; // Simulasi kegagalan
    }
  }
}