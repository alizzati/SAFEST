import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:safest/config/routes.dart'; 
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  Timer? _navigationTimer;
  Timer? _statusTimer;
  
  late AudioPlayer _audioPlayer; 

  int _seconds = 0;
  bool _isSpeakerOn = false; // State Speaker
  final String contactName = 'Mom'; 

  final AudioContext _earpieceContext = const AudioContext(
    android: AudioContextAndroid(
        usageType: AndroidUsageType.voiceCommunication,
        contentType: AndroidContentType.speech,
    ),
  );

  // Konteks untuk Speaker (Loudspeaker): Fokus pada media/umum, memaksa output speaker
  final AudioContext _speakerContext = const AudioContext(
    android: AudioContextAndroid(
        usageType: AndroidUsageType.media,
        contentType: AndroidContentType.music,
    ),
  );

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _startRinging();
    
    _navigationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _audioPlayer.stop(); 
        
        // Navigasi GoRouter dengan mengirimkan state speaker
        context.pushReplacementNamed(
          'ongoing_call', 
          // Menggunakan 'extra' untuk mengirimkan state speaker
          extra: {'isInitialSpeakerOn': _isSpeakerOn},
        );
      }
    });

    // Timer Status: Menghitung waktu
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _seconds++);
    });
  }
  
  void _startRinging() async {
    // Atur konteks awal ke Earpiece (Handset)
    await _audioPlayer.setAudioContext(_earpieceContext);
    
    // TODO: Ganti path audio
    await _audioPlayer.setSource(AssetSource('sounds/calling_audio.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.resume();
  }
  
  // Fungsi Toggle Speaker (Perbaikan Inti)
  void _toggleSpeaker() async {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });

    if (_isSpeakerOn) {
        // AKTIFKAN SPEAKER (Loudspeaker)
        await _audioPlayer.setAudioContext(_speakerContext); 
        print("Speaker: LOUDSPEAKER AKTIF"); 
    } else {
        // NON-AKTIFKAN SPEAKER (Earpiece/Handset)
        await _audioPlayer.setAudioContext(_earpieceContext);
        print("Speaker: EARPIECE AKTIF"); 
    }
  }


  @override
  void dispose() {
    _navigationTimer?.cancel();
    _statusTimer?.cancel();
    _audioPlayer.stop(); 
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    const darkGray = Color(0xFF333333);
    const redColor = Color(0xFFE53935);
    const activeIconColor = Colors.white;

    return Scaffold(
      backgroundColor: darkGray,
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: const Text(
          'Calling ...',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: darkGray,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar (Kontak)
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Nama Kontak
                Text(
                  contactName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                
                // Status Waktu
                Text(
                  'Calling... ${_formatTime(_seconds)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
                
                const SizedBox(height: 50), 
                
                // Call Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 1. Speaker Button
                      _buildActionCircle(
                        Icons.volume_up, 
                        'Speaker',
                        onTap: _toggleSpeaker, // Aktifkan Speaker
                        isActive: _isSpeakerOn, 
                      ),
                      
                      // 2. Location Button
                      _buildActionCircle(
                        Icons.location_on, 
                        'Location', 
                        onTap: () {}, 
                        isActive: false,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50), 
                
                // End Call Button
                GestureDetector(
                  // Navigasi langsung ke EmergencyScreen
                  onTap: () {
                    _audioPlayer.stop();
                    context.go(AppRoutes.emergency); 
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: redColor,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: activeIconColor,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildActionCircle
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
      ],
    );
  }
}