import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const SafestApp());
}

class SafestApp extends StatelessWidget {
  const SafestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAFEST App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}
