import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';

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
        // context.go(AppRoutes.liveVideo);
        break;
      case 3:
        context.go(AppRoutes.education);
        break;
      case 4:
        context.push(AppRoutes.emergency);
        break;
    }
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
