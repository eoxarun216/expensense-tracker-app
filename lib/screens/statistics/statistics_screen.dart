import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Month'; // Week, Month, Year
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    // Get all expenses from provider
    final allExpenses = expenseProvider.expenses;

    // Filter expenses based on selected period
    final filteredExpenses = _filterExpensesByPeriod(allExpenses, _selectedPeriod);

    // Calculate totals for filtered expenses
    final filteredCategoryTotals = <String, double>{};
    for (var expense in filteredExpenses) {
      filteredCategoryTotals[expense.category] = (filteredCategoryTotals[expense.category] ?? 0) + expense.amount;
    }
    final filteredTotalExpenses = filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    // Calculate average per day for the filtered period
    final avgPerDay = _calculateAveragePerDay(filteredExpenses, _selectedPeriod);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Analytics & Insights',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your spending patterns',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: expenseProvider.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period Selector
                        _buildPeriodSelector(),
                        const SizedBox(height: 24),

                        // Summary Cards (using filtered data)
                        _buildSummaryCards(filteredExpenses, filteredTotalExpenses, avgPerDay),
                        const SizedBox(height: 24),

                        // Charts Section Header
                        _buildSectionHeader('Spending Overview ($_selectedPeriod)'),
                        const SizedBox(height: 16),

                        // Only Pie Chart at top!
                        Row(
                          children: [
                            Expanded(
                              child: _buildPieChart(context, filteredCategoryTotals, filteredTotalExpenses),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Trends section ONLY below chart
                        _buildSectionHeader('Trends ($_selectedPeriod)'),
                        const SizedBox(height: 16),
                        _buildTrendsChart(context, filteredExpenses, _selectedPeriod),
                        const SizedBox(height: 24),

                        // Detailed Sections (using filtered data)
                        _buildSectionHeader('Detailed Breakdown ($_selectedPeriod)'),
                        const SizedBox(height: 16),
                        _buildCategoryList(context, filteredCategoryTotals, filteredTotalExpenses),
                        const SizedBox(height: 24),
                        _buildTopExpenses(context, filteredExpenses),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<ExpenseModel> _filterExpensesByPeriod(List<ExpenseModel> expenses, String period) {
    final now = DateTime.now();
    DateTime startPeriod;

    switch (period) {
      case 'Week':
        startPeriod = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startPeriod = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startPeriod = DateTime(now.year, 1, 1);
        break;
      default:
        return expenses;
    }

    return expenses.where((expense) => expense.date.isAfter(startPeriod)).toList();
  }

  double _calculateAveragePerDay(List<ExpenseModel> expenses, String period) {
    if (expenses.isEmpty) return 0.0;
    final totalAmount = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    int daysInPeriod = 1;

    final now = DateTime.now();
    switch (period) {
      case 'Week':
        daysInPeriod = 7;
        break;
      case 'Month':
        daysInPeriod = DateTime(now.year, now.month + 1, 0).day;
        break;
      case 'Year':
        daysInPeriod = 365;
        break;
    }
    return totalAmount / daysInPeriod;
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(List<ExpenseModel> filteredExpenses, double totalExpenses, double avgPerDay) {
    final maxExpense = filteredExpenses.isNotEmpty
        ? filteredExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Spent',
            '₹${totalExpenses.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg/Day',
            '₹${avgPerDay.toStringAsFixed(0)}',
            Icons.calendar_today,
            Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Highest',
            '₹${maxExpense.toStringAsFixed(0)}',
            Icons.trending_up,
            Colors.orange.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, double> categoryTotals, double totalExpenses) {
    if (categoryTotals.isEmpty) {
      return _buildEmptyChart('No data available');
    }
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Category Distribution',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: categoryTotals.entries.map((entry) {
                  final categoryData = CategoryData.categories.firstWhere(
                    (cat) => cat['name'] == entry.key,
                    orElse: () => CategoryData.categories.last,
                  );
                  final percentage = (entry.value / totalExpenses) * 100;
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: Color(categoryData['color']),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 4,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart(BuildContext context, List<ExpenseModel> expenses, String period) {
    if (expenses.isEmpty) {
      return _buildEmptyChart('No data available');
    }

    late List<Map<String, dynamic>> periodData;

    if (period == 'Week') {
      final now = DateTime.now();
      periodData = List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        final dayExpenses = expenses.where((e) {
          return e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day;
        });
        final total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
        return {'date': date, 'total': total};
      });
    } else if (period == 'Month') {
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      periodData = List.generate(daysInMonth, (index) {
        final date = DateTime(now.year, now.month, index + 1);
        final dayExpenses = expenses.where((e) {
          return e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day;
        });
        final total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
        return {'date': date, 'total': total};
      });
    } else {
      final now = DateTime.now();
      periodData = List.generate(12, (index) {
        final month = index + 1;
        final startOfMonth = DateTime(now.year, month, 1);
        final endOfMonth = DateTime(now.year, month + 1, 0);
        final monthExpenses = expenses.where((e) {
          return e.date.isAtSameMomentAs(startOfMonth) ||
              e.date.isAtSameMomentAs(endOfMonth) ||
              (e.date.isAfter(startOfMonth) && e.date.isBefore(endOfMonth));
        });
        final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
        return {'date': startOfMonth, 'total': total};
      });
    }
    final maxAmount = periodData.map((d) => d['total'] as double).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            period == 'Week' ? 'Weekly Trends' : period == 'Month' ? 'Daily Trends' : 'Monthly Trends',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount > 0 ? maxAmount * 1.2 : 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final total = periodData[group.x.toInt()]['total'] as double;
                      final date = periodData[group.x.toInt()]['date'] as DateTime;
                      String dateFormat;
                      if (period == 'Year') {
                        dateFormat = 'MMM yyyy';
                      } else if (period == 'Month') {
                        dateFormat = 'dd/MM';
                      } else {
                        dateFormat = 'MMM dd';
                      }
                      return BarTooltipItem(
                        '₹${total.toStringAsFixed(0)}\n${DateFormat(dateFormat).format(date)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < periodData.length) {
                          final date = periodData[value.toInt()]['date'] as DateTime;
                          String dateFormat;
                          String titleText = '';
                          if (period == 'Year') {
                            dateFormat = 'MMM';
                            titleText = DateFormat(dateFormat).format(date);
                          } else if (period == 'Month') {
                            if (date.day % 5 == 0 || date.day == 1) {
                              titleText = date.day.toString();
                            }
                          } else {
                            dateFormat = 'EEE';
                            titleText = DateFormat(dateFormat).format(date);
                          }
                          if (titleText.isNotEmpty) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(
                                titleText,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          } else {
                            return const SideTitleWidget(
                              axisSide: AxisSide.bottom,
                              child: Text(''),
                            );
                          }
                        }
                        return const SideTitleWidget(
                          axisSide: AxisSide.bottom,
                          child: Text(''),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(periodData.length, (index) {
                  final total = periodData[index]['total'] as double;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color: Theme.of(context).primaryColor,
                        width: periodData.length > 31 ? 8.0 : 16.0,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, Map<String, double> categoryTotals, double totalExpenses) {
    if (categoryTotals.isEmpty) {
      return _buildEmptyChart('No categories to show');
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: sortedCategories.map((entry) {
          final categoryData = CategoryData.categories.firstWhere(
            (cat) => cat['name'] == entry.key,
            orElse: () => CategoryData.categories.last,
          );
          final percentage = (entry.value / totalExpenses) * 100;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(categoryData['color']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          categoryData['icon'],
                          style: TextStyle(fontSize: 24, color: Color(categoryData['color'])),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${entry.value.toStringAsFixed(0)} • ${percentage.toStringAsFixed(1)}% of total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${entry.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(categoryData['color']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    color: Color(categoryData['color']),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopExpenses(BuildContext context, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return _buildEmptyChart('No expenses to show');
    }
    final topExpenses = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: topExpenses.take(5).map((expense) {
          final categoryData = CategoryData.categories.firstWhere(
            (cat) => cat['name'] == expense.category,
            orElse: () => CategoryData.categories.last,
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(categoryData['color']).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      categoryData['icon'],
                      style: TextStyle(fontSize: 24, color: Color(categoryData['color'])),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(expense.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${expense.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
