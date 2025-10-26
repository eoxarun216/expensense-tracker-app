import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/constants.dart';
import '../expenses/expense_details_screen.dart';

class MonthlyExpensesScreen extends StatefulWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  State<MonthlyExpensesScreen> createState() => _MonthlyExpensesScreenState();
}

class _MonthlyExpensesScreenState extends State<MonthlyExpensesScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedMonth;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _viewMode = 'daily';

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final monthExpenses = _getMonthExpenses(expenseProvider.expenses);
    final monthTotal = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    
    final avgDaily = monthExpenses.isNotEmpty 
        ? monthTotal / DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day
        : 0.0;
    final maxExpense = monthExpenses.isNotEmpty
        ? monthExpenses.reduce((a, b) => a.amount > b.amount ? a : b).amount
        : 0.0;
    
    final categoryTotals = <String, double>{};
    for (var expense in monthExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final now = DateTime.now();
    final isFutureMonth = _selectedMonth.isAfter(DateTime(now.year, now.month));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Compact App Bar
          SliverAppBar(
            expandedHeight: 240, // ✅ Reduced from 260
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6), // ✅ Compact padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Month Navigator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28), // ✅ Smaller
                              onPressed: () => _changeMonth(-1),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    DateFormat('MMMM').format(_selectedMonth),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24, // ✅ Reduced from 28
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('yyyy').format(_selectedMonth),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14, // ✅ Reduced from 16
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // ✅ Compact
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${monthExpenses.length} transactions',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11, // ✅ Reduced from 12
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: isFutureMonth ? Colors.white30 : Colors.white,
                                size: 28, // ✅ Smaller
                              ),
                              onPressed: isFutureMonth ? null : () => _changeMonth(1),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10), // ✅ Reduced from 16
                        
                        // Compact Total Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // ✅ Very compact
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Total Spent',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12, // ✅ Reduced from 14
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4), // ✅ Reduced from 6
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  '₹${monthTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28, // ✅ Reduced from 32
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7), // ✅ Reduced from 12
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildQuickStat('Avg/Day', '₹${avgDaily.toStringAsFixed(0)}'),
                                  Container(width: 1, height: 24, color: Colors.white30), // ✅ Shorter
                                  _buildQuickStat('Highest', '₹${maxExpense.toStringAsFixed(0)}'),
                                  Container(width: 1, height: 24, color: Colors.white30), // ✅ Shorter
                                  _buildQuickStat('Categories', '${categoryTotals.length}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Compact View Mode Toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), // ✅ Reduced padding
              child: Row(
                children: [
                  Expanded(
                    child: _buildViewModeButton('Daily View', Icons.calendar_today, 'daily'),
                  ),
                  const SizedBox(width: 10), // ✅ Reduced from 12
                  Expanded(
                    child: _buildViewModeButton('By Category', Icons.category, 'category'),
                  ),
                ],
              ),
            ),
          ),

          // Content
          monthExpenses.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : _viewMode == 'daily'
                  ? _buildDailyView(monthExpenses)
                  : _buildCategoryView(categoryTotals, monthTotal),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14, // ✅ Reduced from 16
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9, // ✅ Reduced from 10
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeButton(String label, IconData icon, String mode) {
    final isSelected = _viewMode == mode;
    return Material(
      color: isSelected ? Theme.of(context).primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(10), // ✅ Slightly smaller
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: () {
          setState(() {
            _viewMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10), // ✅ Reduced from 12
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16, // ✅ Reduced from 18
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6), // ✅ Reduced from 8
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 13, // ✅ Reduced from 14
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverList _buildDailyView(List<ExpenseModel> expenses) {
    final groupedExpenses = <String, List<ExpenseModel>>{};
    for (var expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
    }

    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dateKey = sortedDates[index];
          final dayExpenses = groupedExpenses[dateKey]!;
          final dayTotal = dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
          final date = DateTime.parse(dateKey);
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildDaySection(date, dayExpenses, dayTotal),
          );
        },
        childCount: sortedDates.length,
      ),
    );
  }

  Widget _buildDaySection(DateTime date, List<ExpenseModel> expenses, double total) {
    final now = DateTime.now();
    final isToday = date.year == now.year && 
                   date.month == now.month && 
                   date.day == now.day;
    final isYesterday = now.difference(date).inDays == 1;

    String dayLabel;
    if (isToday) {
      dayLabel = 'Today';
    } else if (isYesterday) {
      dayLabel = 'Yesterday';
    } else {
      dayLabel = DateFormat('EEEE, MMM dd').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // ✅ Reduced from 8
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // ✅ Compact
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14, // ✅ Reduced from 16
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 6), // ✅ Reduced from 8
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // ✅ Reduced from 14
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // ✅ Reduced from 16
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6), // ✅ Reduced from 8
          ...expenses.map((expense) => _buildExpenseCard(expense)),
        ],
      ),
    );
  }

  SliverList _buildCategoryView(Map<String, double> categoryTotals, double monthTotal) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = sortedCategories[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCategoryCard(entry.key, entry.value, monthTotal),
          );
        },
        childCount: sortedCategories.length,
      ),
    );
  }

  Widget _buildCategoryCard(String category, double amount, double total) {
    final categoryData = CategoryData.getCategoryByName(category) ??
        CategoryData.categories.last;
    final percentage = (amount / total) * 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), // ✅ Reduced from 6
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // ✅ Slightly smaller
        elevation: 1,
        child: InkWell(
          onTap: () => _showCategoryExpenses(category),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14), // ✅ Reduced from 16
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52, // ✅ Reduced from 56
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(categoryData['color']).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          categoryData['icon'],
                          style: const TextStyle(fontSize: 26), // ✅ Reduced from 28
                        ),
                      ),
                    ),
                    const SizedBox(width: 14), // ✅ Reduced from 16
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15, // ✅ Reduced from 16
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(categoryData['color']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(1)}% of total',
                              style: TextStyle(
                                fontSize: 10, // ✅ Reduced from 11
                                fontWeight: FontWeight.w600,
                                color: Color(categoryData['color']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // ✅ Reduced from 20
                            color: Color(categoryData['color']),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 18, // ✅ Reduced from 20
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10), // ✅ Reduced from 12
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 7, // ✅ Reduced from 8
                    backgroundColor: Colors.grey[200],
                    color: Color(categoryData['color']),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final categoryData = CategoryData.getCategoryByName(expense.category) ??
        CategoryData.categories.last;

    return Card(
      margin: const EdgeInsets.only(bottom: 6), // ✅ Reduced from 8
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // ✅ Slightly smaller
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailsScreen(expense: expense),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10), // ✅ Reduced from 12
          child: Row(
            children: [
              Container(
                width: 44, // ✅ Reduced from 48
                height: 44,
                decoration: BoxDecoration(
                  color: Color(categoryData['color']).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    categoryData['icon'],
                    style: const TextStyle(fontSize: 22), // ✅ Reduced from 24
                  ),
                ),
              ),
              const SizedBox(width: 10), // ✅ Reduced from 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13, // ✅ Reduced from 14
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(categoryData['color']).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.category,
                            style: TextStyle(
                              fontSize: 9, // ✅ Reduced from 10
                              fontWeight: FontWeight.w600,
                              color: Color(categoryData['color']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6), // ✅ Reduced from 8
                        Icon(Icons.access_time, size: 9, color: Colors.grey[500]), // ✅ Smaller
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('HH:mm').format(expense.date),
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]), // ✅ Reduced from 11
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '₹${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15, // ✅ Reduced from 16
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40), // ✅ Reduced from 48
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28), // ✅ Reduced from 32
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 70, // ✅ Reduced from 80
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20), // ✅ Reduced from 24
            Text(
              'No expenses found',
              style: TextStyle(
                fontSize: 18, // ✅ Reduced from 20
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6), // ✅ Reduced from 8
            Text(
              'You didn\'t spend anything in\n${DateFormat('MMMM yyyy').format(_selectedMonth)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13, // ✅ Reduced from 14
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ExpenseModel> _getMonthExpenses(List<ExpenseModel> allExpenses) {
    return allExpenses.where((expense) {
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _showCategoryExpenses(String category) {
    final expenseProvider = context.read<ExpenseProvider>();
    final categoryExpenses = _getMonthExpenses(expenseProvider.expenses)
        .where((e) => e.category == category)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14), // ✅ Compact
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '$category Expenses',
                      style: const TextStyle(
                        fontSize: 18, // ✅ Reduced from 20
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${categoryExpenses.length} transactions',
                      style: TextStyle(
                        fontSize: 13, // ✅ Reduced from 14
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryExpenses.length,
                  itemBuilder: (context, index) {
                    return _buildExpenseCard(categoryExpenses[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
