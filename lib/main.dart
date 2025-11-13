import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/emergency/emergency_call_screen.dart';
import 'screens/emergency/calling_screen.dart';
import 'screens/emergency/ongoing_call_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safest',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF512DA8)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Setup routes
      // initialRoute: '/signup', // Screen pertama yang muncul
      initialRoute: '/emergency (sos)',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/emergency (sos)': (context) => const EmergencyCallScreen(), // Target popUntil
        '/calling': (context) => const CallingScreen(),
        '/ongoing_call': (context) => const OngoingCallScreen(),
      },
    );
  }
}
