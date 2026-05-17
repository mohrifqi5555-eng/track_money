import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/account.dart';

class AuthProvider with ChangeNotifier {
  List<Account> _accounts = [];
  Account? _currentAccount;
  bool _isLoading = true;

  List<Account> get accounts => _accounts;
  Account? get currentAccount => _currentAccount;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentAccount != null;

  AuthProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsStr = prefs.getString('accounts');
      if (accountsStr != null) {
        final List<dynamic> decoded = jsonDecode(accountsStr);
        _accounts = decoded.map((e) => Account.fromMap(e)).toList();
      }

      final rememberLogin = prefs.getBool('remember_login') ?? false;
      if (rememberLogin) {
        final currentId = prefs.getString('current_account_id');
        if (currentId != null) {
          _currentAccount = _accounts.firstWhere(
            (acc) => acc.id == currentId,
            orElse: () => throw Exception('Account not found'),
          );
        }
      } else {
        _currentAccount = null;
      }
    } catch (e) {
      _currentAccount = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData({bool? rememberLoginOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsStr = jsonEncode(_accounts.map((e) => e.toMap()).toList());
    await prefs.setString('accounts', accountsStr);
    
    final rememberLogin = rememberLoginOverride ?? prefs.getBool('remember_login') ?? false;
    await prefs.setBool('remember_login', rememberLogin);
    
    if (_currentAccount != null && rememberLogin) {
      await prefs.setString('current_account_id', _currentAccount!.id);
    } else {
      await prefs.remove('current_account_id');
    }
  }

  Future<String?> register(String username, String email, String password, {bool rememberMe = true}) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanUsername = username.trim();
    
    if (cleanUsername.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (cleanEmail.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Format email tidak valid';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    if (_accounts.any((acc) => acc.email.toLowerCase() == cleanEmail)) {
      return 'Email sudah terdaftar';
    }

    final newAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: cleanUsername,
      email: cleanEmail,
      password: password,
      profilePhoto: 'https://i.pravatar.cc/150?u=$cleanEmail',
    );

    _accounts.add(newAccount);
    _currentAccount = newAccount;
    await _saveData(rememberLoginOverride: rememberMe);
    notifyListeners();
    return null; // success
  }

  Future<String?> login(String email, String password, {bool rememberMe = true}) async {
    final cleanEmail = email.trim().toLowerCase();
    
    if (cleanEmail.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (password.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    try {
      final account = _accounts.firstWhere(
        (acc) => acc.email.toLowerCase() == cleanEmail,
      );
      if (account.password == password) {
        _currentAccount = account;
        await _saveData(rememberLoginOverride: rememberMe);
        notifyListeners();
        return null; // success
      } else {
        return 'Password salah';
      }
    } catch (e) {
      return 'Email tidak ditemukan';
    }
  }

  Future<void> switchAccount(String id) async {
    try {
      _currentAccount = _accounts.firstWhere((acc) => acc.id == id);
      await _saveData(rememberLoginOverride: true); // Remember switched account
      notifyListeners();
    } catch (e) {
      // account not found
    }
  }

  Future<void> logout() async {
    _currentAccount = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_login', false);
    await prefs.remove('current_account_id');
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Remove account from list
    _accounts.removeWhere((acc) => acc.id == id);
    
    // 2. Clear all isolated data
    await prefs.remove('transactions_$id');
    await prefs.remove('savings_targets_$id');
    await prefs.remove('${id}_notificationsEnabled');
    await prefs.remove('${id}_biometricEnabled');
    await prefs.remove('${id}_pin');
    
    // 3. If it is the current active account, perform logout
    if (_currentAccount?.id == id) {
      _currentAccount = null;
      await prefs.setBool('remember_login', false);
      await prefs.remove('current_account_id');
    }
    
    // 4. Save updated accounts list
    final accountsStr = jsonEncode(_accounts.map((e) => e.toMap()).toList());
    await prefs.setString('accounts', accountsStr);
    
    notifyListeners();
  }

  Future<void> updateProfile(String username, String email, String photo) async {
    if (_currentAccount != null) {
      _currentAccount!.username = username.trim();
      _currentAccount!.email = email.trim().toLowerCase();
      _currentAccount!.profilePhoto = photo;
      
      // Update account inside the global list
      final idx = _accounts.indexWhere((acc) => acc.id == _currentAccount!.id);
      if (idx != -1) {
        _accounts[idx] = _currentAccount!;
      }
      
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> updateInitialBalance(double balance) async {
    if (_currentAccount != null) {
      _currentAccount!.initialBalance = balance;
      
      // Update account inside the global list
      final idx = _accounts.indexWhere((acc) => acc.id == _currentAccount!.id);
      if (idx != -1) {
        _accounts[idx] = _currentAccount!;
      }
      
      await _saveData();
      notifyListeners();
    }
  }

  Future<String> saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }
}
