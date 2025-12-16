import 'package:flutter/material.dart';
import 'package:safest/models/emergency_contact.dart';

// Widget untuk Contact Card
class ContactCard extends StatelessWidget {
  final EmergencyContact contact;

  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // Sedikit diperlebar agar nama tidak gampang terpotong
      margin: const EdgeInsets.symmetric(vertical: 5), // Margin vertikal untuk shadow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(contact.avatarUrl.isNotEmpty 
                          ? contact.avatarUrl 
                          : 'assets/images/avatar_pink.png'),
                      fit: BoxFit.cover,
                      // Error builder jika asset tidak ditemukan
                      onError: (exception, stackTrace) {}, 
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.relationship,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey, 
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Icon titik tiga di pojok kanan atas
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.more_vert, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Widget untuk Tombol Tambah Kontak
class AddContactCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddContactCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 15, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          // Tidak pakai shadow agar terlihat beda (seperti tombol placeholder)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 24, color: Color(0xFF512DA8)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add New",
              style: TextStyle(
                color: Color(0xFF512DA8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}