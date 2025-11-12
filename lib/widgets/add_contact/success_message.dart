import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan AlertDialog untuk membungkus konten pesan sukses
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      // Setel margin/border untuk meniru border ungu
      backgroundColor: Colors.transparent, 
      elevation: 0, 
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF6A1B9A), width: 3), // Border Ungu
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lingkaran Hijau
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.lightGreen, width: 2),
              ),
              child: Icon(Icons.check, color: Colors.lightGreen, size: 30),
            ),
            const SizedBox(height: 15), 
            Text(
              'Emergency contact has been added successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6A1B9A),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}