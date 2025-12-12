import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:safest/screens/splash_screen.dart';
import 'package:safest/screens/sign_in_screen.dart';
import 'package:safest/screens/sign_up_screen.dart';
import 'package:safest/screens/onboarding_screen.dart';
import 'package:safest/screens/personal_info_screen.dart';
import 'package:safest/screens/emergency_contact_screen.dart';
import 'package:safest/screens/home_screen.dart';
import 'package:safest/screens/fake_call/set_fake_call_screen.dart';
import 'package:safest/screens/education_screen.dart';
import 'package:safest/widgets/custom_bottom_nav_bar.dart';
import 'package:safest/screens/emergency/emergency_call_screen.dart';
import 'package:safest/screens/emergency/calling_screen.dart';
import 'package:safest/screens/emergency/ongoing_call_screen.dart';
import 'package:safest/screens/live_video_screen.dart';
import 'package:safest/screens/profile_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const profile = '/profile';
  static const onBoarding = '/on_boarding';
  static const personalInfo = '/personal-info';
  static const emergencyContact = '/emergency-contact';
  static const home = '/home';
  static const setFake = '/set_fake';
  static const education = '/education';
  static const emergency = '/emergency';
  static const calling = '/calling';
  static const ongoingCall = '/ongoing_call';
  static const liveVideo = '/live_video';
}

GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.onBoarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergencyContact,
        builder: (context, state) => const EmergencyContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyCallScreen(),
      ),
      GoRoute(
        path: AppRoutes.calling,
        builder: (context, state) => const CallingScreen(),
      ),
      GoRoute(
        path: AppRoutes.liveVideo,
        builder: (context, state) => const LiveVideoScreen(),
      ),
      GoRoute(
        path: AppRoutes.ongoingCall,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final bool isSpeakerOn = (args?['isSpeakerOn'] as bool?) ?? false;
          return OngoingCallScreen(isInitialSpeakerOn: isSpeakerOn);
        },
      ),
      // ShellRoute untuk bottom nav
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            extendBody: true,
            body: child,
            bottomNavigationBar: CustomBottomNavBar(),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.setFake,
            builder: (context, state) => const SetFakeCallScreen(),
          ),
          GoRoute(
            path: AppRoutes.education,
            builder: (context, state) => const EducationScreen(),
          ),
        ],
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) async {
      final User? user = FirebaseAuth.instance.currentUser;
      final String location = state.uri.path;

      final isAuthRoute = location == AppRoutes.signIn || location == AppRoutes.signUp;
      final isOnboardingRoute = location == AppRoutes.personalInfo || location == AppRoutes.emergencyContact;
      final isSplash = location == AppRoutes.splash;

      // 1. User belum login → arahkan ke SignIn kecuali sedang akses SignIn / SignUp / Splash
      if (user == null) {
        if (isAuthRoute || isSplash) return null;
        return AppRoutes.signIn;
      }

      // 2. User sudah login → cek profile
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();

      final bool profileComplete = data?['profileComplete'] == true;
      final bool hasEmergencyContact = data?['emergencyContacts'] != null;

      // Profile belum lengkap → Personal Info
      if (!profileComplete) {
        if (isOnboardingRoute) return null;
        return AppRoutes.personalInfo;
      }

      // Profile lengkap tapi emergency contact belum ada → Emergency Contact
      if (profileComplete && !hasEmergencyContact) {
        if (location == AppRoutes.emergencyContact) return null;
        return AppRoutes.emergencyContact;
      }

      // Profile lengkap + emergency contact ada → arahkan ke Home jika coba akses route auth / onboarding / splash
      if (profileComplete && hasEmergencyContact) {
        if (isAuthRoute || isOnboardingRoute || isSplash) return AppRoutes.home;
        return null;
      }

      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('404 - Page Not Found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Path: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Splash'),
            ),
          ],
        ),
      ),
    ),
  );
}
