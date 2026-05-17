import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_target.dart';

class SavingsProvider with ChangeNotifier {
  List<SavingsTarget> _targets = [];
  bool _isLoading = false;
  String? _accountId;

  List<SavingsTarget> get targets => _targets;
  bool get isLoading => _isLoading;

  void updateAccountId(String? accountId) {
    if (_accountId != accountId) {
      _accountId = accountId;
      _loadTargets();
    }
  }

  Future<void> addTarget(SavingsTarget target) async {
    _targets.add(target);
    notifyListeners();
    await _saveTargets();
  }

  Future<void> updateTarget(SavingsTarget updatedTarget) async {
    final index = _targets.indexWhere((t) => t.id == updatedTarget.id);
    if (index != -1) {
      _targets[index] = updatedTarget;
      notifyListeners();
      await _saveTargets();
    }
  }

  Future<void> deleteTarget(String id) async {
    _targets.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTargets();
  }

  Future<void> _saveTargets() async {
    if (_accountId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_targets.map((t) => t.toMap()).toList());
    await prefs.setString('savings_targets_$_accountId', encodedData);
  }

  Future<void> _loadTargets() async {
    if (_accountId == null) {
      _targets = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('savings_targets_$_accountId');
    
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _targets = decodedData.map((item) => SavingsTarget.fromMap(item)).toList();
    } else {
      // Mock initial data if empty
      _targets = [
        SavingsTarget(id: '1', title: 'MacBook Pro', targetAmount: 25000000, currentAmount: 15000000, icon: Icons.laptop_mac_rounded),
        SavingsTarget(id: '2', title: 'Liburan Jepang', targetAmount: 15000000, currentAmount: 3000000, icon: Icons.flight_takeoff_rounded),
      ];
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
