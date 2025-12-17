import 'package:flutter/material.dart';

Widget liveHistoryAppBar(
  double screenWidth,
  double screenHeight,
  Color purpleColor,
) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: screenHeight * 0.015,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Text(
          'Live Video History',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: purpleColor,
          ),
        ),
      ],
    ),
  );
}
