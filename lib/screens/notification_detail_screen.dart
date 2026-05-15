import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // Format nominal jika ada
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final String amountText = notification.amount != null ? currencyFormatter.format(notification.amount) : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Notifikasi', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.expenseColor),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: _buildHeaderCard(context),
              ),
              const SizedBox(height: 24),

              // Info Card
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: _buildInfoCard(context, amountText),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: _buildActionButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'transaction':
        final isIncome = notification.title.toLowerCase().contains('pemasukan');
        icon = isIncome ? Icons.add_chart_rounded : Icons.shopping_cart_checkout_rounded;
        color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
        break;
      case 'alert':
        icon = Icons.warning_rounded;
        color = AppTheme.expenseColor;
        break;
      case 'budget':
        icon = Icons.account_balance_wallet_rounded;
        color = Colors.orange;
        break;
      case 'saving':
        icon = Icons.stars_rounded;
        color = const Color(0xFF6366F1);
        break;
      case 'report':
        icon = Icons.bar_chart_rounded;
        color = Colors.teal;
        break;
      default:
        icon = Icons.notifications_active_rounded;
        color = AppTheme.primaryColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            notification.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (notification.status == 'failed' ? AppTheme.expenseColor : AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  notification.status == 'failed' ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  size: 14,
                  color: notification.status == 'failed' ? AppTheme.expenseColor : AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  notification.status == 'failed' ? 'Gagal' : 'Berhasil',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: notification.status == 'failed' ? AppTheme.expenseColor : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String amountText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Kategori', _getCategoryName(notification.type), Icons.category_outlined),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          _buildInfoRow('Waktu', DateFormat('dd MMM yyyy, HH:mm', 'id').format(notification.timestamp), Icons.access_time_rounded),
          if (amountText.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _buildInfoRow('Nominal', amountText, Icons.payments_outlined, valueColor: AppTheme.textPrimary, isBold: true),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          const Text(
            'Deskripsi Lengkap',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            notification.body,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor, bool isBold = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (!notification.isRead)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                NotificationService().markAsRead(notification.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.mark_email_read_outlined),
              label: const Text('Tandai Sudah Dibaca', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(String type) {
    switch (type) {
      case 'transaction': return 'Transaksi';
      case 'alert': return 'Peringatan';
      case 'budget': return 'Anggaran';
      case 'saving': return 'Tabungan';
      case 'report': return 'Laporan';
      default: return 'Umum';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Notifikasi?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              NotificationService().deleteNotification(notification.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return from detail
            },
            child: const Text('Hapus', style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }
}
