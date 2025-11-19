import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String labelText;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isLargeScreen;
  final double screenWidth;
  final double screenHeight;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    required this.isLargeScreen,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = isLargeScreen ? 14.0 : screenWidth * 0.038;

    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: effectiveFontSize,
          color: const Color(0xFF7E7E7E),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
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
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.04,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: effectiveFontSize,
              color: const Color(0xFF000000),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Color(0xFF7E7E7E),
      ),
    );
  }
}