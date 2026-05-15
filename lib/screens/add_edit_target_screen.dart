import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/savings_target.dart';
import '../providers/savings_provider.dart';
import '../theme/app_theme.dart';

class AddEditTargetScreen extends StatefulWidget {
  final SavingsTarget? target;

  const AddEditTargetScreen({Key? key, this.target}) : super(key: key);

  @override
  State<AddEditTargetScreen> createState() => _AddEditTargetScreenState();
}

class _AddEditTargetScreenState extends State<AddEditTargetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  IconData _selectedIcon = Icons.stars_rounded;

  final List<IconData> _availableIcons = [
    Icons.stars_rounded,
    Icons.laptop_mac_rounded,
    Icons.flight_takeoff_rounded,
    Icons.emergency_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.phone_iphone_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.target?.title ?? '');
    _targetAmountController = TextEditingController(text: widget.target?.targetAmount.toInt().toString() ?? '');
    _currentAmountController = TextEditingController(text: widget.target?.currentAmount.toInt().toString() ?? '');
    if (widget.target != null) {
      _selectedIcon = widget.target!.icon;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.target != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Target' : 'Tambah Target Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconPicker(),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Nama Target',
                controller: _titleController,
                hint: 'Misal: MacBook Pro',
                icon: Icons.edit_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Nominal Target',
                controller: _targetAmountController,
                hint: '0',
                icon: Icons.account_balance_wallet_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Nominal Terkumpul Sekarang',
                controller: _currentAmountController,
                hint: '0',
                icon: Icons.savings_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTarget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Target',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _confirmDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.expenseColor,
                    ),
                    child: const Text('Hapus Target Ini'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Icon',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableIcons.map((icon) {
            bool isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
            filled: true,
            fillColor: Theme.of(context).cardTheme.color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Field ini wajib diisi';
            if (keyboardType == TextInputType.number && double.tryParse(value) == null) {
              return 'Masukkan angka yang valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveTarget() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SavingsProvider>(context, listen: false);
      final target = SavingsTarget(
        id: widget.target?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(_currentAmountController.text),
        icon: _selectedIcon,
      );

      if (widget.target == null) {
        provider.addTarget(target);
      } else {
        provider.updateTarget(target);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.target == null ? 'Target berhasil ditambah' : 'Target berhasil diperbarui'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Target'),
        content: const Text('Apakah Anda yakin ingin menghapus target ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Provider.of<SavingsProvider>(context, listen: false).deleteTarget(widget.target!.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Target berhasil dihapus'), backgroundColor: AppTheme.expenseColor),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }
}
