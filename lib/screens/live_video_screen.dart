import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:safest/config/routes.dart';

class LiveVideoScreen extends StatefulWidget {
  const LiveVideoScreen({Key? key}) : super(key: key);

  @override
  _LiveVideoScreenState createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
  final Color _purpleColor = const Color(0xFF512DAB);
  final Color _redColor = const Color(0xFFC62828);

  LatLng? _currentLocation;
  String _currentAddress = 'Getting location...';
  Timer? _locationTimer;
  int _duration = 0;
  Timer? _durationTimer;
  bool _isRecording = true;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  late Timer _imageTimer;
  String? _currentImageUrl =
      'http://ummuhafidzah.sch.id/safest/uploads/esp32-cam.jpg';
  String _imageUrl = 'http://ummuhafidzah.sch.id/safest/uploads/esp32-cam.jpg';
  late Timer _timer;
  int _numEmergencyContacts = 0;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadEmergencyContacts();
    // Update lokasi setiap 2 detik
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _getCurrentLocation();
    });

    // Update durasi video setiap detik
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRecording) {
        timer.cancel();
        return;
      }
      setState(() {
        _duration++;
      });
    });

    // Update gambar setiap 2 detik
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;

      final newUrl =
          'http://ummuhafidzah.sch.id/safest/uploads/esp32-cam.jpg?t=${DateTime.now().millisecondsSinceEpoch}';

      await precacheImage(NetworkImage(newUrl), context);

      if (mounted) {
        setState(() {
          _currentImageUrl = newUrl;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = 'Location service disabled';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = 'Location permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = 'Location permission denied forever';
      });
      return;
    }

    try {
      // Ambil posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Buat GeoPoint untuk Firestore
      GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'position': geoPoint});
      }

      // Update state lokal jika perlu
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Ambil alamat dari Nominatim API jika perlu
      await _getAddressFromNominatim(position.latitude, position.longitude);
    } catch (e) {
      print('❌ Error getting position: $e');
      setState(() {
        _currentAddress = 'Error getting location';
      });
    }
  }

  // Method untuk reverse geocoding menggunakan Nominatim API (OpenStreetMap)
  // Method untuk reverse geocoding menggunakan Nominatim API (OpenStreetMap)
  // Method untuk reverse geocoding menggunakan Nominatim API (OpenStreetMap)
  Future<void> _getAddressFromNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SafestApp/1.0', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('📍 Nominatim Response: $data'); // Debug print

        if (data['address'] != null) {
          final address = data['address'];

          // Buat format alamat dengan prioritas nama jalan
          List<String> addressParts = [];

          // PRIORITAS UTAMA: Ambil nama jalan/road
          if (address['road'] != null &&
              address['road'].toString().isNotEmpty) {
            addressParts.add(address['road']);
          } else if (address['street'] != null &&
              address['street'].toString().isNotEmpty) {
            addressParts.add(address['street']);
          } else if (address['pedestrian'] != null &&
              address['pedestrian'].toString().isNotEmpty) {
            addressParts.add(address['pedestrian']);
          } else if (address['footway'] != null &&
              address['footway'].toString().isNotEmpty) {
            addressParts.add(address['footway']);
          } else if (address['path'] != null &&
              address['path'].toString().isNotEmpty) {
            addressParts.add(address['path']);
          }

          // Tambahkan house_number jika ada
          if (address['house_number'] != null &&
              address['house_number'].toString().isNotEmpty) {
            if (addressParts.isNotEmpty) {
              addressParts[0] =
                  'No. ${address['house_number']}, ${addressParts[0]}';
            } else {
              addressParts.add('No. ${address['house_number']}');
            }
          }

          // Tambahkan suburb/neighbourhood untuk konteks lokasi
          if (address['suburb'] != null &&
              address['suburb'].toString().isNotEmpty) {
            addressParts.add(address['suburb']);
          } else if (address['neighbourhood'] != null &&
              address['neighbourhood'].toString().isNotEmpty) {
            addressParts.add(address['neighbourhood']);
          } else if (address['quarter'] != null &&
              address['quarter'].toString().isNotEmpty) {
            addressParts.add(address['quarter']);
          }

          // ✅ TAMBAHKAN CITY_DISTRICT
          if (address['city_district'] != null &&
              address['city_district'].toString().isNotEmpty) {
            addressParts.add(address['city_district']);
          }

          // ✅ TAMBAHKAN CITY
          if (address['city'] != null &&
              address['city'].toString().isNotEmpty) {
            addressParts.add(address['city']);
          } else if (address['town'] != null &&
              address['town'].toString().isNotEmpty) {
            addressParts.add(address['town']);
          } else if (address['village'] != null &&
              address['village'].toString().isNotEmpty) {
            addressParts.add(address['village']);
          } else if (address['municipality'] != null &&
              address['municipality'].toString().isNotEmpty) {
            addressParts.add(address['municipality']);
          }

          // Jika tidak ada nama jalan sama sekali, coba ambil dari amenity atau building
          if (addressParts.isEmpty ||
              (addressParts.length == 1 && addressParts[0].startsWith('No.'))) {
            if (address['amenity'] != null &&
                address['amenity'].toString().isNotEmpty) {
              addressParts.insert(0, address['amenity']);
            } else if (address['building'] != null &&
                address['building'].toString().isNotEmpty) {
              addressParts.insert(0, address['building']);
            } else if (address['shop'] != null &&
                address['shop'].toString().isNotEmpty) {
              addressParts.insert(0, address['shop']);
            }
          }

          // Jika masih kosong, gunakan display_name
          String finalAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : data['display_name'] ?? 'Unknown location';

          // Batasi panjang jika terlalu panjang (maksimal 120 karakter)
          if (finalAddress.length > 120) {
            List<String> parts = finalAddress.split(', ');
            if (parts.length > 4) {
              finalAddress = parts.sublist(0, 4).join(', ');
            }
          }

          setState(() {
            _currentAddress = finalAddress;
          });

          print('📍 Final Address: $finalAddress');
          print(
            '📍 Available keys: ${address.keys.toList()}',
          ); // Debug: lihat semua key yang tersedia
          print('📍 Road: ${address['road']}');
          print('📍 City District: ${address['city_district']}');
          print('📍 City: ${address['city']}');
        } else {
          // Jika tidak ada detail address, gunakan display_name
          String displayName = data['display_name'] ?? 'Unknown location';

          // Ambil hanya bagian penting dari display_name (maksimal 4 bagian)
          List<String> parts = displayName.split(', ');
          String shortAddress = parts.length > 4
              ? parts.sublist(0, 4).join(', ')
              : displayName;

          setState(() {
            _currentAddress = shortAddress;
          });

          print('📍 Display Name: $shortAddress');
        }
      } else {
        print('❌ Nominatim API Error: ${response.statusCode}');
        setState(() {
          _currentAddress =
              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      print('❌ Error getting address from Nominatim: $e');
      setState(() {
        _currentAddress =
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      });
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _durationTimer?.cancel();
    _timer?.cancel();
    _currentImageUrl = null; // <-- reset
    super.dispose();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        final contacts = data['emergencyContacts'] as Map<String, dynamic>?;

        debugPrint('Contacts raw: $contacts');

        setState(() {
          _numEmergencyContacts = contacts?.length ?? 0;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load emergency contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Emergency Video',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: _purpleColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isRecording = false;
                      });

                      // Update isLive menjadi false
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({'isLive': false});
                      }

                      context.go(AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _redColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.012,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: Text(
                      'STOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Card
            Container(
              margin: EdgeInsets.all(screenWidth * 0.04),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: screenWidth * 0.025,
                            height: screenWidth * 0.025,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Video Live Active',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Duration: ${_formatDuration(_duration)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Broadcasting to $_numEmergencyContacts emergency contacts',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Preview Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              height: screenHeight * 0.35,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                child: Stack(
                  children: [
                    // Placeholder untuk video
                    // Ganti bagian ini:
                    _isCameraOn
                        ? Image.network(
                            _currentImageUrl!,
                            key: ValueKey(
                              _currentImageUrl,
                            ), // <-- paksa rebuild
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            gaplessPlayback: true, // penting agar tidak blink
                            filterQuality: FilterQuality.low,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam_off,
                                    color: Colors.white54,
                                    size: 80,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                Icons.videocam_off,
                                size: 80,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                    // Control buttons overlay
                    Positioned(
                      bottom: screenHeight * 0.02,
                      left: screenWidth * 0.04,
                      child: Row(
                        children: [
                          // Mic button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMicOn = !_isMicOn;
                              });
                            },
                            child: Container(
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              decoration: BoxDecoration(
                                color: _isMicOn
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.red.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isMicOn ? Icons.mic : Icons.mic_off,
                                color: _isMicOn ? Colors.black : Colors.white,
                                size: screenWidth * 0.06,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),

                          // Camera button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCameraOn = !_isCameraOn;
                              });
                            },
                            child: Container(
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              decoration: BoxDecoration(
                                color: _isCameraOn
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.red.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isCameraOn
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                color: _isCameraOn
                                    ? Colors.black
                                    : Colors.white,
                                size: screenWidth * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Fullscreen button
                    Positioned(
                      bottom: screenHeight * 0.02,
                      right: screenWidth * 0.04,
                      child: GestureDetector(
                        onTap: () {
                          // Handle fullscreen
                        },
                        child: Container(
                          width: screenWidth * 0.11,
                          height: screenWidth * 0.11,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fullscreen,
                            color: Colors.black,
                            size: screenWidth * 0.06,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Current Location Label
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.orange,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location:',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          _currentAddress,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Map
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  child: _currentLocation == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: _purpleColor),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                _currentAddress,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.035,
                                ),
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
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.15,
                                  point: _currentLocation!,
                                  child: Icon(
                                    Icons.location_pin,
                                    size: screenWidth * 0.1,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Connected Contacts
            Container(
              margin: EdgeInsets.only(
                left: screenWidth * 0.04,
                right: screenWidth * 0.04,
                bottom: screenHeight * 0.02,
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Contacts',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_numEmergencyContacts  emergency contacts watching',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: screenWidth * 0.025,
                        height: screenWidth * 0.025,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Connected',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
