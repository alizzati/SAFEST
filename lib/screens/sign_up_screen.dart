import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gradient_button.dart';
import '../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controller untuk mengelola state password visibility
  bool _isPasswordVisible = false;

  // Controller untuk checkbox terms & conditions
  bool _isTermsAccepted = false;

  // Form key untuk validasi
  final _formKey = GlobalKey<FormState>();

  // Controller untuk text field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk handle sign up
  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please accept Terms of Service and Privacy Policy',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ Jika semua valid, pindah ke halaman Home/Profile
    context.go('/home'); // atau '/home' jika ada halaman home terpisah
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Menentukan apakah layar besar (tablet/desktop)
          final isLargeScreen = constraints.maxWidth > 600;

          // Mengatur max width untuk form agar tidak terlalu lebar di layar besar
          final maxWidth = isLargeScreen ? 400.0 : constraints.maxWidth * 0.9;

          // Menyesuaikan padding berdasarkan orientasi
          final verticalPadding = orientation == Orientation.portrait
              ? screenHeight * 0.05
              : screenHeight * 0.02;

          return SingleChildScrollView(
            // Menambahkan physics untuk smooth scrolling
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                // Memastikan konten minimal setinggi layar untuk center vertical
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ==================== HEADER SECTION ====================
                          // Judul "Secure Your Safety Today"
                          Text(
                            'Secure Your\nSafety Today',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen ? 40 : screenWidth * 0.1,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF512DA8),
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Subtitle/deskripsi
                          Text(
                            'Sign up now and stay connected with\nemergency contacts anytime, anywhere.',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen
                                  ? 14
                                  : screenWidth * 0.035,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7E7E7E),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(
                            height: orientation == Orientation.portrait
                                ? screenHeight * 0.03
                                : screenHeight * 0.03,
                          ),

                          // ==================== EMAIL INPUT FIELD ====================
                          TextFormField(
                            controller: _emailController,
                            validator: Validators.validateEmail,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: isLargeScreen
                                    ? 14
                                    : screenWidth * 0.038,
                                color: const Color(0xFF7E7E7E),
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              // Error style
                              errorStyle: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: isLargeScreen
                                    ? 12
                                    : screenWidth * 0.032,
                                color: Colors.red.shade600,
                              ),
                              // Border saat tidak fokus
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                              ),
                              // Border saat fokus
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF512DA8),
                                  width: 2,
                                ),
                              ),
                              // Border saat error
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red.shade600,
                                  width: 2,
                                ),
                              ),
                              // Border saat error dan fokus
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red.shade600,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.04,
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen
                                  ? 14
                                  : screenWidth * 0.038,
                              color: const Color(0xFF000000),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // ==================== PASSWORD INPUT FIELD ====================
                          TextFormField(
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: isLargeScreen
                                    ? 14
                                    : screenWidth * 0.038,
                                color: const Color(0xFF7E7E7E),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              // Error style
                              errorStyle: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: isLargeScreen
                                    ? 12
                                    : screenWidth * 0.032,
                                color: Colors.red.shade600,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF512DA8),
                                  width: 2,
                                ),
                              ),
                              // Border saat error
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red.shade600,
                                  width: 2,
                                ),
                              ),
                              // Border saat error dan fokus
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red.shade600,
                                  width: 2,
                                ),
                              ),
                              // Icon untuk show/hide password
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7E7E7E),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.04,
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: isLargeScreen
                                  ? 14
                                  : screenWidth * 0.038,
                              color: const Color(0xFF0F0F0F),
                            ),
                            // Toggle obscure text berdasarkan state
                            obscureText: !_isPasswordVisible,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // ==================== TERMS & CONDITIONS CHECKBOX ====================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Custom Checkbox dengan gradient border
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isTermsAccepted = !_isTermsAccepted;
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _isTermsAccepted
                                        ? const Color(0xFF512DA8)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _isTermsAccepted
                                          ? const Color(0xFF512DA8)
                                          : const Color(0xFFE0E0E0),
                                      width: 2,
                                    ),
                                  ),
                                  child: _isTermsAccepted
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              // Text dalam satu baris (flexible)
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontSize: isLargeScreen
                                          ? 13
                                          : screenWidth * 0.028,
                                      color: const Color(0xFF7E7E7E),
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            // TODO: Navigate to Terms of Service
                                          },
                                          child: Text(
                                            'Terms of Service',
                                            style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: isLargeScreen
                                                  ? 13
                                                  : screenWidth * 0.028,
                                              color: const Color(0xFF512DA8),
                                              fontWeight: FontWeight.w600,
                                              decorationColor: const Color(
                                                0xFF512DA8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            // TODO: Navigate to Privacy Policy
                                          },
                                          child: Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: isLargeScreen
                                                  ? 13
                                                  : screenWidth * 0.028,
                                              color: const Color(0xFF512DA8),
                                              fontWeight: FontWeight.w600,
                                              decorationColor: const Color(
                                                0xFF512DA8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // ==================== SIGN UP BUTTON ====================
                          GradientButton(
                            text: 'Sign Up',
                            onPressed: _handleSignUp,
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // ==================== DIVIDER WITH "OR" ====================
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: const Color(0xFFE0E0E0),
                                  thickness: 1,
                                  endIndent: screenWidth * 0.03,
                                ),
                              ),
                              Text(
                                'or',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: isLargeScreen
                                      ? 13
                                      : screenWidth * 0.035,
                                  color: const Color(0xFF7E7E7E),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: const Color(0xFFE0E0E0),
                                  thickness: 1,
                                  indent: screenWidth * 0.03,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.025),

                          // ==================== GOOGLE SIGN IN BUTTON ====================
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement Google sign in functionality
                                // await signInWithGoogle();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon Google di sebelah kiri
                                  Image.asset(
                                    'assets/images/google_icon.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  // Text Continue with Google (regular, tidak bold)
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontSize: isLargeScreen
                                          ? 14
                                          : screenWidth * 0.038,
                                      fontWeight: FontWeight.normal,
                                      color: const Color(0xFF0F0F0F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: orientation == Orientation.portrait
                                ? screenHeight * 0.025
                                : screenHeight * 0.02,
                          ),

                          // ==================== SIGN IN LINK ====================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: isLargeScreen
                                      ? 13
                                      : screenWidth * 0.035,
                                  color: const Color(0xFF512DA8),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push('/signin');
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: isLargeScreen
                                        ? 13
                                        : screenWidth * 0.035,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF512DA8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.02),
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
