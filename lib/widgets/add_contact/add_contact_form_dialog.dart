import 'package:flutter/material.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/services/user_service.dart';
import 'package:safest/widgets/custom_text_field.dart';
import 'package:safest/widgets/custom_dropdown.dart';
import 'package:safest/widgets/gradient_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContactFormDialog extends StatefulWidget {
  final AddContactMode mode;

  const AddContactFormDialog({super.key, required this.mode});

  @override
  State<AddContactFormDialog> createState() => _AddContactFormDialogState();
}

class _AddContactFormDialogState extends State<AddContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ContactService _contactService = ContactService();
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneOrIdController = TextEditingController();

  bool _isLoading = false;
  String? _selectedRelationship;

  bool _isCheckingId = false;
  bool _isIdValid = false;
  String? _idErrorMessage;
  String? _foundUserName;

  final List<String> _relationshipOptions = [
    'Parent', 'Sibling', 'Spouse', 'Friend', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _phoneOrIdController.addListener(() {
      if (widget.mode == AddContactMode.id && _isIdValid) {
        setState(() {
          _isIdValid = false;
          _foundUserName = null;
          _idErrorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneOrIdController.dispose();
    super.dispose();
  }

  Future<void> _checkUserId() async {
    final targetId = _phoneOrIdController.text.trim();
    if (targetId.isEmpty) return;

    setState(() {
      _isCheckingId = true;
      _idErrorMessage = null;
      _isIdValid = false;
      _foundUserName = null;
    });

    try {
      final userData = await _userService.findUserByCustomId(targetId);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (userData != null) {
        if (currentUser != null && userData['uid'] == currentUser.uid) {
           setState(() {
            _isIdValid = false;
            _idErrorMessage = "You cannot add yourself as a contact.";
          });
        } else {
          setState(() {
            _isIdValid = true;
            String fullName = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
            if (fullName.isEmpty) fullName = userData['displayName'] ?? 'Unknown User';
            _foundUserName = fullName;
          });
        }
      } else {
        setState(() {
          _isIdValid = false;
          _idErrorMessage = "User ID not found";
        });
      }
    } catch (e) {
      setState(() => _idErrorMessage = "Error checking ID");
    } finally {
      setState(() => _isCheckingId = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.mode == AddContactMode.id && !_isIdValid) {
      setState(() => _idErrorMessage = "Please enter a valid User ID");
      return;
    }

    setState(() => _isLoading = true);

    bool success = false;

    if (widget.mode == AddContactMode.phone) {
      // MODE PHONE
      success = await _contactService.addContact(
        mode: widget.mode,
        name: _nameController.text.trim(),
        phone: _phoneOrIdController.text.trim(),
        relationship: _selectedRelationship!,
        id: null,
      );
    } else {
      // MODE ID
      success = await _contactService.addContact(
        mode: widget.mode,
        name: _foundUserName ?? 'Unknown',
        phone: null,
        id: _phoneOrIdController.text.trim(),
        relationship: _selectedRelationship!,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact added successfully!")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add contact.")),
      );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mode == AddContactMode.phone
                    ? 'Add Contact by Phone'
                    : 'Add Contact by ID',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF512DA8),
                ),
              ),
              const SizedBox(height: 20),

              if (widget.mode == AddContactMode.phone) ...[
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Contact Name',
                  isLargeScreen: isLargeScreen,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _phoneOrIdController,
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isLargeScreen: isLargeScreen,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneOrIdController,
                        labelText: 'User ID',
                        isLargeScreen: isLargeScreen,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        validator: (v) => v!.isEmpty ? 'ID is required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isCheckingId ? null : _checkUserId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF512DA8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isCheckingId
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
                
                if (_idErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Text(
                      _idErrorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                if (_isIdValid && _foundUserName != null)
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("User Found:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                _foundUserName!,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 15),

              if (widget.mode == AddContactMode.phone || (widget.mode == AddContactMode.id && _isIdValid))
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
                      text: _isLoading ? 'Saving...' : 'Add',
                      onPressed: (_isLoading || (widget.mode == AddContactMode.id && !_isIdValid)) 
                          ? null 
                          : _handleSave,
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
    );
  }
}