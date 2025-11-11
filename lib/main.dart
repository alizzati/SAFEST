import 'package:flutter/material.dart';
import 'package:safest/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Contact App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}class EmergencyContact {
  final String name;
  final String relationship;
  final String avatarUrl;
  final String? phoneNumber;
  final String? userId;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.avatarUrl,
    this.phoneNumber,
    this.userId,
  });
}