import 'package:flutter/material.dart';
import '../models/contact_model.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  
  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundImage: AssetImage(contact.avatarUrl)),
          const SizedBox(height: 6),
          Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
          Text(contact.relation, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
