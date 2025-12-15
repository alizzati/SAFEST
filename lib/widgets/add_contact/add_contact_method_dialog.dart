import 'package:flutter/material.dart';
import 'package:safest/services/contact_service.dart';

class AddContactMethodDialog extends StatelessWidget {
  const AddContactMethodDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Emergency Contact',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choose how you want to add your emergency contact. You can add an emergency contact by their registered number or paste their ID.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // menutup dialog dan mengembalikan Mode yang dipilih
          _buildModeButton(context, 'Add by Phone Number', AddContactMode.phone),
          const SizedBox(height: 10),
          _buildModeButton(context, 'Add by ID', AddContactMode.id),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String text, AddContactMode mode) {
    return ElevatedButton(
      onPressed: () {
        // Kembalikan Mode yang dipilih ke ProfileScreen
        Navigator.pop(context, mode);
      },
      style: ElevatedButton.styleFrom( 
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF6A1B9A), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text( 
        text,
        style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 16),
      ),
    );
  }
}