// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:safest/widgets/home/card_audio.dart';
import 'package:safest/data/sound_data.dart';
import 'package:safest/widgets/home/button_circle.dart';
import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingCardId;
  bool _isSirenePlaying = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // 🔁 Update lokasi setiap 2 detik sekali
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Panggil ulang fungsi lokasi
      await _getCurrentLocation();
    });
  }

  LatLng? _currentLocation;
  bool _locationEnabled = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationEnabled = false);
      return;
    }

    // Periksa dan minta izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationEnabled = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationEnabled = false);
      return;
    }

    // Ambil lokasi sekarang
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationEnabled = true;
    });
  }

  void _playCardAudio(SoundItem soundItem) async {
    try {
      if (_currentlyPlayingCardId == soundItem.id) {
        // Jika card yang sama diklik, stop audio
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingCardId = null;
        });
      } else {
        // Stop semua audio yang sedang berjalan
        await _audioPlayer.stop();

        // Play audio baru menggunakan AssetSource
        await _audioPlayer.play(AssetSource(soundItem.audioPath));

        setState(() {
          _currentlyPlayingCardId = soundItem.id;
          _isSirenePlaying = false;
        });

        print('🔊 Playing: ${soundItem.text}');
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  void _playSirene() async {
    try {
      if (_isSirenePlaying) {
        // Jika sirene sedang berjalan, stop
        await _audioPlayer.stop();
        setState(() {
          _isSirenePlaying = false;
          _currentlyPlayingCardId = null;
        });
        print('🔇 Sirene stopped');
      } else {
        // Stop semua audio yang sedang berjalan
        await _audioPlayer.stop();

        // Play suara sirene
        await _audioPlayer.play(AssetSource(SoundData.sireneSound.audioPath));

        setState(() {
          _isSirenePlaying = true;
          _currentlyPlayingCardId = null;
        });

        print('🚨 Sirene activated!');
      }
    } catch (e) {
      print('❌ Error playing sirene: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            // ==== PETA FULL SCREEN ====
            _currentLocation == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          _locationEnabled
                              ? 'Getting location...'
                              : 'Enable location to display the map',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60,
                            height: 60,
                            point: _currentLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            Column(
              children: [
                // Custom Header dengan jarak dari batas atas
                Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.03,
                    left: screenWidth * 0.06,
                    right: screenWidth * 0.06,
                    bottom: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(),
                  child: Column(
                    children: [
                      // Baris pertama: Menu icon, Search, dan Profile icon
                      Row(
                        children: [
                          // Menu icon (kiri)
                          ButtonCircle(
                            size: screenWidth * 0.13,
                            color: Colors.white,
                            icon: Icons.refresh,
                            iconColor: const Color(0xFF512DAB),
                            onPressed: () async {
                              // Tampilkan indikator loading singkat
                              setState(() {
                                _currentLocation = null;
                                _locationEnabled = false;
                              });

                              // Ambil lokasi terbaru dan refresh tampilan
                              await _getCurrentLocation();

                              // Opsi tambahan: stop audio yang sedang diputar
                              await _audioPlayer.stop();
                              setState(() {
                                _isSirenePlaying = false;
                                _currentlyPlayingCardId = null;
                              });

                              print('🔄 Halaman Home di-refresh');
                            },
                            shadowColor: Colors.black.withOpacity(0.1),
                          ),

                          // Search bar (tengah)
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              height: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: screenWidth * 0.03),
                                  Icon(
                                    Icons.search,
                                    color: Colors.grey[600],
                                    size: screenWidth * 0.05,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      textAlignVertical: TextAlignVertical
                                          .center, // 🔹 Rata tengah vertikal
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        border: InputBorder.none,
                                        isDense:
                                            true, // 🔹 Mengurangi tinggi ekstra
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical:
                                              screenHeight *
                                              0.01, // sesuaikan agar pas
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Profile icon (kanan)
                          ButtonCircle(
                            size: screenWidth * 0.13,
                            color: Colors.white,
                            icon: Icons.person,
                            iconColor: const Color(0xFF512DAB),
                            onPressed: () {
                              context.push(AppRoutes.profile);
                            },

                            shadowColor: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // Baris kedua: Notification icon tepat di bawah profile
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Container(
                              width: screenWidth * 0.1,
                              child: SizedBox(),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(flex: 2, child: SizedBox()),
                            SizedBox(width: screenWidth * 0.03),
                            ButtonCircle(
                              size: screenWidth * 0.13,
                              color: Colors.white,
                              icon: Icons.notifications,
                              iconColor: const Color(0xFF512DAB),
                              onPressed: () {
                                // Handle menu button press
                              },
                              shadowColor: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Button Sirene dan Share Location di sebelah kiri
            Positioned(
              left: screenWidth * 0.04,
              top: screenHeight * 0.4,
              child: Column(
                children: [
                  // Button Sirene (atas) - dengan efek visual ketika aktif
                  ButtonCircle(
                    size: screenWidth * 0.14,
                    color: Colors.white,
                    assetImage: 'assets/images/sirene.png',
                    iconColor: _isSirenePlaying ? Colors.white : null,
                    isActive: _isSirenePlaying,
                    activeColor: Colors.red,
                    onPressed: _playSirene,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Button Share Location (bawah)
                  ButtonCircle(
                    size: screenWidth * 0.14,
                    color: Colors.white,
                    assetImage: 'assets/images/share_loc.png',
                    onPressed: () {
                      print('Share location button pressed');
                    },
                  ),
                ],
              ),
            ),

            // Horizontal Scroll Cards tepat di atas tombol SOS
            Positioned(
              bottom: screenHeight * 0.20,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.12,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: SoundData.emergencySounds.length,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  itemBuilder: (context, index) {
                    final soundItem = SoundData.emergencySounds[index];
                    return AudioCard(
                      soundItem: soundItem,
                      isPlaying: _currentlyPlayingCardId == soundItem.id,
                      onTap: () => _playCardAudio(soundItem),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      index: index,
                    );
                  },
                ),
              ),
            ),

            // Indicator sirene aktif (opsional)
          ],
        ),
      ),
    );
  }
}
