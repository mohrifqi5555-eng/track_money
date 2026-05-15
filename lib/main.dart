import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:track_money/screens/dashboard_screen.dart';
import 'package:track_money/screens/history_screen.dart';
import 'package:track_money/screens/add_transaction_screen.dart';
import 'package:track_money/theme/app_theme.dart';
import 'package:track_money/models/transaction.dart';
import 'package:track_money/screens/reports_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:track_money/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  await NotificationService().init();
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
    Transaction(id: 't1', title: 'Gaji Bulanan', amount: 15000000, isIncome: true, date: DateTime.now().subtract(const Duration(days: 1))),
    Transaction(id: 't2', title: 'Kopi', amount: 45000, isIncome: false, date: DateTime.now()),
    Transaction(id: 't3', title: 'Belanja Harian', amount: 250000, isIncome: false, date: DateTime.now()),
    Transaction(id: 't4', title: 'Desain Freelance', amount: 2000000, isIncome: true, date: DateTime.now().subtract(const Duration(days: 2))),
    Transaction(id: 't5', title: 'Tagihan Internet', amount: 350000, isIncome: false, date: DateTime.now().subtract(const Duration(days: 3))),
  ];
  // stray entries removed

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

    // 1. Notifikasi transaksi baru
    NotificationService().showNotification(
      title: isIncome ? 'Pemasukan Berhasil' : 'Pengeluaran Berhasil',
      body: 'Transaksi "$title" sebesar Rp ${amount.toInt()} telah dicatat.',
      type: 'transaction',
    );

    // 2. Notifikasi pengeluaran besar (misal > 1.000.000)
    if (!isIncome && amount >= 1000000) {
      NotificationService().showNotification(
        title: 'Pengeluaran Besar!',
        body: 'Anda baru saja mencatat pengeluaran sebesar Rp ${amount.toInt()}. Tetap pantau budget Anda!',
        type: 'alert',
      );
    }

    // Hitung total untuk budget & tabungan
    double totalInc = _userTransactions.where((tx) => tx.isIncome).fold(0, (sum, item) => sum + item.amount);
    double totalExp = _userTransactions.where((tx) => !tx.isIncome).fold(0, (sum, item) => sum + item.amount);
    double balance = totalInc - totalExp;

    // 3. Notifikasi budget hampir habis (misal balance < 10% dari income)
    if (totalInc > 0 && balance < (totalInc * 0.1) && !isIncome) {
      NotificationService().showNotification(
        title: 'Budget Menipis',
        body: 'Saldo Anda tersisa Rp ${balance.toInt()}. Hati-hati dalam pengeluaran berikutnya.',
        type: 'budget',
      );
    }

    // 4. Notifikasi target tabungan tercapai (misal target = 30% dari income)
    double savingsTarget = totalInc * 0.3;
    if (totalInc > 0 && balance >= savingsTarget && isIncome) {
       NotificationService().showNotification(
        title: 'Target Tabungan Tercapai!',
        body: 'Selamat! Tabungan Anda telah mencapai target 30% dari total pemasukan.',
        type: 'saving',
      );
    }
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
      ReportsScreen(transactions: _userTransactions),
      const Center(child: Text('Pengaturan Profil', style: TextStyle(fontWeight: FontWeight.bold))),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: SizedBox(
        height: 56,
        width: 56,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(addTx: _addNewTransaction),
              ),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000), // black 3%
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: const Color(0xFF94A3B8),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
