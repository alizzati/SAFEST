import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:safest/widgets/add_contact/add_contact_method_dialog.dart';
import 'package:safest/widgets/profile/contact_detail_dialog.dart';
import 'package:safest/models/emergency_contact.dart';
import 'package:safest/services/contact_service.dart';
import 'package:safest/widgets/profile/contact_card.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ContactService _contactService = ContactService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  // Personal Information Data
  String _firstName = 'Emma';
  String _lastName = 'Watson';
  String _phoneNumber = '628123456789010';
  String _email = 'emma@gmail.com';
  String _city = 'Gotham City';
  String _country = 'Konoha Bahlilan';
  String _streetAddress =
      'Jalan Mulu jadian Kaga, Haram Akhi, Gotham City Karang ancur, Titanic, Konoha Bahlilan. 12345';
  String _postCode = '12345';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contactData = await _contactService.fetchContacts();
    _contacts = contactData
        .map(
          (data) => EmergencyContact(
        name: data['name']!,
        relationship: data['relationship']!,
        avatarUrl: data['avatarUrl']!,
        phoneNumber: data['phone_number'],
      ),
    )
        .toList();
    setState(() => _isLoading = false);
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddContactMethodDialog();
      },
    ).then((added) {
      if (added == true) {
        _loadContacts();
      }
    });
  }

  void _showContactDetailDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContactDetailDialog(contact: contact);
      },
    ).then((deleted) {
      if (deleted == true) {
        _loadContacts();
      }
    });
  }

  void _showEditPersonalInfoDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Controllers untuk form
    final firstNameController = TextEditingController(text: _firstName);
    final lastNameController = TextEditingController(text: _lastName);
    final phoneController = TextEditingController(text: _phoneNumber);
    final emailController = TextEditingController(text: _email);
    final cityController = TextEditingController(text: _city);
    final countryController = TextEditingController(text: _country);
    final streetController = TextEditingController(text: _streetAddress);
    final postCodeController = TextEditingController(text: _postCode);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
              maxWidth: screenWidth * 0.9,
            ),
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Edit Personal Information',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A148C),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Scrollable Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Form Fields
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'First Name',
                                firstNameController,
                                screenWidth,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: _buildTextField(
                                'Last Name',
                                lastNameController,
                                screenWidth,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildTextField(
                          'Phone Number',
                          phoneController,
                          screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildTextField('Email', emailController, screenWidth),
                        SizedBox(height: screenHeight * 0.015),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'City',
                                cityController,
                                screenWidth,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: _buildTextField(
                                'Country',
                                countryController,
                                screenWidth,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildTextField(
                          'Street Address',
                          streetController,
                          screenWidth,
                          maxLines: 2,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildTextField(
                          'Post Code',
                          postCodeController,
                          screenWidth,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.018,
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
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _firstName = firstNameController.text;
                            _lastName = lastNameController.text;
                            _phoneNumber = phoneController.text;
                            _email = emailController.text;
                            _city = cityController.text;
                            _country = countryController.text;
                            _streetAddress = streetController.text;
                            _postCode = postCodeController.text;
                          });
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Personal information updated'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A148C),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.02,
                            ),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      double screenWidth, {
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: screenWidth * 0.035),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.03,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              borderSide: const BorderSide(color: Color(0xFF4A148C)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const primaryPurple = Color(0xFF4A148C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: screenHeight * 0.30,
            pinned: false,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left_rounded,
                size: screenWidth * 0.08,
                color: Colors.black,
              ),
              onPressed: () => context.go(AppRoutes.home),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: _buildUserProfileHeader(screenWidth, screenHeight),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contact',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                        : SizedBox(
                      height: screenHeight * 0.15,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _contacts.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _contacts.length) {
                            return GestureDetector(
                              onTap: () =>
                                  _showContactDetailDialog(_contacts[index]),
                              child: ContactCard(contact: _contacts[index]),
                            );
                          } else {
                            return AddContactCard(
                                onTap: _showAddContactDialog);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: screenWidth * 0.05,
                          ),
                          onPressed: _showEditPersonalInfoDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildPersonalInformationBox(screenWidth, screenHeight),

                    // Logout Button
                    SizedBox(height: screenHeight * 0.03),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        context.go(AppRoutes.signIn);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.only(
        top: screenHeight * 0.12,
        left: screenWidth * 0.05,
        right: screenWidth * 0.05,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserAvatar(screenWidth),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Emma Watson',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          _buildUserId(screenWidth),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(double screenWidth) {
    return Container(
      width: screenWidth * 0.25,
      height: screenWidth * 0.25,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF6A1B9A),
          width: 3,
        ),
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/images/person.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUserId(double screenWidth) {
    const String userId = 'A1B2C3D40';
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            userId,
            style: TextStyle(fontSize: screenWidth * 0.038, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        InkWell(
          onTap: () {
            Clipboard.setData(const ClipboardData(text: userId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User ID copied to clipboard'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Icon(
            Icons.copy,
            size: screenWidth * 0.038,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
      ],
    );
  }

  Widget _buildPersonalInformationBox(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoItem('First Name', _firstName, screenWidth)),
              SizedBox(width: screenWidth * 0.04),
              Expanded(child: _buildInfoItem('Last Name', _lastName, screenWidth)),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Phone Number', _phoneNumber, screenWidth)),
              SizedBox(width: screenWidth * 0.04),
              Expanded(child: _buildInfoItem('Email', _email, screenWidth)),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(child: _buildInfoItem('City', _city, screenWidth)),
              SizedBox(width: screenWidth * 0.04),
              Expanded(child: _buildInfoItem('Country', _country, screenWidth)),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('Street Address', _streetAddress, screenWidth),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('Post Code', _postCode, screenWidth),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          value,
          style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.grey[700]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
