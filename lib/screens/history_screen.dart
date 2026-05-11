import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(String) deleteTx;
  const HistoryScreen({Key? key, required this.transactions, required this.deleteTx}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';

  List<Transaction> get _filteredTransactions {
    if (_filter == 'Income') return widget.transactions.where((tx) => tx.isIncome).toList();
    if (_filter == 'Expense') return widget.transactions.where((tx) => !tx.isIncome).toList();
    return widget.transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                children: [
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Filter Tabs
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Income'),
                  _buildFilterChip('Expense'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 18),
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
                              padding: const EdgeInsets.only(right: 30),
                              decoration: BoxDecoration(
                                color: AppTheme.expenseColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
                            ),
                            onDismissed: (direction) {
                              widget.deleteTx(tx.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${tx.title} deleted'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.2)),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
