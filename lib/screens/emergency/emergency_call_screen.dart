// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; 
// import 'package:safest/models/emergency_status.dart'; 
import 'package:safest/widgets/emergency/status_card.dart'; 
// import 'package:safest/widgets/emergency/end_call_confirmation_dialog.dart'; 
import 'package:safest/widgets/custom_bottom_nav_bar.dart';
import 'package:safest/services/emergency_status_service.dart'; 

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen>
    with SingleTickerProviderStateMixin {
  
  // HAPUS: Timer? _statusTimer;
  // HAPUS: int _currentStatusIndex = 0;
  // HAPUS: final List<EmergencyStatus> _allStatuses = [...]
  // Logika status dipindahkan ke EmergencyStatusService

  late AnimationController _pulsingAnimationController;
  late Animation<double> _pulsingAnimation;

  // Konstanta Ukuran (Disetel untuk stabilitas)
  static const double _statusCardVisualHeight = 100.0;
  static const double _buttonSafeSize = 250.0;
  static const double _buttonBaseSize = 180.0;
  static const double _buttonInnerSize = 150.0;

  @override
  void initState() {
    super.initState();

    _pulsingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulsingAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulsingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // MEMULAI LOOP STATUS menggunakan Service
    // Ini memastikan loop status selalu berjalan saat user berada di halaman ini
    if (!emergencyStatusService.isActive) {
        emergencyStatusService.startEmergencyStatusLoop();
    }
  }

  // HAPUS: Method _startStatusSequence() yang lama

  @override
  void dispose() {
    // HANYA CANCEL ANIMASI CONTROLLER (Timer status dikelola oleh Service)
    _pulsingAnimationController.dispose();
    super.dispose();
  }

  void _onHoldEnd() {
    // Timer di Service tetap berjalan saat navigasi
    // Navigasi ke CallingScreen
    context.pushReplacementNamed('calling');
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6A1B9A);
    
    return Scaffold(
      backgroundColor: Colors.white,
      
      // HILANGKAN APPBAR (ganti dengan toolbar height 0)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, 
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      
      // Tambahkan CustomBottomNavBar
      bottomNavigationBar: CustomBottomNavBar(), 
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tombol Navigasi Manual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => context.pop(), 
                ),
                IconButton(
                    icon: const Icon(Icons.home_outlined, color: Colors.black),
                    onPressed: () => context.go('/home'), 
                ),
              ],
            ),
            const SizedBox(height: 10),
            
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

            // Daftar Status Dinamis (MENDENGARKAN SERVICE)
            SizedBox(
              height: _statusCardVisualHeight, 
              child: ListenableBuilder(
                listenable: emergencyStatusService, // <--- LISTENER BARU
                builder: (context, child) {
                  // Gunakan AnimatedSwitcher untuk efek fade
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: StatusCard(
                      // Gunakan key unik agar AnimatedSwitcher bekerja
                      key: ValueKey(emergencyStatusService.currentStatus.text), 
                      status: emergencyStatusService.currentStatus, // Ambil dari Service
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40), // Buffer untuk Navbar
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    // Implementasi tombol pulsing tetap sama
    return SizedBox(
      width: _buttonSafeSize,
      height: _buttonSafeSize,
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Memanggil popover "Hold the button" (fungsi showHoldButtonDialog harus diimpor/didefinisikan)
            // showHoldButtonDialog(context); 
          },
          onLongPress: _onHoldEnd, 
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
                        'assets/images/call_sos.png',
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