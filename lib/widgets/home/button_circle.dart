import 'package:flutter/material.dart';

class ButtonCircle extends StatelessWidget {
  final double size;
  final Color color;
  final IconData? icon;
  final String? assetImage;
  final VoidCallback onPressed;
  final Color? iconColor;
  final double? iconSize;
  final bool isActive;
  final Color? activeColor;
  final Color? shadowColor;

  const ButtonCircle({
    Key? key,
    required this.size,
    required this.color,
    required this.onPressed,
    this.icon,
    this.assetImage,
    this.iconColor,
    this.iconSize,
    this.isActive = false,
    this.activeColor,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? (activeColor ?? color) : color,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: (isActive
                ? (activeColor ?? color).withOpacity(0.5)
                : (shadowColor ?? Colors.black.withOpacity(0.2))),
            blurRadius: isActive ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: isActive
            ? Border.all(color: activeColor ?? Colors.red, width: 2)
            : null,
      ),
      child: IconButton(
        icon: assetImage != null
            ? Image.asset(
                assetImage!,
                width: iconSize ?? size * 0.5,
                height: iconSize ?? size * 0.5,
                color: iconColor,
              )
            : Icon(
                icon,
                color: iconColor ?? Colors.black,
                size: iconSize ?? size * 0.5,
              ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
