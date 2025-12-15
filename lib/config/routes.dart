import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/screens/fake_call/set_fake_call_screen.dart';
import 'package:safest/screens/home_screen.dart';
import 'package:safest/screens/profile_screen.dart';
import 'package:safest/screens/onboarding_screen.dart';
import 'package:safest/screens/emergency/emergency_call_screen.dart';
import 'package:safest/screens/emergency/calling_screen.dart';
import 'package:safest/screens/emergency/ongoing_call_screen.dart';
import 'package:safest/screens/sign_in_screen.dart';
import 'package:safest/screens/sign_up_screen.dart';
import 'package:safest/screens/splash_screen.dart';
import 'package:safest/screens/live_video_screen.dart';
import 'package:safest/screens/education_screen.dart';
import 'package:safest/widgets/custom_bottom_nav_bar.dart';
import 'package:safest/screens/personal_info_screen.dart';
import 'package:safest/screens/emergency_contact_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String profile = '/profile';
  static const String onBoarding = '/on_boarding';
  static const String emergency = '/emergency';
  static const String calling = '/calling';
  static const String home = '/home';
  static const String setFake = '/set_fake';
  static const String ongoingCall = '/ongoing_call';
  static const String liveVideo = '/liveVideo';
  static const String education = '/education';
  static const String personalInfo = '/personal-info';
  static const String emergencyContact = '/emergency-contact';
}

GoRouter createRouter() {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // initialLocation: AppRoutes.signIn,
    initialLocation: AppRoutes.signIn,

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
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyCallScreen(),
      ),
      GoRoute(
        path: AppRoutes.calling,
        name: 'calling',
        builder: (context, state) => const CallingScreen(),
      ),
      GoRoute(
        path: AppRoutes.ongoingCall,
        name: 'ongoing_call',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final bool isSpeakerOn = (args?['isSpeakerOn'] as bool?) ?? false;
          return OngoingCallScreen(isInitialSpeakerOn: isSpeakerOn);
        },
      ),

      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            extendBody: true,
            body: child,
            bottomNavigationBar: CustomBottomNavBar(), // Tambahkan const
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
            path: AppRoutes.liveVideo,
            builder: (context, state) => const LiveVideoScreen(),
          ),
          GoRoute(
            path: AppRoutes.education,
            builder: (context, state) => const EducationScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
