import 'package:flutter/material.dart';
import 'package:safest/models/emergency_status.dart'; 

class StatusCard extends StatelessWidget {
  final EmergencyStatus status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Warna ungu utama
    const primaryPurple = Color(0xFF6A1B9A);

    return Container(
      width: double.infinity,
      // Mengurangi margin bawah di sini karena sudah diatur di Sized Box
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: primaryPurple,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon, color: primaryPurple, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              status.text,
              style: const TextStyle(
                color: primaryPurple,
                fontSize: 14,
                height: 1.4, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}