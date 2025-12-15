import 'package:flutter/material.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart'; 

class ContactDetailDialog extends StatelessWidget {
  final EmergencyContact contact;
  // Service untuk menghapus data
  final ContactService _contactService = ContactService(); 

  ContactDetailDialog({super.key, required this.contact});

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // 1. Hapus kontak di service
                await _contactService.deleteContact(contact.name); 
                
                // 2. Tutup dialog konfirmasi
                Navigator.of(dialogContext).pop(); 
                
                // 3. Tutup dialog detail & kirim 'true' ke ProfileScreen
                Navigator.of(context).pop(true); 
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(contact.avatarUrl),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: const Color(0xFF512DA8), width: 2),
            ),
          ),
          const SizedBox(height: 10),

          // Nama
          Text(
            contact.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF512DA8)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),

          // Info Tambahan
          Text(
            contact.phoneNumber ?? contact.userId ?? 'N/A', 
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),

          // Badge Relationship
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE1BEE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              contact.relationship,
              style: const TextStyle(fontSize: 12, color: Color(0xFF512DA8), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // --- BAGIAN YANG DIPERBAIKI (Expanded Buttons) ---
          Row(
            children: [
              // Tombol Edit (Dibungkus Expanded)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12), // Padding vertikal
                  ),
                  child: const Text(
                    'pEdit', 
                    overflow: TextOverflow.ellipsis, // Mencegah teks panjang
                  ),
                ),
              ),
              
              const SizedBox(width: 10), // Jarak antar tombol
              
              // Tombol Delete (Dibungkus Expanded)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12), // Padding vertikal
                  ),
                  child: const Text(
                    'Delete', 
                    overflow: TextOverflow.ellipsis, // Mencegah teks panjang
                  ),
                ),
              ),
            ],
          ),
          // --- AKHIR PERBAIKAN ---
        ],
      ), 
    );
  }
}