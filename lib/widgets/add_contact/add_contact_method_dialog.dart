import 'package:flutter/material.dart';
import 'add_contact_form_dialog.dart';
import 'package:safest/services/contact_service.dart';

class AddContactMethodDialog extends StatelessWidget {
  const AddContactMethodDialog({super.key});

  // Fungsi untuk menampilkan Pop Up 2 atau 3
  void _showFormDialog(BuildContext context, AddContactMode mode) {
    // Tutup Pop Up 1 terlebih dahulu
    Navigator.pop(context); 
    
    // Tampilkan Pop Up 2 atau 3
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddContactFormDialog(mode: mode);
      },
    ).then((added) {
      // Setelah Pop Up 2/3 selesai, kembalikan status ke ProfileScreen
      if (added == true) {
        Navigator.pop(context, true); 
      }
    });
  }

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

          _buildModeButton(context, 'Add by Phone Number', AddContactMode.phone),
          const SizedBox(height: 10),
          _buildModeButton(context, 'Add by ID', AddContactMode.id),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String text, AddContactMode mode) {
    return ElevatedButton(
      onPressed: () => _showFormDialog(context, mode),
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