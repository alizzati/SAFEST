import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String userId;
  final String? avatarUrl;
  final VoidCallback onEdit; 

  const ProfileHeader({
    super.key,
    required this.name,
    required this.userId,
    required this.avatarUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF512DA8);

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: 115, 
            height: 115,
            child: Stack(
              children: [

                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryPurple, width: 3),
                      image: DecorationImage(
                        image: (avatarUrl != null && avatarUrl!.isNotEmpty && avatarUrl!.startsWith('http'))
                            ? NetworkImage(avatarUrl!) as ImageProvider
                            : const AssetImage('assets/images/avatar_pink.png'), // Gunakan default yang benar
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      onTap: onEdit, 
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(8), 
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 5),
          
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: userId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID Copied to clipboard!'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
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
                    userId,
                    style: const TextStyle(
                        fontSize: 16,
                        color: primaryPurple,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}