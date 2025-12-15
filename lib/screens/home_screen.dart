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
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Notifikasi Plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String? _currentlyPlayingCardId;
  bool _isSirenePlaying = false; 
  Position? _currentPosition; // Variabel ini sekarang akan sinkron
  
  final Color _purpleColor = const Color(0xFF512DAB);
  final Color _redColor = const Color(0xFFC62828);
  final Color _greenColor = const Color(0xFF4CAF50);

  LatLng? _currentLocation;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Inisialisasi notifikasi
    _getCurrentLocation();

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _getCurrentLocation();
    });
  }

  // --- 1. INISIALISASI NOTIFIKASI ---
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Pastikan icon ada

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // --- 2. MENAMPILKAN NOTIFIKASI ---
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'share_location_channel', // Channel ID
      'Live Location Sharing',  // Channel Name
      channelDescription: 'Notifications for live location sharing',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF512DAB),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Live Location Active', // Title (Sesuai gambar: Warning S.O.S Alert!)
      'Your live location is currently being shared with selected contacts.', // Body
      notificationDetails,
    );
  }

  // --- 3. PERBAIKAN LOGIKA LOKASI ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationEnabled = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationEnabled = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationEnabled = false);
      return;
    }

    // Ambil lokasi
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        // Update KEDUA variabel agar sinkron
        _currentPosition = position; 
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
      });
    }
  }

  // --- 4. LOGIKA SHARE LOCATION YANG DIPERBAIKI ---
  void _shareCurrentLocation() async {
    // Cek ketersediaan lokasi
    if (_currentPosition == null && _currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mencari lokasi... Harap tunggu.')),
      );
      await _getCurrentLocation(); // Coba paksa update
      return;
    }

    // Gunakan data yang tersedia
    final lat = _currentPosition?.latitude ?? _currentLocation!.latitude;
    final lon = _currentPosition?.longitude ?? _currentLocation!.longitude;
    
    // Link Google Maps yang valid
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    
    final textToShare = '🚨 EMERGENCY ALERT 🚨\n\nSaya sedang dalam situasi darurat. Berikut adalah lokasi terkini saya:\n$mapsUrl';

    try {
      // Share UI
      await Share.share(textToShare);
      
      // Tampilkan Notifikasi Berhasil
      _showNotification();
      
    } catch (e) {
      print("Error sharing location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal berbagi lokasi.')),
      );
    }
  }

  void _playCardAudio(SoundItem soundItem) async {
    try {
      if (_currentlyPlayingCardId == soundItem.id) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingCardId = null;
        });
      } else {
        await _audioPlayer.stop();
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

  void _playSirene({required bool shouldPlay}) async {
    try {
      if (shouldPlay) {
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource(SoundData.sireneSound.audioPath));
        setState(() {
          _isSirenePlaying = true;
          _currentlyPlayingCardId = null;
        });
        print('🚨 Sirene activated!');
        
        if (mounted) {
          _showTurnOffSireneDialog();
        }

      } else {
        await _audioPlayer.stop();
        setState(() {
          _isSirenePlaying = false;
          _currentlyPlayingCardId = null;
        });
        print('🔇 Sirene stopped');
      }
    } catch (e) {
      print('❌ Error playing sirene: $e');
    }
  }

  void _handleSireneButtonPress() {
    if (_isSirenePlaying) {
      _showTurnOffSireneDialog();
    } else {
      _showActivateSireneDialog();
    }
  }

  void _showActivateSireneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.all(30),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Activate\nEmergency Siren?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _purpleColor,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _redColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup dialog konfirmasi
                      _playSirene(shouldPlay: true); // Mulai sirene dan otomatis buka dialog Turn Off
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _greenColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Activate Siren', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTurnOffSireneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.all(30),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/sirene.png', height: 80),
              const SizedBox(height: 10),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog Turn Off
                  _playSirene(shouldPlay: false); // Matikan sirene
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _redColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Turn Off Siren', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
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
                  decoration: const BoxDecoration(),
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
                            iconColor: _purpleColor,
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
                            iconColor: _purpleColor,
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
                            const Expanded(child: SizedBox()),
                            Container(
                              width: screenWidth * 0.1,
                              child: const SizedBox(),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            const Expanded(flex: 2, child: SizedBox()),
                            SizedBox(width: screenWidth * 0.03),
                            ButtonCircle(
                              size: screenWidth * 0.13,
                              color: Colors.white,
                              icon: Icons.notifications,
                              iconColor: _purpleColor,
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
                  // Button Sirene (atas) - MENGGUNAKAN LOGIC POP-UP BARU
                  ButtonCircle(
                    size: screenWidth * 0.14,
                    color: Colors.white,
                    assetImage: 'assets/images/sirene.png',
                    iconColor: _isSirenePlaying ? Colors.white : null,
                    isActive: _isSirenePlaying,
                    activeColor: _redColor,
                    onPressed: _handleSireneButtonPress, // Panggil handler baru
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Button Share Location (bawah)
                  ButtonCircle(
                    size: screenWidth * 0.14,
                    color: Colors.white,
                    assetImage: 'assets/images/share_loc.png',
                    onPressed: () {
                      _shareCurrentLocation();
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
              child: SizedBox(
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