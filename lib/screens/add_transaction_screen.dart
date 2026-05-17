import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) return;

    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: _titleController.text,
      amount: enteredAmount,
      isIncome: _isIncome,
      date: _selectedDate,
    );
    transactionProvider.addTransaction(newTx);

    NotificationService().showNotification(
      title: _isIncome ? 'Pemasukan Berhasil' : 'Pengeluaran Berhasil',
      body: 'Transaksi "${_titleController.text}" sebesar Rp ${enteredAmount.toInt()} telah dicatat.',
      type: 'transaction',
    );

    if (!_isIncome && enteredAmount >= 1000000) {
      NotificationService().showNotification(
        title: 'Pengeluaran Besar!',
        body: 'Anda baru saja mencatat pengeluaran sebesar Rp ${enteredAmount.toInt()}. Tetap pantau budget Anda!',
        type: 'alert',
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildInputLabel('Nama Transaksi'),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: _buildTextField(
                controller: _titleController,
                hint: 'cth. Gaji, Belanja, Makan Malam',
                icon: Icons.edit_note_rounded,
              ),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: _buildInputLabel('Jumlah'),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: _buildTextField(
                controller: _amountController,
                hint: '0',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: _buildInputLabel('Tipe'),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  _buildTypeButton(
                    label: 'Pemasukan',
                    isActive: _isIncome,
                    onTap: () => setState(() => _isIncome = true),
                    activeColor: AppTheme.incomeColor,
                    icon: Icons.add_circle_outline,
                  ),
                  const SizedBox(width: 16),
                  _buildTypeButton(
                    label: 'Pengeluaran',
                    isActive: !_isIncome,
                    onTap: () => setState(() => _isIncome = false),
                    activeColor: AppTheme.expenseColor,
                    icon: Icons.remove_circle_outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 600),
              child: _buildInputLabel('Tanggal'),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 700),
              child: InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1A9E9E9E)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: const Color(0x4D059669), // primaryColor 30%
                  ),
                  onPressed: _submitData,
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x03000000), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0x8064748B), fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 22),
          prefixText: prefixText,
          prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x1A9E9E9E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x1A9E9E9E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    required IconData icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive 
              ? (activeColor == AppTheme.incomeColor 
                  ? const Color(0x1410B981) 
                  : const Color(0x14EF4444))
              : Colors.white,
            border: Border.all(
              color: isActive ? activeColor : const Color(0x1A9E9E9E),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? activeColor : AppTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
