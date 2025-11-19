import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/widgets/add_contact/add_contact_method_dialog.dart';
import 'package:safest/widgets/profile/contact_detail_dialog.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/widgets/profile/contact_card.dart';
import 'package:flutter/services.dart';  

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ContactService _contactService = ContactService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contactData = await _contactService.fetchContacts();
    _contacts = contactData.map((data) => EmergencyContact(
      name: data['name']!,
      relationship: data['relationship']!,
      avatarUrl: data['avatarUrl']!,
      phoneNumber: data['phone_number'],
    )).toList();
    setState(() => _isLoading = false);
  }

  // Fungsi untuk menampilkan Pop Up 1 (Pilih Metode)
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddContactMethodDialog();
      },
    ).then((added) {
      if (added == true) {
        _loadContacts();
      }
    });
  }

  // .then() untuk menangani refresh setelah delete
  void _showContactDetailDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContactDetailDialog(contact: contact);
      },
    ).then((deleted) {
      // Jika dialog ditutup dan mengembalikan 'true' (artinya dihapus)
      if (deleted == true) {
        _loadContacts(); // Refresh daftar kontak
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4A148C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- Sliver AppBar (Layer Foto Profil) ---
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 250.0, // Tinggi saat expanded
            pinned: false, // Tidak dipin, hanya menghilang saat di-scroll
            automaticallyImplyLeading: false,
            leading: IconButton(
                icon: const Icon(Icons.keyboard_arrow_left_rounded, size: 30, color: Colors.black),
                onPressed: () => context.pop(), // Aksi tombol kembali
            ),
            actions: [
                IconButton(
                    icon: const Icon(Icons.home_outlined, size: 24, color: Colors.black),
                    onPressed: () => context.go('/home'), // Aksi tombol home
                ),
                const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.zero,
              collapseMode: CollapseMode.pin,
              background: _buildUserProfileHeader(context), // Header Avatar + Nama
            ),
          ),

          // --- Sliver List (Layer Konten Ungu) ---
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: primaryPurple, 
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Emergency Contact
                    const Text('Emergency Contact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : _buildEmergencyContactList(), // List kontak
                    
                    const SizedBox(height: 20),

                    // Judul Personal Information
                    const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),

                    _buildPersonalInformationBox(), // Box putih info
                    const SizedBox(height: 50), // Buffer space
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 100, bottom: 20), // Padding agar tidak tertutup AppBar
      alignment: Alignment.center,
      child: Column(
        children: [
          _buildUserAvatar(),
          const SizedBox(height: 10),
          const Text(
            'Emma Watson',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 4),
          _buildUserId(context),
        ],
      ),
    );
  }

  Widget _buildUserId(BuildContext context) {
    const String userId = 'A1B2C3D40';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(userId, style: TextStyle(fontSize: 16, color: Colors.grey)),
        
        IconButton(
          icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
          onPressed: () {
            // Aksi untuk menyalin
            Clipboard.setData(const ClipboardData(text: userId));
            
            // Tampilkan notifikasi (SnackBar)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User ID copied to clipboard'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating, // Agar snackbar mengambang
              ),
            );
          },
          // Mengurangi padding default IconButton agar lebih rapat
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          splashRadius: 16,
        ),

        IconButton(
          icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
          onPressed: () {
            // Aksi edit
          },
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          splashRadius: 16,
        ),
      ],
    );
  }
  
  Widget _buildUserAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // Border putih dihilangkan sesuai desain baru
        // border: Border.all(color: Colors.white, width: 3),
        image: DecorationImage(
          image: AssetImage('assets/avatar_pink.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }


  // Widget ini HANYA me-render list horizontal
  Widget _buildEmergencyContactList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0), // Dihapus paddingnya
        itemCount: _contacts.length + 1,
        itemBuilder: (context, index) {
          if (index < _contacts.length) {
            return GestureDetector(
              onTap: () => _showContactDetailDialog(_contacts[index]),
              child: ContactCard(contact: _contacts[index]),
            );
          } else {
            return AddContactCard(onTap: _showAddContactDialog);
          }
        },
      ),
    );
  }

  // Widget ini HANYA me-render box putih
  Widget _buildPersonalInformationBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow sedikit lebih jelas
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      // Konten Informasi Pribadi
    );
  }
}