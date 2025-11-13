import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  Timer? _navigationTimer;
  Timer? _statusTimer;
  int _seconds = 0;
  bool _navigated = false;

  final String contactName = 'Mom';

  @override
  void initState() {
    super.initState();

    // Navigasi otomatis setelah 5 detik
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_navigated) {
        _navigated = true;
        context.pushReplacement(AppRoutes.ongoingCall);
      }
    });

    // Timer status
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _statusTimer?.cancel();
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

            // Tombol aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCircle(Icons.volume_up, 'Speaker', lightGray),

                // Tombol merah (akhiri panggilan)
                GestureDetector(
                  onTap: () {
                    if (_navigated) return; // cegah double navigasi
                    _navigationTimer?.cancel();
                    _navigated = true;
                    context.pop(AppRoutes.emergency);
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
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                _buildActionCircle(Icons.location_on, 'Location', lightGray),
              ],
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
          child: Icon(icon, color: Colors.white, size: 35),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
