import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:safest/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    if (!_isTermsAccepted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please accept Terms of Service and Privacy Policy',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please sign in.'),
            backgroundColor: Color(0xFF512DA8),
          ),
        );
        context.go(AppRoutes.signIn);
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Registration failed.";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      await AuthService().signInWithGoogle();
      if (mounted) context.go(AppRoutes.personalInfo);
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? "Authentication failed.";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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
          final maxWidth = isLargeScreen ? 400.0 : constraints.maxWidth * 0.9;
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          SizedBox(height: screenHeight * 0.03),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email Address',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            isLargeScreen: isLargeScreen,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            obscureText: !_isPasswordVisible,
                            validator: Validators.validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF7E7E7E),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                );
                              },
                            ),
                            isLargeScreen: isLargeScreen,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _isTermsAccepted = !_isTermsAccepted,
                                  );
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
                                          onTap: () {},
                                          child: Text(
                                            'Terms of Service',
                                            style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: isLargeScreen
                                                  ? 13
                                                  : screenWidth * 0.028,
                                              color: const Color(0xFF512DA8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: isLargeScreen
                                                  ? 13
                                                  : screenWidth * 0.028,
                                              color: const Color(0xFF512DA8),
                                              fontWeight: FontWeight.w600,
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
                          GradientButton(
                            text: _isLoading ? 'Signing Up...' : 'Sign Up',
                            onPressed: _isLoading ? null : _handleSignUp,
                          ),
                          SizedBox(height: screenHeight * 0.03),
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
                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed: _isGoogleLoading
                                  ? null
                                  : _handleGoogleSignIn,
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
                                  Image.asset(
                                    'assets/images/google_icon.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Text(
                                    _isGoogleLoading
                                        ? 'Signing in...'
                                        : 'Continue with Google',
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
                                onPressed: () => context.go(AppRoutes.signIn),
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
