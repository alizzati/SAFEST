import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:safest/widgets/add_contact/add_contact_method_dialog.dart';
import 'package:safest/widgets/add_contact/add_contact_form_dialog.dart';
import 'package:safest/widgets/profile/contact_detail_dialog.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/widgets/profile/contact_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ContactService _contactService = ContactService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  static const Color _primaryPurple = Color(0xFF512DA8);

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // --- LOGIC LOAD CONTACTS ---
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
      debugPrint('Error loading contacts: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC DIALOG ADD CONTACT ---
  Future<void> _showAddContactDialog() async {
    // Tampilkan Dialog Metode (Phone vs ID) dan mengembalikan Enum 'AddContactMode' atau null jika dicancel
    final AddContactMode? selectedMode = await showDialog<AddContactMode>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return const AddContactMethodDialog();
      },
    );

    // buka Form Dialog Mode Dipilih
    if (selectedMode != null && mounted) {
      final bool? isSuccess = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return AddContactFormDialog(mode: selectedMode);
        },
      );

      if (isSuccess == true) {
        _loadContacts();
      }
    }
  }

  // --- LOGIC MENAMPILKAN DETAIL ---
  void _showContactDetailDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ContactDetailDialog(contact: contact);
      },
    ).then((deleted) {
      // Refresh jika kontak dihapus
      if (deleted == true) {
        _loadContacts();
      }
    });
  }

  void _navigateToPersonalInfo() {
    context.push('/personal-info');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: _primaryPurple,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 30,
            color: Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              size: 28,
              color: Colors.black,
            ),
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildUserProfileHeader()),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // LIST CONTACT
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : _buildEmergencyContactList(),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _navigateToPersonalInfo,
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryPurple, width: 3),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/ceww.png'),
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Emma Watson',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          _buildUserId(),
        ],
      ),
    );
  }

  Widget _buildUserId() {
    const String userId = 'A1B2C3D40';
    return GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: userId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID Copied!'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            userId,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.copy, size: 16, color: _primaryPurple),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _contacts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return AddContactCard(onTap: _showAddContactDialog);
          }
          // index 0 dipakai buat Add Button di atas
          if (index < _contacts.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                onTap: () => _showContactDetailDialog(_contacts[index]),
                child: ContactCard(contact: _contacts[index]),
              ),
            );
          } else {
            return AddContactCard(onTap: _showAddContactDialog);
          }
        },
      ),
    );
  }

  Widget _buildPersonalInformationBox() {
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
            children: [
              Expanded(child: _buildInfoField('First Name', 'Clara')),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Last Name', 'Adelia')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInfoField('Phone Number', '628123456789010'),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Post Code', '12345')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildInfoField('City', 'Gotham City')),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Country', 'Konoha Bahlilan')),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoField('Email', 'clara1234@gmail.com'),
          _buildInfoField(
            'Street Address',
            'Jalan Mulu Jadian Kaga, Haram Akhi, Gotham City Karang ancur, Titanic, Konoha Bahlilan. 12345',
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
