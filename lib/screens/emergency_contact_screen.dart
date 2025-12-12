import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/gradient_button.dart';
import '../utils/validators.dart';
import '../config/routes.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  String? _selectedRelationship;
  final List<String> _relationshipOptions = [
    'Parent',
    'Sibling',
    'Spouse',
    'Friend',
    'Other',
  ];

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go(AppRoutes.signIn);
      return;
    }

    setState(() { _isLoading = true; });

    final Map<String, dynamic> emergencyContactsData = {
      'contact_1': {
        'name': _contactNameController.text.trim(),
        'phone': _contactPhoneController.text.trim(),
        'relationship': _selectedRelationship,
      },
    };

    try {
      // Update Firestore → simpan emergency contact & set profileComplete: true
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'emergencyContacts': emergencyContactsData,
        'profileComplete': true,  // pastikan ini TRUE
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Onboarding complete! Welcome to Safest.')),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // langsung ke home
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          final maxWidth = isLargeScreen ? 500.0 : constraints.maxWidth * 0.9;
          final verticalPadding = orientation == Orientation.portrait
              ? screenHeight * 0.10
              : screenHeight * 0.05;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                width: maxWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: verticalPadding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency\nContacts',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: isLargeScreen ? 34 : screenWidth * 0.085,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF512DA8),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Provide a contact we can reach in case of emergencies.',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: isLargeScreen ? 14 : screenWidth * 0.035,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7E7E7E),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Emergency Contact Name',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF512DA8),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        controller: _contactNameController,
                        labelText: "Enter contact’s full name",
                        validator: (value) =>
                            Validators.validateRequired(value, fieldName: 'Name'),
                        isLargeScreen: isLargeScreen,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Emergency Contact Phone Number',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF512DA8),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        controller: _contactPhoneController,
                        labelText: "Enter contact’s phone number",
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                        isLargeScreen: isLargeScreen,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Relationship with Contact',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF512DA8),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomDropdown(
                        value: _selectedRelationship,
                        labelText: 'Select relationship',
                        items: _relationshipOptions,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRelationship = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a relationship';
                          }
                          return null;
                        },
                        isLargeScreen: isLargeScreen,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      GradientButton(
                        text: 'Save',
                        onPressed: _isLoading ? null : _handleSave,
                        width: double.infinity,
                        height: screenHeight * 0.065,
                        fontSize: isLargeScreen ? 16 : 18,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Text(
                          'Need to add more contacts? You can do this anytime in your profile settings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: isLargeScreen ? 13 : screenWidth * 0.034,
                            color: const Color(0xFF7E7E7E),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}