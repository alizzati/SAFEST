import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../utils/validators.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Dropdown value
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetController.dispose();
    _postCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    print('First Name: ${_firstNameController.text}');
    print('Last Name: ${_lastNameController.text}');
    print('Gender: $_selectedGender');
    print('Street: ${_streetController.text}');
    print('Post Code: ${_postCodeController.text}');
    print('City: ${_cityController.text}');
    print('Country: ${_countryController.text}');
    print('Phone: ${_phoneController.text}');
    print('Email: ${_emailController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Personal information saved successfully!'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
              ? screenHeight * 0.05
              : screenHeight * 0.02;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                          SizedBox(height: screenHeight * 0.02),

                          // ==================== HEADER ====================
                          Text(
                            'Personal\nInformation',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen ? 36 : screenWidth * 0.09,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF512DA8),
                              height: 1.2,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Text(
                            'Please provide your personal details below to help us create your profile. All fields are required.',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen ? 14 : screenWidth * 0.032,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7E7E7E),
                              height: 1.6,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Text(
                            'Your Personal Details',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen ? 16 : screenWidth * 0.042,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF512DA8),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // First Name & Last Name
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _firstNameController,
                                  labelText: 'First Name',
                                  validator: (v) => Validators.validateRequired(v, fieldName: 'First name'),
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: CustomTextField(
                                  controller: _lastNameController,
                                  labelText: 'Last Name',
                                  validator: (v) => Validators.validateRequired(v, fieldName: 'Last name'),
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Gender Dropdown
                          CustomDropdown(
                            value: _selectedGender,
                            labelText: 'Gender',
                            items: _genderOptions,
                            onChanged: (newValue) => setState(() => _selectedGender = newValue),
                            validator: (value) => Validators.validateRequired(value, fieldName: 'Gender'),
                            isLargeScreen: isLargeScreen,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Text(
                            'Your Residential Address',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen ? 16 : screenWidth * 0.042,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF512DA8),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Street
                          CustomTextField(
                            controller: _streetController,
                            labelText: 'Street Address',
                            validator: (v) => Validators.validateRequired(v, fieldName: 'Street address'),
                            isLargeScreen: isLargeScreen,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Post Code, City, Country
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: _postCodeController,
                                  labelText: 'Post Code',
                                  keyboardType: TextInputType.number,
                                  validator: Validators.validatePostalCode,
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Expanded(
                                flex: 3,
                                child: CustomTextField(
                                  controller: _cityController,
                                  labelText: 'City',
                                  validator: (v) => Validators.validateRequired(v, fieldName: 'City'),
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Expanded(
                                flex: 3,
                                child: CustomTextField(
                                  controller: _countryController,
                                  labelText: 'Country',
                                  validator: (v) => Validators.validateRequired(v, fieldName: 'Country'),
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Text(
                            'Contact Details',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen ? 16 : screenWidth * 0.042,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF512DA8),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Phone
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.2,
                                child: CustomTextField(
                                  labelText: '',
                                  initialValue: '+62',
                                  readOnly: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Expanded(
                                child: CustomTextField(
                                  controller: _phoneController,
                                  labelText: 'Phone Number',
                                  keyboardType: TextInputType.phone,
                                  validator: Validators.validatePhone,
                                  isLargeScreen: isLargeScreen,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          // Email
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email Address',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            isLargeScreen: isLargeScreen,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          GradientButton(
                            text: 'Save',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _handleSave();
                                Future.delayed(const Duration(milliseconds: 800), () {
                                  context.go(AppRoutes.emergencyContact);
                                });
                              }
                            },
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            fontSize: isLargeScreen ? 16 : 18,
                          ),


                          SizedBox(height: screenHeight * 0.03),
                        ],
                      ),
                    ),
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