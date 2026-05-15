import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const ReportsScreen({super.key, required this.transactions});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Bulanan';
  DateTime _focusedDate = DateTime.now();
  final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();
    final totalIncome = filteredTransactions.where((tx) => tx.isIncome).fold(0.0, (sum, item) => sum + item.amount);
    final totalExpense = filteredTransactions.where((tx) => !tx.isIncome).fold(0.0, (sum, item) => sum + item.amount);
    final totalBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Premium Header
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 24),

                // 2. Tab Period Filter
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: _buildPeriodTabs(),
                ),
                const SizedBox(height: 24),

                // 3. Month Navigation (only for monthly filter)
                if (_selectedPeriod == 'Bulanan')
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: _buildMonthNavigator(),
                  ),
                const SizedBox(height: 20),

                // 4. Premium Balance Card
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildBalanceCard(totalIncome, totalExpense, totalBalance),
                ),
                const SizedBox(height: 24),

                // 5. Expense Trend Chart
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: _buildExpenseChart(filteredTransactions),
                ),
                const SizedBox(height: 24),

                // 6. Category Section
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: _buildCategoryDistribution(filteredTransactions),
                ),
                const SizedBox(height: 24),

                // 7. Budget Progress
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: _buildBudgetProgress(totalExpense),
                ),
                const SizedBox(height: 24),

                // 8. Financial Insights & Details
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: _buildInsightSection(filteredTransactions, totalIncome, totalExpense),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Laporan',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -1),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: const Icon(Icons.calendar_today_rounded, size: 20, color: AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: ['Mingguan', 'Bulanan', 'Tahunan'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  period,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(Icons.chevron_left_rounded, () {
          setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1));
        }),
        Text(
          DateFormat('MMMM yyyy', 'id').format(_focusedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        _buildNavButton(Icons.chevron_right_rounded, () {
          setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1));
        }),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, size: 22, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildBalanceCard(double income, double expense, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          const Text('Total Saldo Bersih', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                _buildCompactStat('Pemasukan', income, Icons.north_east_rounded),
                Container(width: 1, height: 30, color: Colors.white12),
                _buildCompactStat('Pengeluaran', expense, Icons.south_west_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, double amount, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: Colors.white70),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(currencyFormatter.format(amount), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(List<Transaction> transactions) {
    final spots = _getExpenseSpots(transactions);
    final dates = _getUniqueDates(transactions);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tren Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => AppTheme.textPrimary,
                    tooltipPadding: const EdgeInsets.all(10),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dateStr = dates.length > spot.x.toInt() ? DateFormat('dd MMM').format(dates[spot.x.toInt()]) : '';
                        return LineTooltipItem(
                          '$dateStr\n${currencyFormatter.format(spot.y * 1000)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < dates.length) {
                          if (dates.length > 7 && value.toInt() % (dates.length ~/ 4) != 0) return const SizedBox();
                          return Text(DateFormat('dd/MM').format(dates[value.toInt()]), style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w600));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.expenseColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.expenseColor.withOpacity(0.25), AppTheme.expenseColor.withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(List<Transaction> transactions) {
    final Map<String, double> categoryData = {};
    for (var tx in transactions.where((t) => !t.isIncome)) {
      categoryData[tx.category] = (categoryData[tx.category] ?? 0) + tx.amount;
    }
    
    final totalExp = categoryData.values.fold(0.0, (s, i) => s + i);
    final colors = [AppTheme.primaryColor, Colors.orange, Colors.blue, Colors.purple, Colors.red];
    final icons = [Icons.restaurant_rounded, Icons.directions_car_rounded, Icons.shopping_bag_rounded, Icons.videogame_asset_rounded, Icons.more_horiz_rounded];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 35,
                    sections: categoryData.isEmpty 
                      ? [PieChartSectionData(color: Colors.grey.withOpacity(0.1), value: 1, radius: 25, title: '')]
                      : categoryData.entries.map((e) {
                          final idx = categoryData.keys.toList().indexOf(e.key);
                          return PieChartSectionData(color: colors[idx % colors.length], value: e.value, radius: 25, title: '');
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: categoryData.entries.take(4).map((e) {
                    final idx = categoryData.keys.toList().indexOf(e.key);
                    final pct = (totalExp > 0 ? (e.value / totalExp * 100) : 0).toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: colors[idx % colors.length].withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(icons[idx % icons.length], size: 12, color: colors[idx % colors.length]),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colors[idx % colors.length])),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(double totalExpense) {
    const double budgetTotal = 15000000;
    final double percent = (totalExpense / budgetTotal).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Budget Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: percent > 0.8 ? AppTheme.expenseColor : AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              color: percent > 0.8 ? AppTheme.expenseColor : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currencyFormatter.format(totalExpense), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('dari ${currencyFormatter.format(budgetTotal)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(List<Transaction> transactions, double income, double expense) {
    final topExpense = transactions.where((t) => !t.isIncome).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insight Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          _buildInsightTile('Pengeluaran Terbesar', topExpense.isNotEmpty ? topExpense.first.title : '-', Icons.trending_up_rounded, Colors.red),
          const SizedBox(height: 16),
          _buildInsightTile('Target Tabungan', income > 0 ? 'Tercapai 45%' : 'Belum Mulai', Icons.savings_rounded, Colors.indigo),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _exportToPDF(transactions, income, expense),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Export Laporan PDF', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          ],
        ),
      ],
    );
  }

  List<Transaction> _getFilteredTransactions() {
    return widget.transactions.where((tx) {
      if (_selectedPeriod == 'Mingguan') {
        return tx.date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
      } else if (_selectedPeriod == 'Bulanan') {
        return tx.date.month == _focusedDate.month && tx.date.year == _focusedDate.year;
      } else {
        return tx.date.year == _focusedDate.year;
      }
    }).toList();
  }

  List<FlSpot> _getExpenseSpots(List<Transaction> transactions) {
    final expenses = transactions.where((t) => !t.isIncome).toList();
    if (expenses.isEmpty) return [const FlSpot(0, 150), const FlSpot(1, 450), const FlSpot(2, 300), const FlSpot(3, 800), const FlSpot(4, 550), const FlSpot(5, 700), const FlSpot(6, 400)];
    
    final Map<String, double> dailySum = {};
    for (var tx in expenses) {
      final dayStr = DateFormat('yyyy-MM-dd').format(tx.date);
      dailySum[dayStr] = (dailySum[dayStr] ?? 0) + tx.amount;
    }
    
    final sortedDays = dailySum.keys.toList()..sort();
    return List.generate(sortedDays.length, (i) => FlSpot(i.toDouble(), dailySum[sortedDays[i]]! / 1000));
  }

  List<DateTime> _getUniqueDates(List<Transaction> transactions) {
    final expenses = transactions.where((t) => !t.isIncome).toList();
    if (expenses.isEmpty) return List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i)));
    
    final Map<String, DateTime> uniqueDays = {};
    for (var tx in expenses) {
      final dayStr = DateFormat('yyyy-MM-dd').format(tx.date);
      if (!uniqueDays.containsKey(dayStr)) uniqueDays[dayStr] = DateTime(tx.date.year, tx.date.month, tx.date.day);
    }
    
    return uniqueDays.values.toList()..sort((a, b) => a.compareTo(b));
  }

  Future<void> _exportToPDF(List<Transaction> transactions, double income, double expense) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Laporan Keuangan MoneyTrack')),
              pw.SizedBox(height: 20),
              pw.Text('Periode: $_selectedPeriod (${DateFormat('MMMM yyyy', 'id').format(_focusedDate)})'),
              pw.SizedBox(height: 20),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Pemasukan:'), pw.Text(currencyFormatter.format(income))]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Pengeluaran:'), pw.Text(currencyFormatter.format(expense))]),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Saldo Akhir:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(currencyFormatter.format(income - expense), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
              pw.SizedBox(height: 40),
              pw.Table.fromTextArray(context: context, data: [['Tanggal', 'Judul', 'Kategori', 'Nominal'], ...transactions.map((tx) => [DateFormat('dd/MM/yy').format(tx.date), tx.title, tx.category, currencyFormatter.format(tx.amount)])]),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
