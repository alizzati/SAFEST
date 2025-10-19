import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../models/user_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/contact_card.dart';
import '../widgets/info_box.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User user = User(
    id: "A1B2C3D40",
    name: "Emma Watson",
    avatarUrl: "assets/avatar.png",
    contacts: [
      Contact(name: "Cleopatra", relation: "Sister", avatarUrl: "assets/avatar.png"),
      Contact(name: "Sangkuriang", relation: "Father", avatarUrl: "assets/avatar.png"),
    ],
  );

  final userService = UserService();

  void _addContact() async {
    final newContact = Contact(name: "New Contact", relation: "Friend", avatarUrl: "assets/avatar.png");
    setState(() {
      user.contacts.add(newContact);
    });
    await userService.updateUser(user);
  }

  void _editProfile() async {
    setState(() {
      user.name = "Updated Name";
    });
    await userService.updateUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C0FFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(user: user, onEdit: _editProfile),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A0DFF), Color(0xFF3C0FFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Emergency Contact",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: user.contacts.length + 1,
                        itemBuilder: (context, index) {
                          if (index < user.contacts.length) {
                            return ContactCard(contact: user.contacts[index]);
                          } else {
                            return GestureDetector(
                              onTap: _addContact,
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 40),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Personal Information",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const InfoBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
