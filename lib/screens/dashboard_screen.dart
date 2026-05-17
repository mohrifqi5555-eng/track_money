import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';
import '../providers/user_provider.dart';

import '../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  ImageProvider _getProfileImage(String photoPath) {
    if (photoPath.startsWith('http')) {
      return NetworkImage(photoPath);
    } else {
      return FileImage(File(photoPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final totalIncome = transactions.where((tx) => tx.isIncome).fold(0.0, (sum, item) => sum + item.amount);
    final totalExpense = transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, item) => sum + item.amount);
    final totalBalance = userProvider.initialBalance + totalIncome - totalExpense;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: _getProfileImage(userProvider.profilePhoto),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            userProvider.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: NotificationService(),
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () {
                          _showNotificationsBottomSheet(context);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black.withOpacity(0.05)),
                              ),
                              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary, size: 22),
                            ),
                            if (NotificationService().unreadCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.expenseColor,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '${NotificationService().unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Main Balance Card
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26059669), // primaryColor 15%
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Saldo',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: () => _showEditBalanceDialog(context, userProvider),
                          child: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (userProvider.initialBalance == 0 && transactions.isEmpty)
                            ? 'Belum ada saldo'
                            : currencyFormatter.format(totalBalance),
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: (userProvider.initialBalance == 0 && transactions.isEmpty) ? 24 : 36, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF), // white 10%
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildBalanceDetail(
                            label: 'Pemasukan',
                            amount: totalIncome,
                            icon: Icons.south_west_rounded,
                            color: Colors.white,
                          ),
                          Container(
                            width: 1, 
                            height: 30, 
                            color: Colors.white24, 
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          _buildBalanceDetail(
                            label: 'Pengeluaran',
                            amount: totalExpense,
                            icon: Icons.north_east_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Summary Card
            FadeInUp(
              duration: const Duration(milliseconds: 650),
              child: _buildMonthlySummaryCard(context, transactions),
            ),
            const SizedBox(height: 28),

            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua', 
                      style: TextStyle(
                        color: AppTheme.accentColor, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: TransactionTile(transaction: transactions[index]),
                );
              },
            ),
            const SizedBox(height: 100), // Spacing for FAB
          ],
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: NotificationsScreen(scrollController: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryCard(BuildContext context, List<Transaction> transactions) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMM yyyy', 'id').format(now);

    // Pengeluaran hari ini
    final todayExpense = transactions
        .where((tx) => !tx.isIncome &&
            tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // Budget tersisa: anggap budget bulanan = total pemasukan bulan ini
    final monthlyIncome = transactions
        .where((tx) => tx.isIncome &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final monthlyExpense = transactions
        .where((tx) => !tx.isIncome &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final budgetTersisa = (monthlyIncome - monthlyExpense).clamp(0, double.infinity);

    // Target tabungan: 30% dari pemasukan bulanan
    final savingsTarget = monthlyIncome * 0.30;
    final savedAmount = (monthlyIncome - monthlyExpense).clamp(0, double.infinity);
    final savingsProgress = monthlyIncome > 0
        ? (savedAmount / savingsTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // black 3%
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Bulanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pengeluaran Hari Ini
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.today_rounded,
                  iconBgColor: AppTheme.expenseColor.withOpacity(0.1),
                  iconColor: AppTheme.expenseColor,
                  label: 'Pengeluaran\nHari Ini',
                  value: currencyFormatter.format(todayExpense),
                ),
              ),
              Container(
                width: 1, height: 52,
                color: Colors.black.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // Budget Tersisa
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.account_balance_wallet_rounded,
                  iconBgColor: AppTheme.incomeColor.withOpacity(0.1),
                  iconColor: AppTheme.incomeColor,
                  label: 'Budget\nTersisa',
                  value: currencyFormatter.format(budgetTersisa),
                ),
              ),
              Container(
                width: 1, height: 52,
                color: Colors.black.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // Target Tabungan
              Expanded(
                child: _buildSavingsItem(
                  progress: savingsProgress,
                  percentage: (savingsProgress * 100).toInt(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsItem({required double progress, required int percentage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4B6CF5).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.savings_rounded, color: Color(0xFF4B6CF5), size: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Target\nTabungan',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF4B6CF5).withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4B6CF5)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF4B6CF5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceDetail({required String label, required double amount, required IconData icon, required Color color}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currencyFormatter.format(amount),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBalanceDialog(BuildContext context, UserProvider provider) {
    final TextEditingController controller = TextEditingController(
      text: provider.initialBalance > 0 
          ? NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(provider.initialBalance).trim()
          : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Saldo Awal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Nominal Saldo',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
                if (text.isNotEmpty) {
                  final newBalance = double.parse(text);
                  provider.updateInitialBalance(newBalance);
                } else {
                  provider.updateInitialBalance(0.0);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final int value = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final formatter = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    final String newText = formatter.format(value).trim();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
