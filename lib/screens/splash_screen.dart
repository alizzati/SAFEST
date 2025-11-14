import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _shieldController;
  late AnimationController _rippleController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  // Animations
  late Animation<double> _shieldScale;
  late Animation<double> _shieldRotation;
  late Animation<double> _shieldOpacity;
  late Animation<double> _titleOpacity;
  late Animation<double> _titleScale;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  bool _showPressText = false;

  @override
  void initState() {
    super.initState();

    // ==================== MAIN CONTROLLER ====================
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // ==================== SHIELD ANIMATIONS ====================
    // Shield muncul dengan dramatic effect
    _shieldController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shieldScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_shieldController);

    _shieldRotation = Tween<double>(begin: math.pi * 2, end: 0.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeOutBack),
    );

    _shieldOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shieldController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ==================== TITLE ANIMATIONS ====================
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    _titleScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
          ),
        );

    // ==================== TAGLINE ANIMATIONS ====================
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
          ),
        );

    // ==================== RIPPLE EFFECT ====================
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // ==================== PARTICLES ====================
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // ==================== GLOW PULSE ====================
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // ==================== START SEQUENCE ====================
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Shield animation
    await Future.delayed(const Duration(milliseconds: 300));
    _shieldController.forward();

    // Main animation (title + tagline)
    await Future.delayed(const Duration(milliseconds: 100));
    _mainController.forward();

    // Setelah animasi utama selesai, tampilkan "Press Anything"
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _showPressText = true;
      });
    }

    // Jangan langsung navigate — tunggu user tap
    // await Future.delayed(const Duration(milliseconds: 2500));
    // _navigateToNext();
  }

  void _navigateToNext() {
    context.go(AppRoutes.onBoarding);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shieldController.dispose();
    _rippleController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      // <— tangkap tap di mana saja
      onTap: _navigateToNext,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7E57C2),
                Color(0xFF673AB7),
                Color(0xFF512DA8),
                Color(0xFF4527A0),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              ...List.generate(30, (index) => _buildParticle(size, index)),
              _buildAnimatedOverlay(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ==================== SHIELD ANIMATION ====================
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._buildRipples(),
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 160 + (_glowController.value * 20),
                                height: 160 + (_glowController.value * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(
                                        0.3 * (1 - _glowController.value),
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _shieldController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _shieldScale.value,
                                child: Transform.rotate(
                                  angle: _shieldRotation.value,
                                  child: Opacity(
                                    opacity: _shieldOpacity.value,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Color(0xFFF5F5F5),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(70),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                          BoxShadow(
                                            color: Colors.purple.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shield,
                                        size: 80,
                                        color: Color(0xFF512DA8),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ==================== APP NAME ====================
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _titleSlide,
                          child: ScaleTransition(
                            scale: _titleScale,
                            child: FadeTransition(
                              opacity: _titleOpacity,
                              child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return const LinearGradient(
                                    colors: [Colors.white, Color(0xFFE1BEE7)],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  'SAFEST',
                                  style: TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 8,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==================== TAGLINE ====================
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            SlideTransition(
                              position: _taglineSlide,
                              child: FadeTransition(
                                opacity: _taglineOpacity,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Your Safety, Our Priority',
                                    style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // ==================== PRESS ANYTHING TEXT ====================
                            AnimatedOpacity(
                              opacity: _showPressText ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              child: const Text(
                                'Press Anything',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== RIPPLE WAVES ====================
  List<Widget> _buildRipples() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          final delay = index * 0.33;
          final progress = (_rippleController.value + delay) % 1.0;
          final scale = 1.0 + (progress * 1.5);
          final opacity = 1.0 - progress;

          return Opacity(
            opacity: opacity * 0.3,
            child: Container(
              width: 140 * scale,
              height: 140 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          );
        },
      );
    });
  }

  // ==================== PARTICLES ====================
  Widget _buildParticle(Size size, int index) {
    final random = math.Random(index);
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final particleSize = 2.0 + random.nextDouble() * 6;
    final speed = 0.3 + random.nextDouble() * 0.7;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value * speed) % 1.0;
        final x = startX + (math.sin(progress * math.pi * 2 + index) * 60);
        final y = startY + (progress * size.height * 0.3);
        final opacity = (math.sin(progress * math.pi * 2) + 1) / 2;

        return Positioned(
          left: x,
          top: y % size.height,
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity * 0.4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(opacity * 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== ANIMATED OVERLAY ====================
  Widget _buildAnimatedOverlay() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(
                  0.05 * (1 - _particleController.value),
                ),
                Colors.transparent,
                Colors.purple.withOpacity(0.1 * _particleController.value),
              ],
            ),
          ),
        );
      },
    );
  }
}
