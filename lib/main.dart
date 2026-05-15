import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:track_money/screens/dashboard_screen.dart';
import 'package:track_money/screens/history_screen.dart';
import 'package:track_money/screens/add_transaction_screen.dart';
import 'package:track_money/theme/app_theme.dart';
import 'package:track_money/models/transaction.dart';
import 'package:track_money/screens/reports_screen.dart';
import 'package:track_money/screens/profile_screen.dart';
import 'package:track_money/providers/theme_provider.dart';
import 'package:track_money/providers/user_provider.dart';
import 'package:track_money/providers/settings_provider.dart';
import 'package:track_money/providers/savings_provider.dart';
import 'package:track_money/screens/lock_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:track_money/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
      ],
      child: const MoneyTrackApp(),
    ),
  );
}

class MoneyTrackApp extends StatelessWidget {
  const MoneyTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoneyTrack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: settingsProvider.isLocked ? const LockScreen() : const MainScreen(),
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

    NotificationService().showNotification(
      title: isIncome ? 'Pemasukan Berhasil' : 'Pengeluaran Berhasil',
      body: 'Transaksi "$title" sebesar Rp ${amount.toInt()} telah dicatat.',
      type: 'transaction',
    );

    if (!isIncome && amount >= 1000000) {
      NotificationService().showNotification(
        title: 'Pengeluaran Besar!',
        body: 'Anda baru saja mencatat pengeluaran sebesar Rp ${amount.toInt()}. Tetap pantau budget Anda!',
        type: 'alert',
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
      ProfileScreen(transactions: _userTransactions),
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
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light 
                ? const Color(0x08000000) 
                : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardTheme.color,
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
