import 'dart:io';
import 'package:flutter/material.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  AuthProvider? _authProvider;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  String get name => _authProvider?.currentAccount?.username ?? 'M. Rifqi';
  String get email => _authProvider?.currentAccount?.email ?? 'rifqi@example.com';
  String get profilePhoto => _authProvider?.currentAccount?.profilePhoto ?? 'https://i.pravatar.cc/150?u=moneytrack';
  double get initialBalance => _authProvider?.currentAccount?.initialBalance ?? 0.0;

  Future<void> updateUser(String name, String email, String photo) async {
    if (_authProvider != null) {
      await _authProvider!.updateProfile(name, email, photo);
      notifyListeners();
    }
  }

  Future<void> updateInitialBalance(double balance) async {
    if (_authProvider != null) {
      await _authProvider!.updateInitialBalance(balance);
      notifyListeners();
    }
  }

  Future<String> saveImageLocally(File imageFile) async {
    if (_authProvider != null) {
      return await _authProvider!.saveImageLocally(imageFile);
    }
    return '';
  }

  Future<void> logout() async {
    if (_authProvider != null) {
      await _authProvider!.logout();
      notifyListeners();
    }
  }
}
