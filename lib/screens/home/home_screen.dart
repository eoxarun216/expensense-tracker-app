import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/constants.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_details_screen.dart';
import '../expenses/search_screen.dart';
import '../budget/budget_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/budget_alert_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExpenseProvider>().fetchExpenses();
        context.read<BudgetProvider>().fetchBudgets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeTab(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack( // Keeps all screens alive for great performance switching back/forth
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 12,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) {
          setState(() => _selectedIndex = idx);
        },
        elevation: 0,
        height: 70,
        backgroundColor: Theme.of(context).cardColor,
        indicatorColor: Theme.of(context).primaryColor.withOpacity(0.13),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// HOMETAB

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedFilter = 'All';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    List<ExpenseModel> filteredExpenses = _getFilteredExpenses(expenseProvider.expenses);
    double filteredTotal = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Personalized Gradient Greeting
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.all(0),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark.withOpacity(0.80),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Hi, ${authProvider.user?.name.split(' ').first ?? "User"} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.trending_up_rounded, color: Colors.white, size: 17),
                            const SizedBox(width: 6),
                            Text(
                              'Smart summary: your ${_selectedFilter.toLowerCase()} expenses',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Track, budget, and grow 📈',
                          style: TextStyle(color: Colors.white.withOpacity(0.90), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                tooltip: 'Search',
              ),
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                ),
                tooltip: 'Budget',
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<ExpenseProvider>().fetchExpenses();
                await context.read<BudgetProvider>().fetchBudgets();
              },
              child: Builder(builder: (context) {
                final isLoading = expenseProvider.isLoading;
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 70),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  children: [
                    // Main Analytics/Balance Card
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: _buildBalanceCard(context, filteredTotal, filteredExpenses.length),
                    ),
                    // Budget Quick Access
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      child: _buildBudgetQuickAccess(context, expenseProvider),
                    ),
                    // Budget Alerts
                    AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      child: _buildBudgetAlerts(context),
                    ),
                    // Filters Row
                    _buildFilterChips(),
                    // Category Filter
                    _buildCategoryFilter(),
                    // Transactions List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 21),
                            tooltip: 'Reset Filters',
                            onPressed: () {
                              setState(() {
                                _selectedFilter = 'All';
                                _selectedCategory = 'All';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Transaction List
                    filteredExpenses.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredExpenses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 5),
                            itemBuilder: (context, idx) =>
                                _buildExpenseCard(filteredExpenses[idx]),
                          ),
                    const SizedBox(height: 90),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> expenses) {
    List<ExpenseModel> filtered = expenses;
    final now = DateTime.now();
    if (_selectedFilter == 'Today') {
      filtered = expenses.where((e) =>
        e.date.year == now.year && e.date.month == now.month && e.date.day == now.day
      ).toList();
    } else if (_selectedFilter == 'Week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      filtered = expenses.where((e) => e.date.isAfter(weekAgo)).toList();
    } else if (_selectedFilter == 'Month') {
      filtered = expenses.where((e) =>
        e.date.year == now.year && e.date.month == now.month
      ).toList();
    }
    if (_selectedCategory != 'All') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }
    return filtered;
  }

  Widget _buildBalanceCard(BuildContext context, double total, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade400,
            Colors.deepPurple.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedFilter == 'All' ? 'Total Expenses' : '$_selectedFilter Expenses',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.17),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  _selectedFilter,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _buildBalanceInfo(Icons.receipt_long, '$count', 'Transactions'),
              const SizedBox(width: 28),
              _buildBalanceInfo(Icons.trending_up,
                count > 0 ? '₹${(total / count).toStringAsFixed(0)}' : '₹0', 'Avg Spend'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold,
            )),
            Text(label, style: const TextStyle(
              color: Colors.white70, fontSize: 10,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetQuickAccess(BuildContext context, ExpenseProvider expenseProvider) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final monthlyBudget = budgetProvider.totalMonthlyBudget;
        final monthExpenses = expenseProvider.getCurrentMonthExpenses();
        final monthTotal = monthExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
        final percentage = monthlyBudget > 0 ? (monthTotal / monthlyBudget) * 100 : 0;
        final isWarning = percentage > 70 && percentage <= 90;
        final isDanger = percentage > 90;
        final gradient = isDanger
            ? [Colors.red.shade400, Colors.red.shade600]
            : isWarning
                ? [Colors.orange.shade400, Colors.orange.shade600]
                : [Colors.green.shade400, Colors.green.shade600];

        return InkWell(
          onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.white.withOpacity(0.20),
                  child: const Icon(Icons.wallet, color: Colors.white, size: 27),
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        monthlyBudget > 0
                            ? '₹${monthTotal.toStringAsFixed(0)} / ₹${monthlyBudget.toStringAsFixed(0)}'
                            : 'Set your budget',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      monthlyBudget > 0 ? '${percentage.toStringAsFixed(0)}%' : 'Set',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tap',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetAlerts(BuildContext context) {
    return Consumer2<ExpenseProvider, BudgetProvider>(
      builder: (context, expenseProvider, budgetProvider, child) {
        final alerts = <Widget>[];
        for (var entry in expenseProvider.categoryTotals.entries) {
          final spent = entry.value;
          final budget = budgetProvider.getBudgetForCategory(entry.key);
          if (budget != null) {
            final status = BudgetAlertService.getBudgetStatus(spent, budget.limit);
            if (status == BudgetStatus.exceeded) {
              alerts.add(_buildAlertBanner(
                context,
                '⚠️ ${entry.key} budget exceeded!',
                'Spent ₹${spent.toStringAsFixed(0)} of ₹${budget.limit.toStringAsFixed(0)}',
                BudgetAlertService.getStatusColor(status),
                status,
              ));
            } else if (status == BudgetStatus.warning) {
              alerts.add(_buildAlertBanner(
                context,
                '⚡ Approaching ${entry.key} budget',
                '${((spent / budget.limit) * 100).toStringAsFixed(0)}% used',
                BudgetAlertService.getStatusColor(status),
                status,
              ));
            }
          }
        }
        if (alerts.isEmpty) return const SizedBox.shrink();
        return Column(children: [...alerts, const SizedBox(height: 10)]);
      },
    );
  }

  Widget _buildAlertBanner(
      BuildContext context, String title, String subtitle, Color color, BudgetStatus status) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Material(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BudgetScreen()),
          ),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Icon(BudgetAlertService.getStatusIcon(status), color: color, size: 27),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                        style: TextStyle(color: color, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Today', 'Week', 'Month'];
    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: filters.length,
        itemBuilder: (context, idx) {
          final filter = filters[idx];
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              selected: selected,
              onSelected: (val) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              showCheckmark: false,
              elevation: selected ? 3 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...CategoryData.categories.map((c) => c['name'] as String)];
    return Container(
      height: 76,
      margin: const EdgeInsets.symmetric(vertical: 9),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: categories.length,
        itemBuilder: (context, idx) {
          final category = categories[idx];
          final selected = _selectedCategory == category;
          String emoji = '📦';
          Color color = Colors.grey;
          if (category != 'All') {
            final categoryData = CategoryData.categories.firstWhere(
                (c) => c['name'] == category,
                orElse: () => CategoryData.categories.last);
            emoji = categoryData['icon'];
            color = Color(categoryData['color']);
          }
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              width: 73,
              margin: const EdgeInsets.only(right: 11),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.13) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? color : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 27)),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? color : Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final categoryData = CategoryData.categories.firstWhere(
      (cat) => cat['name'] == expense.category, orElse: () => CategoryData.categories.last);

    final now = DateTime.now();
    final isToday = now.year == expense.date.year &&
        now.month == expense.date.month && now.day == expense.date.day;
    final isYesterday = now.subtract(const Duration(days: 1)).year == expense.date.year &&
        now.subtract(const Duration(days: 1)).month == expense.date.month &&
        now.subtract(const Duration(days: 1)).day == expense.date.day;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today • ${DateFormat('HH:mm').format(expense.date)}';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('MMM dd, yyyy').format(expense.date);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context, MaterialPageRoute(
            builder: (_) => ExpenseDetailsScreen(expense: expense))),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: Color(categoryData['color']).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    categoryData['icon'],
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(categoryData['color']).withOpacity(0.11),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            expense.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(categoryData['color']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600),
                  ),
                  if (expense.description.isNotEmpty)
                    Icon(Icons.notes, size: 14, color: Colors.grey[400]),
                ],
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
        padding: const EdgeInsets.all(52),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.grey[100], shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 25),
            Text(
              'No expenses found',
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700]),
            ),
            const SizedBox(height: 7),
            Text(
              _selectedFilter == 'All'
                  ? 'Start tracking by adding your first expense'
                  : 'No expenses for $_selectedFilter',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 14.7),
            ),
          ],
        ),
      ),
    );
  }
}
