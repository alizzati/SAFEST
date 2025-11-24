import 'package:flutter/material.dart';
import 'package:safest/widgets/education/hero_card.dart';
import 'package:safest/widgets/education/module_card.dart';
import 'package:safest/models/education_module.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const primaryPurple = Color(0xFF6A1B9A);

    // Data untuk modul-modul
    final List<EducationModule> modules = [
      EducationModule(
        title: 'Personal Safety\nBasics',
        icon: Icons.shield_outlined,
        color: const Color(0xFF9C27B0),
        description: 'Learn essential tips to protect yourself in various situations',
      ),
      EducationModule(
        title: 'Mastering Safety\nTools and Apps',
        icon: Icons.phone_android_outlined,
        color: const Color(0xFF673AB7),
        description: 'Discover how to use safety apps and emergency features',
      ),
      EducationModule(
        title: 'Staying Safe\nin Public',
        icon: Icons.people_outline,
        color: const Color(0xFF512DA8),
        description: 'Navigate public spaces with confidence and awareness',
      ),
      EducationModule(
        title: 'Online Safety\nGuidelines',
        icon: Icons.language_outlined,
        color: const Color(0xFF4A148C),
        description: 'Protect yourself from digital threats and scams',
      ),
      EducationModule(
        title: 'Emergency\nPreparedness',
        icon: Icons.emergency_outlined,
        color: const Color(0xFF6A1B9A),
        description: 'Be ready for any emergency situation with proper planning',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.06, // Ditambah dari 0.02 ke 0.06
              bottom: screenHeight * 0.15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Stay Safe, Stay\nInformed',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                Text(
                  'Empowering you with knowledge and tools for a safer world.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Hero Card - Report and Prevent (Widget Reusable)
                HeroCard(
                  onLearnMorePressed: () {
                    // TODO: Navigate to learn more page
                  },
                ),

                SizedBox(height: screenHeight * 0.03),

                // Safety Education Modules Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Safety Education Modules',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: primaryPurple,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: screenWidth * 0.04,
                      color: primaryPurple,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                // Horizontal Scrollable Module Cards (Widget Reusable)
                SizedBox(
                  height: screenHeight * 0.24,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      return ModuleCard(
                        module: modules[index],
                        onTap: () {
                          // TODO: Navigate to module detail
                        },
                      );
                    },
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}