import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signing in...'),
          backgroundColor: Color(0xFF512DA8),
          duration: Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        context.go(AppRoutes.home);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          final maxWidth = isLargeScreen ? 400.0 : constraints.maxWidth * 0.9;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Container(
                  width: maxWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: isLargeScreen ? 40 : screenWidth * 0.1,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF512DA8),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        Text(
                          'Log in to continue and access your account',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: isLargeScreen ? 14 : screenWidth * 0.035,
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
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          isLargeScreen: isLargeScreen,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Forgot password
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
                                color: const Color(0xFF512DA8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // Sign In Button
                        GradientButton(
                          text: 'Sign In',
                          onPressed: _handleSignIn,
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Divider
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
                                fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
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

                        // Google Sign In
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.065,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Google sign in
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
                                Image.asset(
                                  'assets/images/google_icon.png',
                                  height: 20,
                                  width: 20,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: isLargeScreen ? 14 : screenWidth * 0.038,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF0F0F0F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
                                color: const Color(0xFF512DA8),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push(AppRoutes.signUp);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: isLargeScreen ? 13 : screenWidth * 0.035,
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
          );
        },
      ),
    );
  }
}