import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = 'M. Rifqi';
  String _email = 'rifqi@example.com';
  String _profilePhoto = 'https://i.pravatar.cc/150?u=moneytrack';

  String get name => _name;
  String get email => _email;
  String get profilePhoto => _profilePhoto;

  UserProvider() {
    _loadUser();
  }

  void updateUser(String name, String email, String photo) async {
    _name = name;
    _email = email;
    _profilePhoto = photo;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _name);
    prefs.setString('userEmail', _email);
    prefs.setString('userPhoto', _profilePhoto);
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName') ?? 'M. Rifqi';
    _email = prefs.getString('userEmail') ?? 'rifqi@example.com';
    _profilePhoto = prefs.getString('userPhoto') ?? 'https://i.pravatar.cc/150?u=moneytrack';
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Reset local state if needed
    _name = 'M. Rifqi';
    _email = 'rifqi@example.com';
    _profilePhoto = 'https://i.pravatar.cc/150?u=moneytrack';
    notifyListeners();
  }
}
