import 'package:flutter/material.dart';
// Hapus import user_model jika tidak dipakai langsung, karena data dipassing via parameter simple
// atau sesuaikan dengan model User Anda. Disini saya buat general.

class ProfileHeader extends StatelessWidget {
  final String name;
  final String userId;
  final String avatarUrl;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key, 
    required this.name, 
    required this.userId, 
    required this.avatarUrl,
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF512DA8), width: 3),
                  image: DecorationImage(
                    image: avatarUrl.startsWith('http') 
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : AssetImage(avatarUrl.isEmpty ? 'assets/images/avatar_pink.png' : avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                        )
                      ]
                    ),
                    child: const Icon(Icons.edit, size: 18, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name, 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.grey[100],
               borderRadius: BorderRadius.circular(12)
             ),
             child: Text(
               userId, 
               style: const TextStyle(color: Color(0xFF512DA8), fontWeight: FontWeight.w500),
             ),
          ),
        ],
      ),
    );
  }
}