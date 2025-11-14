import 'package:flutter/material.dart';

class OnboardingDotIndicator extends StatelessWidget {
  final int index;
  final int currentPage;

  const OnboardingDotIndicator({
    super.key,
    required this.index,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: currentPage == index ? 32 : 8,
      decoration: BoxDecoration(
        color: currentPage == index
            ? const Color(0xFF512DA8)
            : const Color(0xFF512DA8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}