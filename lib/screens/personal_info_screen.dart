import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../utils/validators.dart';

class PersonalInfoScreen extends StatefulWidget {
  // Menerima data awal jika diakses dari menu Edit Profile
  final Map<String, dynamic>? initialData;

  const PersonalInfoScreen({super.key, this.initialData});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _populateInitialData();
  }

  // Fungsi untuk mengisi form jika ada data awal (Mode Edit)
  void _populateInitialData() {
    final user = FirebaseAuth.instance.currentUser;
    final data = widget.initialData ?? {};

    // Prioritas: Data dari parameter > Data dari Auth (untuk email) > Kosong
    _firstNameController.text = data['firstName'] ?? '';
    _lastNameController.text = data['lastName'] ?? '';
    _phoneController.text = data['phoneNumber'] ?? '';
    _streetController.text = data['streetAddress'] ?? '';
    _cityController.text = data['city'] ?? '';
    _countryController.text = data['country'] ?? '';
    _postCodeController.text = data['postCode'] ?? '';
    
    // Email biasanya tidak diedit, ambil dari Auth jika data kosong
    _emailController.text = data['email'] ?? user?.email ?? '';
    
    // Gender (opsional jika ada di data)
    if (data.containsKey('gender')) {
      _selectedGender = data['gender'];
    }
  }

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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not authenticated!'), backgroundColor: Colors.red),
        );
        context.go(AppRoutes.signIn);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simpan dengan struktur FLAT (datar) agar mudah dibaca di ProfileScreen
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}', // Full Name backup
        'gender': _selectedGender,
        'phoneNumber': _phoneController.text.trim(),
        'streetAddress': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'postCode': _postCodeController.text.trim(),
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge agar tidak menimpa data kontak/lainnya

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // LOGIKA NAVIGASI:
        // Jika initialData ada, berarti sedang Edit Mode (dari Profile) -> POP
        // Jika initialData kosong, berarti sedang Onboarding -> GO NEXT
        if (widget.initialData != null && widget.initialData!.isNotEmpty) {
          context.pop(true); // Kembali ke Profile dengan sinyal sukses
        } else {
          context.go(AppRoutes.emergencyContact); // Lanjut ke step berikutnya
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    return AppScaffold(
      // Tambahkan App Bar jika dalam Mode Edit agar user bisa kembali manual
      appBar: widget.initialData != null 
        ? AppBar(
            title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ) 
        : null, // Tidak ada AppBar saat Onboarding (sesuai desain awal)
        
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
                          if (widget.initialData == null) ...[
                             SizedBox(height: screenHeight * 0.02),
                             // Header hanya muncul saat Onboarding
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
                          ],

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
                            readOnly: true,
                            fillColor: const Color(0xFFF5F5F5),
                            isLargeScreen: isLargeScreen,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          GradientButton(
                            text: _isLoading ? 'Saving...' : 'Save',
                            onPressed: _isLoading ? null : _handleSave,
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