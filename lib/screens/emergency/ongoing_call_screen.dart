import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safest/widgets/emergency/end_call_confirmation_dialog.dart';

class OngoingCallScreen extends StatefulWidget {
  final bool isInitialSpeakerOn;
  
  // Menerima isInitialSpeakerOn dari rute
  const OngoingCallScreen({required this.isInitialSpeakerOn, super.key});

  @override
  State<OngoingCallScreen> createState() => _OngoingCallScreenState();
}

class _OngoingCallScreenState extends State<OngoingCallScreen> {
  Timer? _callTimer;
  Timer? _recordTimer; // Timer untuk perekaman
  
  int _secondsElapsed = 0; // Timer utama
  int _recordSeconds = 0; // Timer perekaman
  
  // STATE untuk tombol aksi
  late bool _isSpeakerOn; // Diinisialisasi dari argumen
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Menerima state speaker dari CallingScreen
    _isSpeakerOn = widget.isInitialSpeakerOn; 
    
    _startCallTimer();
    // TODO: (SOUND) Mulai efek suara BERBICARA di sini (Ongoing)
  }

  // Fungsi untuk memulai penghitung waktu utama
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  // Toggle Perekaman
  void _toggleRecording() {
    if (_isRecording) {
      // Stop Recording
      _recordTimer?.cancel();
      _recordSeconds = 0;
    } else {
      // Start Recording
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordSeconds++;
          });
        }
      });
    }
    setState(() {
      _isRecording = !_isRecording;
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
    _recordTimer?.cancel(); // Hentikan timer perekaman juga
    
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
      // TODO: (SOUND) Hentikan efek suara BERBICARA di sini
      Navigator.of(context).popUntil((route) => route.settings.name == '/emergency');
    } else {
      // Jika user menekan 'Cancel', lanjutkan timer
      _startCallTimer(); 
      if (_isRecording) {
        _toggleRecording(); // Lanjutkan timer perekaman jika sedang aktif
      }
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _recordTimer?.cancel();
    // TODO: (SOUND) Hentikan efek suara BERBICARA di sini
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkGray = Color(0xFF333333);
    const lightGray = Color(0xFF616161);
    const redColor = Color(0xFFE53935);
    const activeIconColor = Colors.white;

    return Scaffold(
      backgroundColor: darkGray,
      appBar: AppBar(
        title: const Text(
          'Ongoing Call ...',
          style: TextStyle(color: activeIconColor, fontWeight: FontWeight.bold),
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
              'Gensha', // Ganti dengan widget.contactName jika ada
              style: TextStyle(
                color: activeIconColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            
            // Timer Utama
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            
            // Indikator Perekaman
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Recording: ${_formatTime(_recordSeconds)}',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            
            const SizedBox(height: 80),

            // Call Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Speaker Button
                _buildActionCircle(
                  Icons.volume_up, 
                  'Speaker', 
                  lightGray,
                  onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  isActive: _isSpeakerOn,
                ),
                // Send Location
                _buildActionCircle(Icons.location_on, 'Send Location', lightGray),
                // Record Button
                _buildActionCircle(
                  Icons.fiber_manual_record_outlined, 
                  'Record', 
                  lightGray,
                  onTap: _toggleRecording,
                  isActive: _isRecording,
                ),
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
                  color: activeIconColor,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tombol aksi
  Widget _buildActionCircle(IconData icon, String label, Color bgColor, {VoidCallback? onTap, bool isActive = false}) {
    const darkGray = Color(0xFF333333);
    const activeColor = Colors.white;
    final displayBgColor = isActive ? activeColor : bgColor;
    final iconColor = isActive ? darkGray : activeColor;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: displayBgColor,
            ),
            child: Icon(icon, color: iconColor, size: 35),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: activeColor, fontSize: 14),
        ),
      ],
    );
  }
}