import '../models/onboarding_data.dart';

class OnboardingConstants {
  // Data onboarding (gambar, title, description)
  static final List<OnboardingData> pages = [
    OnboardingData(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Welcome to',
      subtitle: 'Your personal security solution!',
      description: 'Enjoy peace of mind anytime, anywhere. Protect yourself and your loved ones with advanced safety features.',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Interactive Crime Map',
      subtitle: '',
      description: 'Explore crime-prone areas around you in real-time. Stay informed and make safer decisions.',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding3.png',
      title: 'One-Tap SOS Access',
      subtitle: '',
      description: 'Get help instantly during emergencies with a single tap, ensuring safety and support when you need it most.',
    ),
  ];

  // Durasi auto slide (detik)
  static const int autoSlideDuration = 5;
}