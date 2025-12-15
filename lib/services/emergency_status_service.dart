import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safest/models/emergency_status.dart'; 

class EmergencyStatusService extends ChangeNotifier {
  Timer? _statusTimer;
  int _currentStatusIndex = 0;
  bool _isActive = false;

  final List<EmergencyStatus> _allStatuses = [
    EmergencyStatus(
      text: 'Emergency activated. Your location is being shared with your primary contact.',
      icon: Icons.security,
    ),
    EmergencyStatus(
      text: 'Sending location update to all emergency contacts.',
      icon: Icons.location_on,
    ),
    EmergencyStatus(
      text: 'Call initiated to primary contact.',
      icon: Icons.call,
    ),
  ];

  EmergencyStatus get currentStatus => _allStatuses[_currentStatusIndex];
  bool get isActive => _isActive;

  void startEmergencyStatusLoop() {
    if (_isActive) return;

    _isActive = true;
    _currentStatusIndex = 0;
    notifyListeners();

    _statusTimer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (!_isActive) {
        t.cancel();
        return;
      }
      _currentStatusIndex = (_currentStatusIndex + 1) % _allStatuses.length;
      notifyListeners();
    });
  }

  void stopEmergencyStatusLoop() {
    _statusTimer?.cancel();
    _statusTimer = null;
    _isActive = false;
    _currentStatusIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopEmergencyStatusLoop();
    super.dispose();
  }
}

final emergencyStatusService = EmergencyStatusService();