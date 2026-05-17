import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  String? _accountId;

  List<Transaction> get transactions => _transactions;

  void updateAccountId(String? accountId) {
    if (_accountId != accountId) {
      _accountId = accountId;
      _loadTransactions();
    }
  }

  Future<void> addTransaction(Transaction tx) async {
    _transactions.insert(0, tx);
    notifyListeners();
    await _saveTransactions();
  }

  Future<void> updateTransaction(Transaction updatedTx) async {
    final index = _transactions.indexWhere((tx) => tx.id == updatedTx.id);
    if (index != -1) {
      _transactions[index] = updatedTx;
      notifyListeners();
      await _saveTransactions();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
    await _saveTransactions();
  }

  Future<void> _saveTransactions() async {
    if (_accountId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_transactions.map((tx) => tx.toMap()).toList());
    await prefs.setString('transactions_$_accountId', encodedData);
  }

  Future<void> _loadTransactions() async {
    if (_accountId == null) {
      _transactions = [];
      notifyListeners();
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('transactions_$_accountId');
    
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _transactions = decodedData.map((item) => Transaction.fromMap(item)).toList();
    } else {
      _transactions = [];
    }
    notifyListeners();
  }
}
