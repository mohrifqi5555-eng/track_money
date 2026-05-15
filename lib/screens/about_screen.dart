import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                child: Text(
                  'MoneyTrack',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Versi 1.0.0',
                  style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'MoneyTrack adalah aplikasi pengelola keuangan cerdas yang membantu Anda mencatat transaksi, memantau pengeluaran, dan mencapai target tabungan dengan mudah dan aman.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 15, height: 1.5, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    Text(
                      'Dikembangkan oleh',
                      style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Antigravity Dev Team',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
