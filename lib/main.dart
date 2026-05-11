import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:track_money/screens/dashboard_screen.dart';
import 'package:track_money/screens/history_screen.dart';
import 'package:track_money/screens/add_transaction_screen.dart';
import 'package:track_money/theme/app_theme.dart';
import 'package:track_money/models/transaction.dart';

void main() {
  runApp(const MoneyTrackApp());
}

class MoneyTrackApp extends StatelessWidget {
  const MoneyTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoneyTrack',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Transaction> _userTransactions = [
    Transaction(id: 't1', title: 'Monthly Salary', amount: 15000000, isIncome: true, date: DateTime.now().subtract(const Duration(days: 1))),
    Transaction(id: 't2', title: 'Coffee', amount: 45000, isIncome: false, date: DateTime.now()),
    Transaction(id: 't3', title: 'Groceries', amount: 250000, isIncome: false, date: DateTime.now()),
    Transaction(id: 't4', title: 'Freelance Design', amount: 2000000, isIncome: true, date: DateTime.now().subtract(const Duration(days: 2))),
    Transaction(id: 't5', title: 'Internet Bill', amount: 350000, isIncome: false, date: DateTime.now().subtract(const Duration(days: 3))),
  ];

  void _addNewTransaction(String title, double amount, bool isIncome, DateTime date) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      isIncome: isIncome,
      date: date,
    );

    setState(() {
      _userTransactions.insert(0, newTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(transactions: _userTransactions),
      HistoryScreen(transactions: _userTransactions, deleteTx: _deleteTransaction),
      const Center(child: Text('Reports Coming Soon', style: TextStyle(fontWeight: FontWeight.bold))),
      const Center(child: Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold))),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(addTx: _addNewTransaction),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        elevation: 8,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
