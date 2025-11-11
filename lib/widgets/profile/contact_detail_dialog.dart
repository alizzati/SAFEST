import 'package:flutter/material.dart';
import 'package:safest/models/emergency_contact.dart';
// Asumsi Anda memiliki service untuk delete, jika tidak, ini hanya simulasi
// import 'package:safest/services/contact_service.dart'; 

class ContactDetailDialog extends StatelessWidget {
  final EmergencyContact contact;

  const ContactDetailDialog({super.key, required this.contact});

  // --- FUNGSI BARU UNTUK KONFIRMASI DELETE ---
  void _showDeleteConfirmationDialog(BuildContext context) {
    // 'context' di sini adalah context dari ContactDetailDialog
    
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) { // 'dialogContext' adalah context dari AlertDialog
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah anda yakin ingin menghapus contact ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                // Tutup dialog konfirmasi
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // 1. (Opsional) Panggil service delete di sini
                // final contactService = ContactService();
                // await contactService.deleteContact(contact.id); 
                
                // 2. Tutup dialog konfirmasi
                Navigator.of(dialogContext).pop(); 
                
                // 3. Tutup dialog detail kontak (ContactDetailDialog)
                //    dan kirim 'true' kembali ke ProfileScreen
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
            ),
          ),
          const SizedBox(height: 8),

          // Nama
          Text(
            contact.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 4),

          // Nomor Telepon/ID (Simulasi)
          Text(
            contact.phoneNumber ?? contact.userId ?? 'N/A', 
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 4),

          // Label Relationship
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE1BEE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              contact.relationship,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),

          // Tombol Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Aksi Edit
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Edit Contact'),
              ),
              OutlinedButton(
                onPressed: () {
                  // PANGGIL FUNGSI KONFIRMASI DELETE
                  _showDeleteConfirmationDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Delete Contact'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}