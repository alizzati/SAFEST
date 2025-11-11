import 'package:flutter/material.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/widgets/add_contact/success_message.dart';

class AddContactFormDialog extends StatefulWidget {
  final AddContactMode mode;

  const AddContactFormDialog({super.key, required this.mode});

  @override
  State<AddContactFormDialog> createState() => _AddContactFormDialogState();
}

class _AddContactFormDialogState extends State<AddContactFormDialog> {
  final ContactService _contactService = ContactService();
  bool _isAdding = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    _idController.dispose();
    super.dispose();
  }
  
  // Proses penambahan kontak
  Future<void> _addContact() async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    bool success = false;
    
    if (widget.mode == AddContactMode.phone) {
      success = await _contactService.addContact(
        mode: AddContactMode.phone,
        name: _nameController.text,
        phone: _phoneController.text,
        relationship: _relationshipController.text,
      );
    } else {
      success = await _contactService.addContact(
        mode: AddContactMode.id,
        id: _idController.text,
        relationship: _relationshipController.text,
      );
    }

    setState(() => _isAdding = false);

    if (success) {
      // 1. Tutup Pop Up 2/3 (Form)
      Navigator.pop(context);
      
      // 2. Tampilkan Pop Up 4 (Success)
      await showDialog(
        context: context,
        builder: (context) => const SuccessDialog(),
      );
      
      // 3. Kembalikan status sukses ke Pop Up 1 (AddContactMethodDialog)
      //    Pop Up 1 akan meneruskan ini ke ProfileScreen untuk refresh.
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } else {
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add contact!')));
    }
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
          // Sub-judul form
          Text(
            widget.mode == AddContactMode.phone 
                ? 'Add Contact by Phone Number' 
                : 'Add Contact by ID',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 20),

          // Form Field
          if (widget.mode == AddContactMode.phone) ...[
            _buildTextField('Emergency Contact Name', 'Enter contact\'s full name', _nameController),
            _buildTextField('Emergency Contact Phone Number', 'Select relationship', _phoneController, keyboardType: TextInputType.phone),
          ] else ...[
            _buildTextField('Emergency Contact ID', 'Enter contact\'s ID', _idController),
          ],
          
          _buildTextField('Relationship with Contact', 'Enter relationship', _relationshipController),
          
          const SizedBox(height: 20),
          
          _buildPurpleButton('Add Contact', _addContact, _isAdding),
        ],
      ),
    );
  }
  
  // Helper Widget untuk TextField (Sama seperti sebelumnya)
  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    // ... (gunakan implementasi TextField sebelumnya)
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF6A1B9A))),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper Widget untuk Tombol Ungu Besar
  Widget _buildPurpleButton(String text, VoidCallback onPressed, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFF6A1B9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: isLoading 
          ? const SizedBox(
              width: 24, height: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}