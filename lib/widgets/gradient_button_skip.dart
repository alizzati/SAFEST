import 'package:flutter/material.dart';

class GradientButtonSkip extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;

  const GradientButtonSkip({
    super.key,
    this.onPressed,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? double.infinity,
        height: height ?? screenHeight * 0.065,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDisabled)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Center(
          child: Text(
            'Skip',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(isDisabled ? 0.5 : 1),
            ),
          ),
        ),
      ),
    );
  }
}
