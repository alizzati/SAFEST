// widgets/card_audio.dart
import 'package:flutter/material.dart';
import 'package:safest/data/sound_data.dart';

class AudioCard extends StatelessWidget {
  final SoundItem soundItem;
  final bool isPlaying;
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;
  final int index;

  const AudioCard({
    Key? key,
    required this.soundItem,
    required this.isPlaying,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.38,
        margin: EdgeInsets.only(
          right: screenWidth * 0.02,
          left: index == 0 ? 0 : screenWidth * 0.01,
        ),
        decoration: BoxDecoration(
          color: isPlaying
              ? const Color(0xFF512DAB).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isPlaying ? const Color(0xFF512DAB) : Colors.grey[200]!,
            width: isPlaying ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Konten teks
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    soundItem.text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.034,
                      color: const Color(0xFF512DAB),
                      fontWeight:
                          isPlaying ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Icon speaker di pojok kanan bawah
            Positioned(
              bottom: screenWidth * 0.01,
              right: screenWidth * 0.01,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? const Color(0xFF512DAB)
                        : const Color(0xFF512DAB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.01),
                  ),
                  child: Icon(
                    isPlaying ? Icons.stop : Icons.volume_up,
                    color: isPlaying ? Colors.white : const Color(0xFF512DAB),
                    size: screenWidth * 0.035,
                  ),
                ),
              ),
            ),

            // Indicator playing di pojok kiri atas
            if (isPlaying)
              Positioned(
                top: screenWidth * 0.01,
                left: screenWidth * 0.01,
                child: Container(
                  width: screenWidth * 0.02,
                  height: screenWidth * 0.02,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
