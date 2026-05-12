import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  final List<Transaction> transactions;
  DashboardScreen({super.key, required this.transactions});

  double get totalIncome => transactions.where((tx) => tx.isIncome).fold(0, (sum, item) => sum + item.amount);
  double get totalExpense => transactions.where((tx) => !tx.isIncome).fold(0, (sum, item) => sum + item.amount);
  double get totalBalance => totalIncome - totalExpense;

  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'MoneyTrack',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1A9E9E9E)),
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary, size: 24),
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
                    const Text(
                      'Total Saldo',
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currencyFormatter.format(totalBalance),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 36, 
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
              child: _buildMonthlySummaryCard(context),
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

  Widget _buildMonthlySummaryCard(BuildContext context) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x149E9E9E)),
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
                  iconBgColor: const Color(0xFFFFF0F0),
                  iconColor: AppTheme.expenseColor,
                  label: 'Pengeluaran\nHari Ini',
                  value: currencyFormatter.format(todayExpense),
                ),
              ),
              Container(
                width: 1, height: 52,
                color: const Color(0x1A9E9E9E),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // Budget Tersisa
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.account_balance_wallet_rounded,
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: AppTheme.incomeColor,
                  label: 'Budget\nTersisa',
                  value: currencyFormatter.format(budgetTersisa),
                ),
              ),
              Container(
                width: 1, height: 52,
                color: const Color(0x1A9E9E9E),
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
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0FE),
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
                  backgroundColor: const Color(0xFFE8F0FE),
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
}
