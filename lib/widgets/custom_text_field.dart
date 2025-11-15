import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;
  final String? initialValue;
  final double? fontSize;
  final bool isLargeScreen;
  final double screenWidth;
  final double screenHeight;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
    this.initialValue,
    this.fontSize,
    required this.isLargeScreen,
    required this.screenWidth,
    required this.screenHeight,
    this.fillColor,
    this.contentPadding,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = fillColor ?? Colors.white;
    final effectiveFontSize = fontSize ?? (isLargeScreen ? 14.0 : screenWidth * 0.038);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText ?? '',
        labelStyle: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: effectiveFontSize,
          color: const Color(0xFF7E7E7E),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: effectiveFillColor,
        suffixIcon: suffixIcon,
        errorStyle: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: isLargeScreen ? 12 : screenWidth * 0.032,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade600,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade600,
            width: 2,
          ),
        ),
        contentPadding: contentPadding ?? EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.04,
        ),
      ),
      style: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: effectiveFontSize,
        color: readOnly ? const Color(0xFF7E7E7E) : const Color(0xFF000000),
      ),
    );
  }
}