import 'package:flutter/material.dart';

// --- Dialog Konfirmasi End Call ---
class EndCallConfirmationDialog extends StatelessWidget {
  // Tambahkan kedua callback untuk konfirmasi dan batal
  final VoidCallback onConfirm;
  final VoidCallback onCancel; 

  const EndCallConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6A1B9A);
    const redColor = Color(0xFFE53935);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: primaryPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure wants to\\nend the call?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Button "Sure"
              TextButton(
                onPressed: onConfirm, // Panggil callback onConfirm (akan navigasi)
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: redColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(100, 45),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Sure'),
              ),
              // Button "Cancel"
              TextButton(
                onPressed: onCancel, // Panggil callback onCancel (akan melanjutkan timer)
                style: TextButton.styleFrom(
                  foregroundColor: primaryPurple,
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: primaryPurple, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(100, 45),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showHoldButtonDialog(BuildContext context) {
  const primaryPurple = Color(0xFF6A1B9A);
  
  showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true, 
    barrierColor: Colors.black54.withOpacity(0.01), 
    barrierLabel: 'Dismiss',
    transitionDuration: const Duration(milliseconds: 200),
    
    // PositionedTransition untuk animasi slide-up (opsional, tapi bagus untuk popover)
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1, // Animasi opacity dari anim1
        child: child,
      );
    },

    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.center, // Pusatkan Align
        child: Padding(
          // Posisikan popover sedikit di atas tengah layar (di atas tombol SOS)
          // Sesuaikan nilai 'bottom' ini jika posisi masih kurang pas
          padding: const EdgeInsets.only(bottom: 200, left: 50, right: 50), 
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Radius sedikit lebih kecil
            elevation: 0, // HILANGKAN SHADOW
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding lebih kecil
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryPurple, width: 1), // KETEBALAN BORDER DIKURANGI
              ),
              child: const Text(
                'Hold the button to make a call',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, // FONT SIZE LEBIH KECIL
                  color: primaryPurple,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
