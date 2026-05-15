import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'savings_target_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import 'reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const ProfileScreen({Key? key, required this.transactions}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double get totalIncome => widget.transactions
      .where((tx) => tx.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => widget.transactions
      .where((tx) => !tx.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpense;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  ImageProvider _getProfileImage(String photoPath) {
    if (photoPath.startsWith('http')) {
      return NetworkImage(photoPath);
    } else {
      return FileImage(File(photoPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: _buildHeader(userProvider),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildBalanceCard(),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Pengaturan Akun'),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profil',
                        subtitle: 'Nama, email, dan foto',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        ),
                      ),
                      _buildMenuToggle(
                        icon: Icons.dark_mode_outlined,
                        title: 'Mode Gelap',
                        value: themeProvider.isDarkMode,
                        onChanged: (val) => themeProvider.toggleTheme(val),
                      ),
                      _buildMenuToggle(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi Transaksi',
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (val) => settingsProvider.toggleNotifications(val),
                      ),
                      _buildMenuItem(
                        icon: Icons.security_outlined,
                        title: 'Keamanan',
                        subtitle: 'PIN dan Biometrik',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SecurityScreen()),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Keuangan'),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.track_changes_rounded,
                        title: 'Target Tabungan',
                        subtitle: 'Atur impian masa depan',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SavingsTargetScreen()),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.pie_chart_outline_rounded,
                        title: 'Statistik Transaksi',
                        subtitle: 'Analisis pengeluaran bulanan',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReportsScreen(transactions: widget.transactions)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Lainnya'),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Aplikasi',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: _buildLogoutButton(userProvider),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProvider user) {
    return Row(
      children: [
        Hero(
          tag: 'profile_photo',
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _getProfileImage(user.profilePhoto),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            ),
            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo Anda',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(balance),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat(
                label: 'Pemasukan',
                amount: totalIncome,
                icon: Icons.arrow_downward_rounded,
                color: Colors.white,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildMiniStat(
                label: 'Pengeluaran',
                amount: totalExpense,
                icon: Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyFormat.format(amount),
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx < children.length - 1)
                Divider(height: 1, indent: 56, endIndent: 16, color: Colors.black.withOpacity(0.05)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
    );
  }

  Widget _buildMenuToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildLogoutButton(UserProvider user) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context, user),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.expenseColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.logout_rounded, color: AppTheme.expenseColor, size: 20),
        label: Text(
          'Keluar Akun',
          style: GoogleFonts.outfit(
            color: AppTheme.expenseColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun MoneyTrack?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await user.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }
}
