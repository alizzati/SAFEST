import 'package:flutter/material.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/services/user_service.dart';
import 'package:safest/widgets/custom_text_field.dart';
import 'package:safest/widgets/custom_dropdown.dart';
import 'package:safest/widgets/gradient_button.dart';

class EditContactDialog extends StatefulWidget {
  final EmergencyContact contact;

  const EditContactDialog({super.key, required this.contact});

  @override
  State<EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<EditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final ContactService _contactService = ContactService();
  final UserService _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _idController;

  bool _isLoading = false;
  String? _selectedRelationship;
  String? _errorMessage;

  final List<String> _relationshipOptions = [
    'Parent', 'Sibling', 'Spouse', 'Friend', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    // 1. PRE-FILL DATA (Isi data awal)
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneController = TextEditingController(text: widget.contact.phoneNumber ?? '');
    _idController = TextEditingController(text: widget.contact.userId ?? '');
    
    // Pastikan value dropdown valid (ada di list option)
    if (_relationshipOptions.contains(widget.contact.relationship)) {
      _selectedRelationship = widget.contact.relationship;
    } else {
      _selectedRelationship = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final nameInput = _nameController.text.trim();
    final phoneInput = _phoneController.text.trim();
    final idInput = _idController.text.trim();

    // VALIDASI: Salah satu (ID atau Phone) harus diisi
    if (phoneInput.isEmpty && idInput.isEmpty) {
      setState(() => _errorMessage = "Either Phone Number or ID must be filled");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String finalName = nameInput;
    String finalPhone = phoneInput;
    String? finalId = idInput.isEmpty ? null : idInput;
    String finalAvatar = widget.contact.avatarUrl;

    try {
      // SKENARIO 1: User Menginput ID
      if (finalId != null) {
        // Cek apakah ID valid
        final userData = await _userService.findUserByCustomId(finalId);
        if (userData == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = "User ID not found";
          });
          return;
        }
        // Jika valid, update data dari User tersebut
        finalName = userData['name'] ?? userData['displayName'] ?? "${userData['firstName']} ${userData['lastName']}";
        finalAvatar = userData['avatarUrl'] ?? 'assets/images/avatar_pink.png';
        // Phone opsional, bisa diambil dari user atau inputan manual
      } 
      
      // SKENARIO 2: User HANYA input Phone (ID Kosong) -> Cek Auto-Fill ID
      else if (finalId == null && finalPhone.isNotEmpty) {
        // Cek apakah nomor HP terdaftar
        final userDataByPhone = await _userService.findUserByPhone(finalPhone);
        
        if (userDataByPhone != null) {
          // USER TERDAFTAR! Auto-fill ID & Update Info
          finalId = userDataByPhone['customId']; // Ambil ID
          finalName = userDataByPhone['name'] ?? userDataByPhone['displayName'] ?? "${userDataByPhone['firstName']} ${userDataByPhone['lastName']}";
          finalAvatar = userDataByPhone['avatarUrl'] ?? 'assets/images/avatar_pink.png';
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User found! ID auto-filled: $finalId")),
            );
          }
        } 
        // Jika tidak terdaftar, biarkan sebagai kontak manual (Non-user)
      }

      // PROSES EDIT DI DATABASE
      bool success = await _contactService.editContact(
        oldContact: widget.contact,
        newContactData: {
          'name': finalName,
          'phone_number': finalPhone,
          'user_id': finalId,
          'relationship': _selectedRelationship,
          'avatarUrl': finalAvatar,
        },
      );

      if (success && mounted) {
        Navigator.pop(context, true); // Tutup dialog & kirim sinyal sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact updated successfully!")),
        );
      } else if (mounted) {
        setState(() => _errorMessage = "Failed to update contact");
      }

    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: isLargeScreen ? 500 : screenWidth * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Contact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF512DA8),
                  ),
                ),
                const SizedBox(height: 20),

                // Nama
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  isLargeScreen: isLargeScreen,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 15),

                // Phone Number
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isLargeScreen: isLargeScreen,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                const SizedBox(height: 15),

                // ID (Bisa diedit jika kosong)
                CustomTextField(
                  controller: _idController,
                  labelText: 'User ID (Optional)',
                  isLargeScreen: isLargeScreen,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  // Jika ID sudah ada, mungkin Anda ingin me-disable edit?
                  // Sesuai request "jika tidak ada ID, kosongkan agar bisa edit", 
                  // berarti field ini selalu enabled.
                ),
                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 15),

                // Relationship
                CustomDropdown(
                  value: _selectedRelationship,
                  labelText: 'Relationship',
                  items: _relationshipOptions,
                  onChanged: (val) => setState(() => _selectedRelationship = val),
                  isLargeScreen: isLargeScreen,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  validator: (v) => v == null ? 'Please select relationship' : null,
                ),

                const SizedBox(height: 25),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(
                        text: _isLoading ? 'Saving...' : 'Save',
                        onPressed: _isLoading ? null : _handleSave,
                        height: 45,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}