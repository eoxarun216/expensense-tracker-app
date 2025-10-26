import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/budget_model.dart';
import '../../utils/constants.dart';
import 'add_budget_screen.dart';
import 'income_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetProvider>().fetchBudgets();
      }
    });
  }

  Future<void> _deleteBudget(BudgetModel budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the ${budget.category} budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final budgetProvider = context.read<BudgetProvider>();
      final success = await budgetProvider.deleteBudget(budget.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(success ? 'Budget deleted' : 'Delete failed'),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _editBudget(BudgetModel budget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBudgetScreen(budget: budget)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final monthlyBudgets = budgetProvider.getBudgetsByPeriod('monthly');
    final totalMonthlyBudget = budgetProvider.totalMonthlyBudget;
    final totalIncome = budgetProvider.totalIncome;

    // Get monthly spending and determine status
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthExpenses = expenseProvider.getExpensesByDateRange(
      monthStart,
      DateTime(now.year, now.month + 1, 0),
    );
    final monthTotal = monthExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final percentage = totalMonthlyBudget > 0 ? (monthTotal / totalMonthlyBudget) * 100 : 0.0;
    final savings = totalIncome - monthTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How budgets work',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: budgetProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => budgetProvider.fetchBudgets(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Income Summary Card (+ nav)
                    _buildIncomeSummaryCard(
                        totalIncome, budgetProvider.personalIncome, budgetProvider.familyIncome),
                    const SizedBox(height: 18),

                    // Overall Budget Analytics Card
                    _buildOverallAnalyticsCard(monthTotal, totalMonthlyBudget, percentage, savings),
                    const SizedBox(height: 24),

                    // Header (actions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Budgets',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Budget List or Empty State
                    monthlyBudgets.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: monthlyBudgets.map((budget) {
                              return _buildBudgetCard(
                                budget,
                                expenseProvider.categoryTotals[budget.category] ?? 0.0,
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }

  Widget _buildIncomeSummaryCard(double total, double personal, double family) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const IncomeScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Monthly Income',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      if (personal > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '• Personal: ₹${personal.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                      if (family > 0)
                        Text(
                          '• Family: ₹${family.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallAnalyticsCard(
      double spent, double budget, double percentUsed, double savings) {
    MaterialColor statusColor = Colors.green;
    String statusText = 'On Track';
    IconData statusIcon = Icons.check_circle_rounded;

    if (percentUsed > 100) {
      statusColor = Colors.red;
      statusText = 'Over Budget';
      statusIcon = Icons.warning_amber_rounded;
    } else if (percentUsed > 80) {
      statusColor = Colors.orange;
      statusText = 'High Usage';
      statusIcon = Icons.error_outline;
    }

    Color savingsColor = savings < 0 ? Colors.red : (savings == 0 ? Colors.grey : Colors.green);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.shade400, statusColor.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusColor.shade700.withOpacity(0.08),
            blurRadius: 17,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('This Month',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(22)),
                child: Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 17),
                    const SizedBox(width: 6),
                    Text(statusText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${spent.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              Text(
                budget > 0 ? '/ ₹${budget.toStringAsFixed(0)}' : '',
                style: const TextStyle(color: Colors.white60, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Savings: ₹${savings.abs().toStringAsFixed(0)}',
                style: TextStyle(
                    color: savingsColor, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              if (savings < 0)
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                    Text(' Overspent',
                        style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              else if (savings == 0)
                Row(
                  children: [
                    const Icon(Icons.money_off, color: Colors.grey, size: 16),
                    Text(' Break-even',
                        style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green, size: 16),
                    Text(' Saved',
                        style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: percentUsed / 100 > 1 ? 1 : percentUsed / 100,
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentUsed.toStringAsFixed(1)}% used',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                budget > 0
                    ? '₹${(budget - spent).toStringAsFixed(0)} left'
                    : 'No budget set',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetModel budget, double spent) {
    final categoryData =
        CategoryData.getCategoryByName(budget.category) ?? CategoryData.categories.last;
    final percent = (spent / budget.limit) * 100;
    final isExceeded = spent > budget.limit;
    final isWarning = spent >= budget.limit * 0.8 && !isExceeded;
    MaterialColor statusColor = Colors.green;
    if (isExceeded) statusColor = Colors.red;
    if (isWarning) statusColor = Colors.orange;

    return Dismissible(
      key: Key(budget.id ?? UniqueKey().toString()),
      background: _buildSwipeBackground(Colors.blue, Icons.edit, 'Edit', Alignment.centerLeft),
      secondaryBackground:
          _buildSwipeBackground(Colors.red, Icons.delete, 'Delete', Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await _deleteBudget(budget);
          return false;
        } else {
          _editBudget(budget);
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: statusColor.withOpacity(0.18), width: 2),
        ),
        child: InkWell(
          onTap: () => _editBudget(budget),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(categoryData['color']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          categoryData['icon'],
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(budget.category,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Text(
                            '${budget.period.toUpperCase()} • ₹${budget.limit.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Spent: ₹${spent.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            )),
                        Text('Left: ₹${(budget.limit - spent).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100 > 1 ? 1 : percent / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editBudget(budget),
                        icon: const Icon(Icons.edit, size: 15),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: Colors.blue.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteBudget(budget),
                        icon: const Icon(Icons.delete, size: 15),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: Colors.red.shade300),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
      Color color, IconData icon, String text, AlignmentGeometry alignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.93),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            alignment == Alignment.centerLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
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
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_outlined, size: 70, color: Colors.grey[400]),
            ),
            const SizedBox(height: 26),
            Text(
              'No budgets yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first budget and start tracking your expenses smarter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How Budgets Work'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Set budgets by category (monthly).\n'
              '• Track your spend and see progress instantly.\n'
              '• Swipe a card right to edit, left to delete.\n'
              '• Tap income summary to manage your incomes.',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('OK'), onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }
}
