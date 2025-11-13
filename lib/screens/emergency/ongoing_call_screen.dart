import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safest/widgets/emergency/end_call_confirmation_dialog.dart';

class OngoingCallScreen extends StatefulWidget {
  const OngoingCallScreen({super.key});

  @override
  State<OngoingCallScreen> createState() => _OngoingCallScreenState();
}

class _OngoingCallScreenState extends State<OngoingCallScreen> {
  Timer? _callTimer;
  int _secondsElapsed = 0; // Mulai dari 0 detik

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  // Fungsi untuk memulai penghitung waktu
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  // Format waktu (misal: 01:21)
  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Fungsi untuk menampilkan dialog konfirmasi
  Future<void> _showEndCallConfirmation(BuildContext context) async {
    // Memastikan timer berhenti saat dialog muncul
    _callTimer?.cancel(); 
    
    final bool? endCall = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return const EndCallConfirmationDialog();
      },
    );

    // Jika user menekan 'Sure' (true)
    if (endCall == true) {
      // NAVIGASI KEMBALI KE EMERGENCY SCREEN
      // Menggunakan popUntil untuk membersihkan stack hingga rute '/emergency'
      Navigator.of(context).popUntil((route) => route.settings.name == '/emergency');
    } else {
      // Jika user menekan 'Cancel', lanjutkan timer
      _startCallTimer(); 
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkGray = Color(0xFF333333);
    const lightGray = Color(0xFF616161);
    const redColor = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: darkGray,
      appBar: AppBar(
        title: const Text(
          'Ongoing Call ...',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: darkGray,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Placeholder
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightGray,
              ),
              child: const Icon(Icons.person, size: 90, color: darkGray),
            ),
            const SizedBox(height: 20),
            
            // Contact Name
            const Text(
              'Mom',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            
            // --- TAMPILAN WAKTU YANG TERUS BERTAMBAH ---
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            // --- AKHIR TAMPILAN WAKTU ---
            
            const SizedBox(height: 80),

            // Call Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCircle(Icons.volume_up, 'Speaker', lightGray),
                _buildActionCircle(Icons.location_on, 'Send Location', lightGray),
                _buildActionCircle(Icons.fiber_manual_record_outlined, 'Record', lightGray),
              ],
            ),
            const SizedBox(height: 80),

            // End Call Button
            GestureDetector(
              onTap: () => _showEndCallConfirmation(context),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: redColor,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, String label, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: Icon(icon, color: Colors.white, size: 35),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}