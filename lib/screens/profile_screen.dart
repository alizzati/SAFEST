import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safest/config/routes.dart';
import 'package:safest/widgets/add_contact/add_contact_method_dialog.dart';
import 'package:safest/widgets/add_contact/add_contact_form_dialog.dart';
import 'package:safest/widgets/profile/contact_detail_dialog.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/services/user_service.dart';
import 'package:safest/widgets/profile/contact_card.dart';
import 'package:safest/widgets/profile_header.dart'; 
import 'package:safest/widgets/profile/personal_info_box.dart'; 

class ProfileScreen extends StatefulWidget {
  final String? targetUserId;
  const ProfileScreen({super.key, this.targetUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ContactService _contactService = ContactService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<EmergencyContact> _contacts = [];
  bool _isLoadingContacts = true;
  bool _isLoadingUser = true;
  bool _isUploadingImage = false;

  String _userId = '';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _email = '';
  String _city = '';
  String _country = '';
  String _address = '';
  String _postCode = '';
  String? _avatarUrl;

  static const Color _primaryPurple = Color(0xFF512DA8);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadContacts();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoadingUser = true);

    User? currentUser = _auth.currentUser;
    String uidToCheck = widget.targetUserId ?? currentUser?.uid ?? '';

    if (uidToCheck.isEmpty) {
      if (mounted) setState(() => _isLoadingUser = false);
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(uidToCheck).get();

      if (userDoc.exists && mounted) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;        
        Map<String, dynamic> details = data['details'] ?? data;

        setState(() {
          _firstName = details['firstName'] ?? '';
          _lastName = details['lastName'] ?? '';
          _phone = details['phoneNumber'] ?? '-';
          _email = data['email'] ?? currentUser?.email ?? '';
          _city = details['city'] ?? '-';
          _country = details['country'] ?? '-';
          _address = details['streetAddress'] ?? '-';
          _postCode = details['postCode'] ?? '-';
          _avatarUrl = data['avatarUrl'];

          String rawUid = uidToCheck;
          _userId = data['customId'] ?? rawUid.substring(0, 6).toUpperCase();
          
          _isLoadingUser = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingUser = false);
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _loadContacts() async {
    if (!mounted) return;
    try {
      final contactData = await _contactService.fetchContacts();
      if (mounted) {
        setState(() {
          _contacts = contactData.map((data) {
            return EmergencyContact(
              name: data['name'] ?? 'Unknown',
              relationship: data['relationship'] ?? '',
              avatarUrl: data['avatarUrl'] ?? 'assets/images/avatar_pink.png',
              phoneNumber: data['phone_number'],
              userId: data['user_id'],
            );
          }).toList();
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingContacts = false);
    }
  }
  Future<void> _navigateToPersonalInfo() async {
    final initialData = {
      'firstName': _firstName,
      'lastName': _lastName,
      'phoneNumber': _phone,
      'email': _email,
      'city': _city,
      'country': _country,
      'streetAddress': _address,
      'postCode': _postCode,
    };
    
    final result = await context.push(AppRoutes.personalInfo, extra: initialData);
    
    if (result == true && mounted) {
      _loadUserData();
    }
  }

  Future<void> _handleChangeProfilePicture() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change Profile Picture",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(Icons.camera_alt, "Camera", () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
                  _buildImageOption(Icons.photo_library, "Gallery", () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[100],
            child: Icon(icon, size: 30, color: _primaryPurple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 60, 
        maxWidth: 800,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _userService.uploadProfilePicture(
          currentUser.uid, 
          File(pickedFile.path)
        );
        
        await _loadUserData(); // Refresh UI
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update picture: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // DIALOGS
  Future<void> _showAddContactDialog() async {
    final AddContactMode? selectedMode = await showDialog<AddContactMode>(
      context: context,
      useRootNavigator: true,
      builder: (context) => const AddContactMethodDialog(),
    );

    if (selectedMode != null && mounted) {
      final bool? isSuccess = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        builder: (context) => AddContactFormDialog(mode: selectedMode),
      );
      if (isSuccess == true) _loadContacts();
    }
  }

  void _showContactDetailDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => ContactDetailDialog(contact: contact),
    ).then((deleted) {
      if (deleted == true) _loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String displayName = "$_firstName $_lastName".trim();
    if (displayName.isEmpty) displayName = "User";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              color: _primaryPurple, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: _primaryPurple))
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // --- HEADER ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ProfileHeader(
                          name: displayName,
                          userId: _userId,
                          avatarUrl: _avatarUrl ?? '',
                          onEdit: _handleChangeProfilePicture, 
                        ),
                      ),
                    ),

                    // --- BODY ---
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: _primaryPurple,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25, 30, 25, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emergency Contact',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 15),

                              _isLoadingContacts
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : SizedBox(
                                      height: 135,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: _contacts.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return AddContactCard(onTap: _showAddContactDialog);
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 15.0),
                                            child: GestureDetector(
                                              onTap: () => _showContactDetailDialog(_contacts[index - 1]),
                                              child: ContactCard(contact: _contacts[index - 1]),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                              const SizedBox(height: 25),

                              // HEADER PERSONAL INFO
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  // TOMBOL EDIT (ICON PENCIL)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: _navigateToPersonalInfo, // AKSI NAVIGASI
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Icon(Icons.edit,
                                            color: Colors.white, size: 22),
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              // PERSONAL INFO BOX
                              PersonalInformationBox(
                                firstName: _firstName,
                                lastName: _lastName,
                                phone: _phone,
                                email: _email,
                                city: _city,
                                country: _country,
                                address: _address,
                                postCode: _postCode,
                              ),

                              SizedBox(height: screenHeight * 0.03),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (context.mounted) {
                                      context.go(AppRoutes.signIn);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC62828),
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.02),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(screenWidth * 0.02)),
                                  ),
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // LOADING OVERLAY
                if (_isUploadingImage)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
              ],
            ),
    );
  }
}