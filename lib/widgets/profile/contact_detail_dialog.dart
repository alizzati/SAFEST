import 'package:flutter/material.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/widgets/add_contact/edit_contact_dialog.dart'; 

class ContactDetailDialog extends StatelessWidget {
  final EmergencyContact contact;
  final ContactService _contactService = ContactService();

  ContactDetailDialog({super.key, required this.contact});

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${contact.name}?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _contactService.deleteContact(contact.name); 
                
                if (context.mounted) {
                  Navigator.of(dialogContext).pop(); 
                  Navigator.of(context).pop(true);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contact deleted")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditContactDialog(contact: contact),
    ).then((result) {
      if (result == true) {
        Navigator.pop(context, true); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF512DA8);
    final screenWidth = MediaQuery.of(context).size.width;
    final String displayId = (contact.userId != null && contact.userId!.isNotEmpty)
        ? contact.userId!
        : "Non user";


    final String displayPhone = (contact.phoneNumber != null && contact.phoneNumber!.isNotEmpty)
        ? contact.phoneNumber!
        : "-"; 

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryPurple.withOpacity(0.2), width: 3),
                image: DecorationImage(
                  image: (contact.avatarUrl.isNotEmpty && contact.avatarUrl.startsWith('http'))
                      ? NetworkImage(contact.avatarUrl) as ImageProvider
                      : const AssetImage('assets/images/avatar_pink.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              contact.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 20),

            _buildDetailRow(
              icon: Icons.badge_outlined,
              label: "User ID",
              value: displayId,
              isId: true, 
            ),
            
            const SizedBox(height: 15),

            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: "Phone Number",
              value: displayPhone,
            ),

            const SizedBox(height: 15),

            _buildDetailRow(
              icon: Icons.favorite_border,
              label: "Relationship",
              value: contact.relationship,
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryPurple,
                      side: const BorderSide(color: primaryPurple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50], // Background merah muda
                      foregroundColor: Colors.red, // Teks merah
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text("Delete"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon, 
    required String label, 
    required String value,
    bool isId = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF512DA8), size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  // Jika ID dan bernilai "Non user", beri warna abu agar beda
                  color: (isId && value == "Non user") ? Colors.grey : Colors.black87,
                  fontStyle: (isId && value == "Non user") ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}