import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(String) deleteTx;
  const HistoryScreen({super.key, required this.transactions, required this.deleteTx});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Semua';

  List<Transaction> get _filteredTransactions {
    if (_filter == 'Pemasukan') return widget.transactions.where((tx) => tx.isIncome).toList();
    if (_filter == 'Pengeluaran') return widget.transactions.where((tx) => !tx.isIncome).toList();
    return widget.transactions;
  }

  @override
  Widget build(BuildContext context) {
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
              child: _filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada transaksi',
                            style: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5), 
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = _filteredTransactions[index];
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
                              widget.deleteTx(tx.id);
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
