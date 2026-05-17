import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SettingsProvider with ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();
  
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _pin = '';
  bool _isLocked = false;
  String? _accountId;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;
  String get pin => _pin;
  bool get isLocked => _isLocked;

  void updateAccountId(String? accountId) {
    if (_accountId != accountId) {
      _accountId = accountId;
      _loadSettings();
    }
  }

  void toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    if (_accountId == null) return;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('${_accountId}_notificationsEnabled', _notificationsEnabled);
  }

  Future<bool> toggleBiometric(bool value) async {
    if (value) {
      // Check if biometric is available
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();
      
      if (!canAuthenticateWithBiometrics || !isDeviceSupported) {
        return false;
      }
      
      // Try to authenticate once to verify it works
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Konfirmasi untuk mengaktifkan Biometrik',
          biometricOnly: true,
        );
        
        if (!didAuthenticate) return false;
      } catch (e) {
        return false;
      }
    }

    _biometricEnabled = value;
    notifyListeners();
    if (_accountId == null) return true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('${_accountId}_biometricEnabled', _biometricEnabled);
    return true;
  }

  void setPin(String value) async {
    _pin = value;
    notifyListeners();
    if (_accountId == null) return;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${_accountId}_pin', _pin);
  }

  void setLocked(bool value) {
    _isLocked = value;
    notifyListeners();
  }

  Future<bool> authenticateBiometric() async {
    try {
      // Removing stickyAuth parameter which caused errors
      return await auth.authenticate(
        localizedReason: 'Silakan verifikasi identitas Anda',
      );
    } catch (e) {
      return false;
    }
  }

  void _loadSettings() async {
    if (_accountId == null) {
      _notificationsEnabled = true;
      _biometricEnabled = false;
      _pin = '';
      _isLocked = false;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('${_accountId}_notificationsEnabled') ?? true;
    _biometricEnabled = prefs.getBool('${_accountId}_biometricEnabled') ?? false;
    _pin = prefs.getString('${_accountId}_pin') ?? '';
    
    // Lock the app on start if PIN or Biometric is enabled
    if (_pin.isNotEmpty || _biometricEnabled) {
      _isLocked = true;
    } else {
      _isLocked = false;
    }
    
    notifyListeners();
  }
}
