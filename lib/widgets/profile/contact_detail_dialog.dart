import 'package:flutter/material.dart';
import 'package:safest/models/emergency_contact.dart';
// Asumsi Anda memiliki service untuk delete, jika tidak, ini hanya simulasi
// import 'package:safest/services/contact_service.dart'; 

class ContactDetailDialog extends StatelessWidget {
  final EmergencyContact contact;
  // Tambahkan mock service jika diperlukan untuk aksi delete
  // final ContactService _contactService = ContactService(); 

  const ContactDetailDialog({super.key, required this.contact});

  // --- FUNGSI BARU UNTUK KONFIRMASI DELETE ---
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // 1. (Opsional) Panggil service delete di sini
                // 2. Tutup dialog konfirmasi
                Navigator.of(dialogContext).pop(); 
                
                // 3. Tutup dialog detail kontak & kirim 'true' kembali
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
    const primaryPurple = Color(0xFF6A1B9A);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Padding dikurangi agar tombol memiliki ruang lebih
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
                // Menggunakan contact.avatarUrl yang berisi path aset
                image: AssetImage(contact.avatarUrl), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Nama
          Text(
            contact.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryPurple),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE1BEE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              contact.relationship,
              style: const TextStyle(fontSize: 12, color: primaryPurple, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),

          // Tombol Aksi
          Row(
            // Menggunakan spaceAround untuk distribusi yang lebih baik dalam ruang sempit
            mainAxisAlignment: MainAxisAlignment.spaceAround, 
            children: [
              OutlinedButton(
                onPressed: () {
                  // Aksi Edit
                  Navigator.pop(context, false); // Tutup dialog, return false (tidak dihapus)
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10), // Padding disesuaikan
                  minimumSize: const Size(70, 38), // Ukuran minimum
                ),
                child: const Text('Edit'), // TEKS DIPERSINGKAT
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
                  padding: const EdgeInsets.symmetric(horizontal: 10), // Padding disesuaikan
                  minimumSize: const Size(70, 38), // Ukuran minimum
                ),
                child: const Text('Delete'), // TEKS DIPERSINGKAT
              ),
            ],
          ),
        ],
      ), 
    );
  }
}