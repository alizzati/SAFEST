import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomBottomNavBar extends StatelessWidget {
  CustomBottomNavBar({super.key});

  final Color primaryColor = const Color(0xFF512DAB);
  final Color inactiveIconColor = const Color(0xFF512DAB);
  final Color activeIconColor = Colors.white;
  final Color activeTextColor = const Color(0xFF512DAB);

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.setFake);
        break;
      case 2:
        _showLiveVideoConfirmation(context);
        break;
      case 3:
        context.go(AppRoutes.education);
        break;
      case 4:
        context.push(AppRoutes.emergency);
        break;
    }
  }

  void _showLiveVideoConfirmation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Color purpleColor = const Color(0xFF512DAB);
    final Color redColor = const Color(0xFFC62828);
    final Color greenColor = const Color(0xFF4CAF50);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          contentPadding: EdgeInsets.all(screenWidth * 0.06),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Live Video
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: purpleColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam,
                  size: screenWidth * 0.15,
                  color: purpleColor,
                ),
              ),

              SizedBox(height: screenWidth * 0.05),

              // Judul
              Text(
                'Start Live Emergency Video?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: purpleColor,
                ),
              ),

              SizedBox(height: screenWidth * 0.03),

              // Deskripsi
              Text(
                'This will broadcast your live video and location to your emergency contacts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[700],
                ),
              ),

              SizedBox(height: screenWidth * 0.06),

              // Tombol
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Cancel
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.035,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.02,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.03),

                      // Tombol Yes, Start
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();

                            // Update isLive menjadi true
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({'isLive': true});
                            }

                            context.go(AppRoutes.liveVideo);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.035,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.02,
                              ),
                            ),
                          ),
                          child: Text(
                            'Yes, Start',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Jarak vertikal
                  // Tombol Watch Other full width
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        try {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser == null) return;

                          final doc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get();

                          final data = doc.data();
                          if (data == null) return;

                          final emergencyContacts =
                              data['emergencyContacts'] as List<dynamic>?;

                          if (emergencyContacts == null ||
                              emergencyContacts.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Info"),
                                content: const Text(
                                  "Tidak ada emergency contact.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          Map<String, dynamic>? liveContactData;

                          // Loop emergency contact (LIST)
                          for (final contact in emergencyContacts) {
                            final contactMap = contact as Map<String, dynamic>;
                            final contactId =
                                contactMap['user_id']; // 🔑 customId

                            if (contactId != null) {
                              final query = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('customId', isEqualTo: contactId)
                                  .limit(1)
                                  .get();

                              if (query.docs.isNotEmpty) {
                                final userData = query.docs.first.data();

                                if (userData['isLive'] == true) {
                                  liveContactData = userData;
                                  break; // stop kalau sudah ketemu yang live
                                }
                              }
                            }
                          }

                          if (liveContactData != null) {
                            // Arahkan ke watchingLiveVideoScreen dengan data
                            context.go(
                              AppRoutes.watchLiveVideo,
                              extra: liveContactData,
                            );
                          } else {
                            // Tidak ada yang live
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Info"),
                                content: const Text(
                                  "Tidak ada yang sedang live.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint(
                            "❌ Error checking live emergency contacts by phone: $e",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleColor,
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.04,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                        ),
                      ),
                      child: Text(
                        'Watch Other',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.setFake)) return 1;
    if (location.startsWith('/liveVideo')) return 2;
    if (location.startsWith('/education')) return 3;
    if (location.startsWith(AppRoutes.emergency)) return 4; // SOS
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isSOSSelected = currentIndex == 4;

    return Container(
      margin: EdgeInsets.only(
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
        bottom: screenHeight * 0.02,
      ),
      height: screenHeight * 0.14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.09,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildNavItem('Home', screenWidth, screenHeight),
                  _buildNavItem('Fake Call', screenWidth, screenHeight),
                  const Expanded(child: SizedBox()),
                  _buildNavItem('Live Video', screenWidth, screenHeight),
                  _buildNavItem('Education', screenWidth, screenHeight),
                ],
              ),
            ),
          ),

          // Floating icons
          Positioned(
            bottom: screenHeight * 0.008,
            left: screenWidth * 0.03,
            right: screenWidth * 0.03,
            child: Row(
              children: [
                _buildFloatingNavItem(
                  context,
                  0,
                  Icons.home_outlined,
                  'Home',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),
                _buildFloatingNavItem(
                  context,
                  1,
                  Icons.phone_outlined,
                  'Fake Call',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),
                const Expanded(child: SizedBox()),
                _buildFloatingNavItem(
                  context,
                  2,
                  Icons.videocam_outlined,
                  'Live Video',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),
                _buildFloatingNavItem(
                  context,
                  3,
                  Icons.school_outlined,
                  'Education',
                  currentIndex,
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
          ),

          // Tombol SOS
          Positioned(
            left: 0,
            right: 0,
            bottom: screenHeight * 0.03,
            child: Center(
              child: GestureDetector(
                onTap: () => _navigate(context, 4),
                child: Container(
                  width: screenWidth * 0.22,
                  height: screenWidth * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: isSOSSelected
                        ? Border.all(color: Colors.redAccent, width: 4)
                        : null,
                    boxShadow: isSOSSelected
                        ? [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, double screenWidth, double screenHeight) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: screenHeight * 0.012),
          Text(
            label,
            style: TextStyle(
              color: Colors.transparent,
              fontSize: screenWidth * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    int currentIndex,
    double screenWidth,
    double screenHeight,
  ) {
    final bool isSelected = currentIndex == index;
    final double iconSize = screenWidth * 0.08;
    final double circleSize = screenWidth * 0.12;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigate(context, index),
        child: Container(
          height: screenHeight * 0.1,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: screenHeight * 0.005,
                child: Text(
                  label,
                  style: TextStyle(
                    color: activeTextColor,
                    fontSize: screenWidth * 0.03,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              Positioned(
                bottom: isSelected
                    ? screenHeight * 0.035
                    : screenHeight * 0.015,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? activeIconColor : inactiveIconColor,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
