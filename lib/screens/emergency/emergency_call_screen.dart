import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Digunakan untuk navigasi GoRouter
import 'package:safest/models/emergency_status.dart'; // Pastikan path benar
import 'package:safest/widgets/emergency/status_card.dart'; // Pastikan path benar
import 'package:safest/widgets/emergency/end_call_confirmation_dialog.dart'; // Import showHoldButtonDialog

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen> with SingleTickerProviderStateMixin {
  Timer? _statusTimer;
  int _currentStatusIndex = 0; 

  late AnimationController _pulsingAnimationController;
  late Animation<double> _pulsingAnimation;
  
  // Konstanta Ukuran (Disetel untuk stabilitas)
  static const double _statusCardVisualHeight = 100.0;
  static const double _buttonSafeSize = 250.0; 
  static const double _buttonBaseSize = 180.0; 
  static const double _buttonInnerSize = 150.0;

  final List<EmergencyStatus> _allStatuses = [
    EmergencyStatus(
      text: 'Emergency activated. Your location is being shared with your primary contact.',
      icon: Icons.location_on, 
    ),
    EmergencyStatus(
      text: 'Attempting to contact your emergency contact, if they do not respond, the next person in your list will be contacted.',
      icon: Icons.phone_in_talk,
    ),
    EmergencyStatus(
      text: 'Recording has started to ensure your safety. Audio will be saved locally.',
      icon: Icons.graphic_eq,
    ),
    EmergencyStatus(
      text: 'Stay calm and follow any instructions from your emergency contacts or local authorities.',
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

    _pulsingAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulsingAnimationController, curve: Curves.easeInOut),
    );

    _startStatusSequence();
  }

  // Logika Looping Status
  void _startStatusSequence() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        if (_currentStatusIndex < _allStatuses.length - 1) { 
          _currentStatusIndex++;
        } else {
          _currentStatusIndex = 0; // Looping
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
      // Kunci untuk GoRouter popUntil, meskipun tidak digunakan secara langsung di sini
      key: const ValueKey('/emergency'), 
      
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (AppBar styling)
        title: const Text('9:41'), // Update waktu di App Bar
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hapus tombol back default
        actions: [
            IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.black),
                onPressed: () => context.go('/home'), // Navigasi GoRouter ke Home
            ),
            const SizedBox(width: 16),
        ],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => context.pop(), // Navigasi GoRouter kembali
        ),
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            _buildCallButton(),
            
            const SizedBox(height: 40), 

            // Daftar Status Dinamis (Stabil)
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
    return SizedBox(
      width: _buttonSafeSize, 
      height: _buttonSafeSize,
      child: Center( 
        child: GestureDetector(
          // --- SINGLE TAP (POPOVER) ---
          onTap: () {
            // Memanggil popover "Hold the button"
            showHoldButtonDialog(context);
          },
          // --- LONG PRESS (NAVIGASI KE CALLING) ---
          onLongPress: () {
            _statusTimer?.cancel();
            
            // Navigasi GoRouter menggunakan nama rute
            context.pushReplacementNamed('calling');
          },
          child: AnimatedBuilder( 
            animation: _pulsingAnimation,
            builder: (context, child) {
              return Container(
                width: _buttonBaseSize * _pulsingAnimation.value, 
                height: _buttonBaseSize * _pulsingAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(_pulsingAnimation.value * 0.3), 
                      blurRadius: 25, 
                      spreadRadius: 8 * _pulsingAnimation.value, 
                    ),
                    const BoxShadow(
                      color: Color(0xFFB71C1C),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: _buttonInnerSize,
                    height: _buttonInnerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                      color: const Color(0xFFC62828), 
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/image_63e8bd.png', 
                        width: 75,
                        height: 75,
                        color: Colors.white, 
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}