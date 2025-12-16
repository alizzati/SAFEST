import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:safest/widgets/add_contact/add_contact_method_dialog.dart';
import 'package:safest/widgets/add_contact/add_contact_form_dialog.dart';
import 'package:safest/widgets/profile/contact_detail_dialog.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/widgets/profile/contact_card.dart';

class ProfileScreen extends StatefulWidget {
  final String? targetUserId;
  const ProfileScreen({super.key, this.targetUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ContactService _contactService = ContactService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  // Data User
  String _userId = '';
  String _userName = 'Loading...';
  String _userEmail = '';
  String? _avatarUrl;

  static const Color _primaryPurple = Color(0xFF512DA8);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadContacts();
  }

  // --- 1. LOAD USER DATA ---
  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    String uidToCheck = widget.targetUserId ?? currentUser?.uid ?? '';

    if (uidToCheck.isEmpty) {
      setState(() {
        _userId = 'No User';
        _userName = 'Guest';
      });
      return;
    }

    setState(() => _userId = uidToCheck);

    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uidToCheck).get();
      
      if (userDoc.exists && mounted) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['name'] ?? 'No Name';
          _userEmail = data['email'] ?? currentUser?.email ?? '';
          _avatarUrl = data['avatarUrl'];
        });
      } else if (mounted) {
        setState(() {
          _userName = currentUser?.displayName ?? 'User';
          _userEmail = currentUser?.email ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  // --- 2. LOAD CONTACTS ---
  Future<void> _loadContacts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC DIALOGS ---
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

      if (isSuccess == true) {
        _loadContacts();
      }
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

  void _navigateToPersonalInfo() {
    context.push('/personal-info');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Header background color
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left, size: 30, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 28, color: Colors.black),
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Bagian Header (Foto & Nama) - Tetap di atas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildUserProfileHeader(),
            ),
          ),
          
          // Bagian Body (Ungu) - Mengisi sisa layar
          SliverFillRemaining(
            hasScrollBody: false, // Penting agar konten di dalamnya tidak scroll sendiri
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 15),

                    // LIST CONTACT
                    _isLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white)))
                        : _buildEmergencyContactList(),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _navigateToPersonalInfo,
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        )
                      ],
                    ),
                    
                    _buildPersonalInformationBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryPurple, width: 3),
                image: DecorationImage(
                  image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? NetworkImage(_avatarUrl!) as ImageProvider
                      : const AssetImage('assets/images/ceww.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _navigateToPersonalInfo,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 20, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _userName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        _buildUserIdWidget(),
      ],
    );
  }

  Widget _buildUserIdWidget() {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: _userId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID Copied!'), duration: Duration(seconds: 1)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _userId.length > 8 ? '${_userId.substring(0, 8)}...' : _userId,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.copy, size: 16, color: _primaryPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactList() {
    return SizedBox(
      height: 135, // Tinggi disesuaikan agar tidak terpotong
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _contacts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return AddContactCard(onTap: _showAddContactDialog);
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () => _showContactDetailDialog(_contacts[index - 1]),
              child: ContactCard(contact: _contacts[index - 1]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInformationBox() {
    // Pastikan data ini nanti diambil dari Firestore (User Service)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align top
            children: [
              Expanded(child: _buildInfoField('First Name', 'Clara')),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Last Name', 'Adelia')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoField('Phone Number', '628123456789010')),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Post Code', '12345')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoField('City', 'Gotham City')),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Country', 'Konoha Bahlilan')),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoField('Email', _userEmail.isNotEmpty ? _userEmail : 'clara1234@gmail.com'),
          const SizedBox(height: 15),
          _buildInfoField('Street Address', 'Jalan Mulu Jadian Kaga, Haram Akhi, Gotham City Karang ancur, Titanic, Konoha Bahlilan. 12345'),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Fix Justify Buruk
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3),
        ),
      ],
    );
  }
}