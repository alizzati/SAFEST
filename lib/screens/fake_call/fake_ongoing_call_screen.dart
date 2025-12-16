import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:safest/widgets/emergency/end_call_confirmation_dialog.dart';

class FakeOngoingCallScreen extends StatefulWidget {
  // Menerima isInitialSpeakerOn dari rute (Perbaikan 2)

  final String name;
  final String phone;
  final bool isInitialSpeakerOn;

  const FakeOngoingCallScreen({
    required this.name,
    required this.phone,
    required this.isInitialSpeakerOn,
    super.key,
  });

  @override
  State<FakeOngoingCallScreen> createState() => _FakeOngoingCallScreenState();
}

class _FakeOngoingCallScreenState extends State<FakeOngoingCallScreen> {
  Timer? _callTimer;
  Timer? _recordTimer;

  int _secondsElapsed = 0;
  int _recordSeconds = 0;

  late bool _isSpeakerOn; // Diinisialisasi dari argumen (Perbaikan 2)
  bool _isRecording = false;

  // Konstanta untuk GAP/Space Timer
  static const double _recordTimerContentHeight = 35.0;
  static const double _recordTimerVerticalPadding = 5.0;
  static const double _recordTimerSpace =
      _recordTimerContentHeight + _recordTimerVerticalPadding * 2;
  static const double _gapBeforeActions = 50.0; // Disesuaikan agar lebih stabil

  @override
  void initState() {
    super.initState();
    // Menerima state speaker dari CallingScreen (Perbaikan 2)
    _isSpeakerOn = widget.isInitialSpeakerOn;

    // TODO: (SOUND) Atur Audio Output ke Speaker jika _isSpeakerOn true, atau ke Earpiece jika false.

    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  // Fungsi Toggle Speaker (Perbaikan 3)
  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // TODO: (SOUND) Atur Audio Output sesuai status _isSpeakerOn yang baru.
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _recordSeconds = 0;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _recordSeconds++);
        }
      });
    } else {
      _recordTimer?.cancel();
    }
  }

  // Navigasi End Call (Perbaikan 1)
  void _showEndCallConfirmation(BuildContext context) {
    // Hentikan timer saat dialog muncul
    _callTimer?.cancel();
    _recordTimer?.cancel();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return EndCallConfirmationDialog(
          // Callback saat tombol "Sure" di-tekan
          onConfirm: () {
            // 1. Tutup dialog konfirmasi
            Navigator.of(dialogContext).pop();

            // 2. Navigasi GoRouter ke Emergency Screen (PERBAIKAN UTAMA)
            context.go(AppRoutes.setFake);
          },
          // Callback saat tombol "Cancel" di-tekan
          onCancel: () {
            // Tutup dialog
            Navigator.of(dialogContext).pop();
            // Lanjutkan timer
            _startCallTimer();
            if (_isRecording) {
              _toggleRecording();
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _recordTimer?.cancel();
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
    const lightGray = Color(0xFF616161);
    const activeIconColor = Colors.white;

    return Scaffold(
      backgroundColor: darkGray,
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: const Text(
          'Ongoing Call',
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
            padding: const EdgeInsets.symmetric(vertical: 10.0),
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

                // Nama kontak
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  widget.phone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 5),

                // Waktu Panggilan (Utama)
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(color: Colors.white70, fontSize: 20),
                ),

                // Record Timer (GAP/SPACE STABIL)
                SizedBox(
                  height: _recordTimerSpace,
                  child: Center(
                    child: Visibility(
                      visible: _isRecording,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _formatTime(_recordSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: _gapBeforeActions),

                // Call Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Speaker Button
                      _buildActionCircle(
                        Icons.volume_up,
                        'Speaker',
                        lightGray,
                        onTap: _toggleSpeaker, // Panggil fungsi toggle speaker
                        isActive: _isSpeakerOn, // Gunakan state _isSpeakerOn
                      ),

                      // Location Button
                      _buildActionCircle(
                        Icons.location_on,
                        'Location',
                        lightGray,
                      ),

                      // Record Button
                      _buildActionCircle(
                        Icons.fiber_manual_record,
                        'Record',
                        lightGray,
                        onTap: _toggleRecording,
                        isActive: _isRecording,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // End Call Button
                GestureDetector(
                  onTap: () => _showEndCallConfirmation(context),
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

  // Widget untuk tombol aksi
  Widget _buildActionCircle(
    IconData icon,
    String label,
    Color bgColor, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
