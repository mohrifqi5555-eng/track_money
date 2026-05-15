import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildInfoCard(context),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Autentikasi'),
            const SizedBox(height: 12),
            FadeInUp(
              child: _buildSecurityItem(
                context,
                icon: Icons.fingerprint_rounded,
                title: 'Biometrik / Fingerprint',
                subtitle: 'Gunakan sidik jari untuk masuk',
                trailing: Switch.adaptive(
                  value: settings.biometricEnabled,
                  onChanged: (val) async {
                    bool success = await settings.toggleBiometric(val);
                    if (!success && val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal mengaktifkan biometrik. Pastikan perangkat mendukung dan sidik jari sudah terdaftar.'),
                          backgroundColor: AppTheme.expenseColor,
                        ),
                      );
                    }
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildSecurityItem(
                context,
                icon: Icons.pin_rounded,
                title: 'PIN Aplikasi',
                subtitle: settings.pin.isEmpty ? 'Belum diatur' : 'Sudah diatur (4 digit)',
                onTap: () => _showPinSetupDialog(context, settings),
              ),
            ),
            if (settings.pin.isNotEmpty) ...[
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: TextButton.icon(
                  onPressed: () => settings.setPin(''),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Hapus PIN'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.expenseColor),
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Sesi Aktif'),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildSecurityItem(
                context,
                icon: Icons.devices_rounded,
                title: 'Perangkat Terhubung',
                subtitle: 'Android SDK 34 - Aktif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: AppTheme.primaryColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keamanan Akun',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'Pastikan akun Anda aman dengan mengaktifkan fitur autentikasi.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSecurityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      ),
    );
  }

  void _showPinSetupDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur PIN Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan 4 digit PIN untuk mengamankan aplikasi.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              style: const TextStyle(letterSpacing: 20, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                settings.setPin(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN berhasil disimpan'), backgroundColor: AppTheme.primaryColor),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
