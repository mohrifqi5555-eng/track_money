import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final filteredTransactions = _filter == 'Pemasukan'
        ? transactions.where((tx) => tx.isIncome).toList()
        : _filter == 'Pengeluaran'
            ? transactions.where((tx) => !tx.isIncome).toList()
            : transactions;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Riwayat',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter Tabs
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Pemasukan'),
                  _buildFilterChip('Pengeluaran'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
                           const SizedBox(height: 16),
                           Text(
                             'Tidak ada transaksi',
                             style: TextStyle(
                               color: Colors.grey.withOpacity(0.5), 
                               fontSize: 16,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ],
                       ),
                     )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        return FadeInRight(
                          delay: Duration(milliseconds: 50 * index),
                          child: Dismissible(
                            key: Key(tx.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: const Color(0x1AEF4444), // expenseColor 10%
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: AppTheme.expenseColor, size: 28),
                            ),
                            onDismissed: (direction) {
                              transactionProvider.deleteTransaction(tx.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${tx.title} dihapus', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: AppTheme.textPrimary,
                                ),
                              );
                            },
                            child: TransactionTile(transaction: tx),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : const Color(0x1A9E9E9E)),
          boxShadow: isSelected ? const [
            BoxShadow(
              color: Color(0x26059669), // primaryColor 15%
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
