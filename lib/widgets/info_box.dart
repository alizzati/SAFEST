import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
