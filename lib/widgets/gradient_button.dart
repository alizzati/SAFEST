import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final bool isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: isDisabled ? null : (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed!();
      },
      onTapCancel: isDisabled ? null : () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? double.infinity,
        height: widget.height ?? screenHeight * 0.065,
        decoration: BoxDecoration(
          gradient: _isPressed
              ? const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFC0C0C0)]) // Warna abu-abu saat disabled
              : _isPressed
              ? null
              : const LinearGradient(
            colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: _isPressed ? Colors.white : null,
          borderRadius: BorderRadius.circular(12),
          border: _isPressed
              ? null
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            if (!_isPressed && !isDisabled)
              const BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
          ],
        ),
        child: Container(
          decoration: _isPressed
              ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: const GradientBoxBorder(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
              ),
              width: 3,
            ),
          )
              : null,
          child: Center(
            child: Text(
              widget.text,
              style: isDisabled
                  ? TextStyle(
                fontFamily: 'OpenSans',
                fontSize: widget.fontSize ?? (isLargeScreen ? 16 : 18),
                fontWeight: FontWeight.w700,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                  ).createShader(
                    const Rect.fromLTWH(0, 0, 200, 50),
                  ),
              )
                  : TextStyle(
                fontFamily: 'OpenSans',
                fontSize: widget.fontSize ?? (isLargeScreen ? 16 : 18),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}