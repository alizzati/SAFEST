import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;

  const ProfileHeader({super.key, required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(radius: 50, backgroundImage: AssetImage(user.avatarUrl)),
          const SizedBox(height: 10),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(user.id, style: const TextStyle(color: Colors.blueAccent)),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.grey)),
        ],
      ),
    );
  }
}
