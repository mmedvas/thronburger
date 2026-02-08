import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../repositories/repositories.dart';

/// Reports Screen
/// Sales analytics with charts (Admin only)
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  DateTimeRange? _dateRange;
  Map<String, dynamic>? _reportData;
  List<Map<String, dynamic>> _dailySales = [];

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (_dateRange == null) return;

    setState(() => _isLoading = true);
    try {
      final orderRepo = context.read<OrderRepository>();
      final report = await orderRepo.getSalesReport(
        fromDate: _dateRange!.start,
        toDate: _dateRange!.end,
      );
      final dailySales = await orderRepo.getDailySales(
        fromDate: _dateRange!.start.subtract(const Duration(days: 14)),
        toDate: _dateRange!.end,
      );
      setState(() {
        _reportData = report;
        _dailySales = dailySales.take(14).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load report: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => _dateRange = result);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        actions: [
          TextButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _dateRange != null
                  ? '${dateFormatter.format(_dateRange!.start)} - ${dateFormatter.format(_dateRange!.end)}'
                  : 'Select dates',
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReport),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData == null
          ? const Center(child: Text('No data available'))
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricsGrid(),
                    const SizedBox(height: 24),
                    _buildSalesChart(),
                    const SizedBox(height: 24),
                    _buildTopItems(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricsGrid() {
    final formatter = NumberFormat('#,###', 'en');
    final data = _reportData!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _MetricCard(
              title: 'Total Sales',
              value: formatter.format((data['totalSales'] as num).toInt()),
              suffix: 'IQD',
              icon: Icons.attach_money,
              color: AppTheme.success,
            ),
            _MetricCard(
              title: 'Orders',
              value: '${data['totalOrders']}',
              icon: Icons.receipt_long,
              color: AppTheme.info,
            ),
            _MetricCard(
              title: 'Avg Order',
              value: formatter.format(
                (data['averageOrderValue'] as num).toInt(),
              ),
              suffix: 'IQD',
              icon: Icons.trending_up,
              color: AppTheme.primary,
            ),
            _MetricCard(
              title: 'Items Sold',
              value: '${data['totalItems']}',
              icon: Icons.fastfood,
              color: AppTheme.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesChart() {
    if (_dailySales.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxSales = _dailySales
        .map((d) => (d['sales'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Sales (Last 14 Days)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxSales * 1.2,
                  barGroups: _dailySales.asMap().entries.map((entry) {
                    final sales = (entry.value['sales'] as num).toDouble();
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: sales,
                          color: AppTheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _dailySales.length) {
                            final date = _dailySales[index]['date'] as String;
                            final day = date.split('-').last;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxSales / 4,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: AppTheme.border, strokeWidth: 1),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final formatter = NumberFormat('#,###', 'en');
                        return BarTooltipItem(
                          '${formatter.format(rod.toY.toInt())} IQD',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopItems() {
    final topItems = _reportData!['topItems'] as List<dynamic>;
    if (topItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final formatter = NumberFormat('#,###', 'en');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...topItems.asMap().entries.map((entry) {
              final item = entry.value as Map<String, dynamic>;
              final index = entry.key;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? AppTheme.primary
                        : index == 1
                        ? AppTheme.textSecondary
                        : index == 2
                        ? AppTheme.warning
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: index < 3 ? Colors.black : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                title: Text(item['name'] as String),
                subtitle: Text(
                  '${item['quantity']} sold',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                trailing: Text(
                  '${formatter.format((item['revenue'] as num).toInt())} IQD',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffix != null)
                  Text(
                    ' $suffix',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
