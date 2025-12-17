import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;

  final LinearGradient? gradient;
  final LinearGradient? pressedGradient;
  final Color? textColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.gradient,
    this.pressedGradient,
    this.textColor,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final bool isDisabled = widget.onPressed == null;

    final defaultGradient =
        widget.gradient ??
        const LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final pressedGradient =
        widget.pressedGradient ??
        const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFC0C0C0)]);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTap: isDisabled
          ? null
          : () {
              widget.onPressed!();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? double.infinity,
        height: widget.height ?? screenHeight * 0.065,
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : (_isPressed ? pressedGradient : defaultGradient),
          color: isDisabled ? Colors.grey.shade200 : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!_isPressed && !isDisabled)
              const BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: widget.fontSize ?? (isLargeScreen ? 16 : 18),
              fontWeight: FontWeight.w700,
              color: isDisabled
                  ? Colors.grey
                  : (widget.textColor ?? Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
