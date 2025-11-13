import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/gradient_button.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../models/onboarding_data.dart';
import '../utils/onboarding_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Page controller untuk mengontrol PageView
  final PageController _pageController = PageController();

  // Index halaman saat ini
  int _currentPage = 0;

  // Timer untuk auto slide
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk memulai auto slide
  void _startAutoSlide() {
    _timer = Timer.periodic(
      Duration(seconds: OnboardingConstants.autoSlideDuration),
          (timer) {
        if (_currentPage < OnboardingConstants.pages.length - 1) {
          _currentPage++;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          // Jika sudah halaman terakhir, stop timer
          _timer?.cancel();
        }
      },
    );
  }

  // Fungsi untuk reset timer saat user manual swipe
  void _resetTimer() {
    _timer?.cancel();
    _startAutoSlide();
  }

  // Fungsi untuk pindah ke halaman berikutnya
  void _nextPage() {
    if (_currentPage < OnboardingConstants.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigasi ke sign in screen
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  // Fungsi untuk skip ke halaman terakhir
  void _skipToEnd() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ==================== PAGE VIEW ====================
          // PageView untuk swipe antar halaman
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _resetTimer();
            },
            itemCount: OnboardingConstants.pages.length,
            itemBuilder: (context, index) {
              return _buildPage(
                OnboardingConstants.pages[index],
                screenHeight,
                screenWidth,
              );
            },
          ),

          // ==================== SKIP BUTTON ====================
          // Tombol skip di kanan atas (hanya muncul jika bukan halaman terakhir)
          if (_currentPage < OnboardingConstants.pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _skipToEnd,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== BUILD SINGLE PAGE ====================
  // Widget untuk membangun satu halaman onboarding
  Widget _buildPage(
      OnboardingData data,
      double screenHeight,
      double screenWidth,
      ) {
    return Stack(
      children: [
        // ==================== BACKGROUND IMAGE ====================
        // Background image dengan gradient overlay
        Positioned.fill(
          child: Stack(
            children: [
              // Background image
              Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                // Error handling jika gambar tidak ditemukan
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF9C7FC9), // Purple light
                          Color(0xFF7B5FA6), // Purple medium
                          Color(0xFF512DA8), // Purple dark
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Gradient overlay untuk membuat teks lebih terbaca
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==================== CONTENT ====================
        Column(
          children: [
            // Spacer untuk top padding
            SizedBox(height: screenHeight * 0.15),

            // ==================== TITLE & SUBTITLE ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                height: 132, // Total fixed height untuk title + subtitle area
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    // Spacing antara title dan subtitle (hanya muncul jika subtitle ada)
                    if (data.subtitle.isNotEmpty) const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Spacer yang lebih kecil agar card naik
            SizedBox(height: screenHeight * 0.25),

            // ==================== BOTTOM CARD ====================
            // Card putih di bawah dengan description, dots indicator, dan button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
              ), // Jarak 5% dari kiri-kanan
              child: Container(
                width: double.infinity,
                // Padding responsif berdasarkan ukuran layar
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.04,
                ),
                // Min height agar card lebih besar
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.35,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Description text dengan ukuran responsif
                    Text(
                      data.description,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: screenWidth * 0.04, // Responsif
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF512DA8).withOpacity(0.8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // ==================== DOTS INDICATOR ====================
                    // Indicator dots untuk menunjukkan halaman ke berapa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        OnboardingConstants.pages.length,
                            (index) => OnboardingDotIndicator(
                          index: index,
                          currentPage: _currentPage,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // ==================== NEXT BUTTON ====================
                    // Tombol Next/Get Started dengan GradientButton widget
                    GradientButton(
                      text: _currentPage == OnboardingConstants.pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: _nextPage,
                      height: screenHeight * 0.07,
                      fontSize: screenWidth * 0.045,
                    ),
                  ],
                ),
              ),
            ),

            // Spacer bawah agar tidak terpotong
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ],
    );
  }
}