import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safest/models/emergency_status.dart';
import 'package:safest/widgets/emergency/status_card.dart';
import 'package:safest/widgets/emergency/end_call_confirmation_dialog.dart';

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen>
    with SingleTickerProviderStateMixin {
  Timer? _statusTimer;
  int _currentStatusIndex = 0;

  late AnimationController _pulsingAnimationController;
  late Animation<double> _pulsingAnimation;

  // Konstanta Ukuran
  static const double _statusCardVisualHeight = 100.0;
  static const double _buttonSafeSize = 250.0;
  static const double _buttonBaseSize = 180.0;
  // INNER DIPERBESAR SEDIKIT LAGI (dari 150.0 menjadi 160.0)
  static const double _buttonInnerSize = 160.0; 
  static const double _buttonIconSize = 80.0; // Icon diperbesar sedikit

  final List<EmergencyStatus> _allStatuses = [
    EmergencyStatus(
      text:
          'Emergency activated. Your location is being shared with your primary contact.',
      icon: Icons.location_on,
    ),
    EmergencyStatus(
      text:
          'Attempting to contact your emergency contact, if they do not respond, the next person in your list will be contacted.',
      icon: Icons.phone_in_talk,
    ),
    EmergencyStatus(
      text:
          'Recording has started to ensure your safety. Audio will be saved locally.',
      icon: Icons.graphic_eq,
    ),
    EmergencyStatus(
      text:
          'Stay calm and follow any instructions from your emergency contacts or local authorities.',
      icon: Icons.person_pin_circle,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulsingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Animasi Pulsing akan mengontrol skala (untuk shadow) dan opacity
    _pulsingAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulsingAnimationController, curve: Curves.easeInOut),
    );

    _startStatusSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _currentStatusIndex = 0; 
    _statusTimer?.cancel(); 
    _startStatusSequence(); 
  }

  void _startStatusSequence() {
    _statusTimer?.cancel(); 
    
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        if (_currentStatusIndex < _allStatuses.length - 1) { 
          _currentStatusIndex++;
        } else {
          _currentStatusIndex = 0; 
        }
      });
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel(); 
    _pulsingAnimationController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.home_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Emergency help\nneeded?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Just hold the button to call',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 40),

            _buildCallButton(),

            const SizedBox(height: 25),

            SizedBox(
              height: _statusCardVisualHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: StatusCard(
                  key: ValueKey(_currentStatusIndex),
                  status: _allStatuses[_currentStatusIndex],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    const redColor = Color(0xFFE53935);
    const innerRedColor = Color(0xFFC62828);
    
    return SizedBox(
      width: _buttonSafeSize,
      height: _buttonSafeSize,
      child: Center(
        child: GestureDetector(
          onTap: () {
            showHoldButtonDialog(context);
          },
          onLongPress: () {
            _statusTimer?.cancel();
            // Navigasi ke Calling Screen
            Navigator.of(context).pushNamed('/calling');
          },
          
          // --- STACK: Memastikan Base Button dan Inner Core Berbagi Titik Tengah ---
          child: Stack(
            alignment: Alignment.center,
            children: [
              
              // 1. BASE BUTTON DENGAN SCALING DAN OPACITY (Efek Pulsing)
              AnimatedBuilder(
                animation: _pulsingAnimation,
                builder: (context, child) {
                  return Opacity( // GOAL: Opacity Berubah
                    opacity: _pulsingAnimation.value * 0.8, // Nilai Opacity antara 0.8 dan 1.0 * 0.8
                    child: Container(
                      width: _buttonBaseSize * _pulsingAnimation.value,
                      height: _buttonBaseSize * _pulsingAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: redColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(_pulsingAnimation.value * 0.3),
                            blurRadius: 25,
                            spreadRadius: 8 * _pulsingAnimation.value,
                          ),
                          const BoxShadow(
                            color: Color(0xFFB71C1C),
                            offset: Offset(0, 5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // 2. INNER CORE (TETAP UKURANNYA)
              Container(
                width: _buttonInnerSize, // Ukuran Inner FIXED (160.0)
                height: _buttonInnerSize, // Ukuran Inner FIXED (160.0)
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                  color: innerRedColor,
                ),
                child: Center(
                  // Ikon (Ukuran TETAP)
                  child: Image.asset(
                    'assets/images/image_63e8bd.png', 
                    width: _buttonIconSize, 
                    height: _buttonIconSize,
                    color: Colors.white, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}