import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; 

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  Timer? _navigationTimer;
  Timer? _statusTimer;
  
  // Audio Player
  late AudioPlayer _audioPlayer; 

  int _seconds = 0;
  bool _isSpeakerOn = false; 
  final String contactName = 'Mom'; 

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _startRinging();
    
    _navigationTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        // Hentikan ringing sebelum navigasi
        _audioPlayer.stop(); 
        
        // Navigasi ke OngoingCallScreen sambil MENGIRIMKAN STATE SPEAKER
        Navigator.of(context).pushReplacementNamed(
          '/ongoing_call', 
          arguments: {'isSpeakerOn': _isSpeakerOn},
        );
      }
    });

    // 2. Timer Status: Menghitung waktu
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _seconds++);
    });
  }
  
  // Fungsi untuk memulai Ringing (Looped)
  void _startRinging() async {
    // Memastikan audioplayer berada dalam mode looping
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Asumsi file 'ringing.mp3' ada di assets/audio/
    // Anda harus mendaftarkan folder 'assets/audio/' di pubspec.yaml
    await _audioPlayer.play(AssetSource('sounds/calling_audio.mp3'));
  }

  @override
  void dispose() {
    // Hentikan dan dispose audio saat widget di-dispose
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _navigationTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }
  
  // Format waktu (00:05)
  String _formatTime(int seconds) {
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const darkGray = Color(0xFF333333);
    const redColor = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: darkGray,
      appBar: AppBar(
        title: const Text(
          'Calling...',
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
            // Avatar
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Nama kontak
            Text(
              contactName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            
            // Waktu
            Text(
              _formatTime(_seconds),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 80),

            // Call Actions
            Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 20.0), 
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, 
                children: [
                  // 1. Speaker Button
                  SizedBox(
                    height: 80, 
                    child: Center(
                      child: _buildActionCircle(
                        Icons.volume_up,
                        'Speaker',
                        onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                        isActive: _isSpeakerOn,
                      ),
                    ),
                  ),
                  
                  // 2. End Call Button (80x80)
                  GestureDetector(
                    onTap: () {
                      _audioPlayer.stop(); 
                      Navigator.of(context).pop();
                    },
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
                  
                  // 3. Location Button
                  SizedBox(
                    height: 80, 
                    child: Center(
                      child: _buildActionCircle(
                        Icons.location_on, 
                        'Location', 
                        // ... (parameter lain)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mengubah _buildActionCircle agar menerima onTap dan isActive
  Widget _buildActionCircle(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    const darkGray = Color(0xFF333333);
    const lightGray = Color(0xFF616161);
    const activeColor = Colors.white;
    
    final bgColor = isActive ? activeColor : lightGray;
    final iconColor = isActive ? darkGray : Colors.white;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(icon, color: iconColor, size: 35),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
