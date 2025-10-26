import 'package:flutter/material.dart';
import '../models/budget_model.dart';

class BudgetAlertService {
  // Alert threshold percentages
  static const double warningThreshold = 80.0; // 80%
  static const double criticalThreshold = 100.0; // 100%

  // Get budget status
  static BudgetStatus getBudgetStatus(double spent, double limit) {
    if (limit == 0) return BudgetStatus.noLimit;
    
    final percentage = (spent / limit) * 100;
    
    if (percentage >= criticalThreshold) {
      return BudgetStatus.exceeded;
    } else if (percentage >= warningThreshold) {
      return BudgetStatus.warning;
    } else {
      return BudgetStatus.safe;
    }
  }

  // Get status color
  static Color getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.exceeded:
        return Colors.red.shade600;
      case BudgetStatus.warning:
        return Colors.orange.shade600;
      case BudgetStatus.safe:
        return Colors.green.shade600;
      case BudgetStatus.noLimit:
        return Colors.grey.shade600;
    }
  }

  // Get status icon
  static IconData getStatusIcon(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.exceeded:
        return Icons.error;
      case BudgetStatus.warning:
        return Icons.warning_amber;
      case BudgetStatus.safe:
        return Icons.check_circle;
      case BudgetStatus.noLimit:
        return Icons.info_outline;
    }
  }

  // Get status message
  static String getStatusMessage(BudgetStatus status, String category, double spent, double limit) {
    switch (status) {
      case BudgetStatus.exceeded:
        final overspent = spent - limit;
        return '⚠️ You\'ve exceeded your $category budget by ₹${overspent.toStringAsFixed(0)}!';
      case BudgetStatus.warning:
        final remaining = limit - spent;
        return '⚡ Approaching $category budget limit. ₹${remaining.toStringAsFixed(0)} remaining.';
      case BudgetStatus.safe:
        final remaining = limit - spent;
        return '✅ $category budget on track. ₹${remaining.toStringAsFixed(0)} remaining.';
      case BudgetStatus.noLimit:
        return 'No budget set for $category.';
    }
  }

  // Show snackbar alert
  static void showBudgetSnackbar(
    BuildContext context,
    String category,
    double spent,
    double limit,
    BudgetStatus status,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              getStatusIcon(status),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                getStatusMessage(status, category, spent, limit),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: getStatusColor(status),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to budget screen if needed
            // Navigator.pushNamed(context, '/budget'); // Adjust route as necessary
          },
        ),
      ),
    );
  }

  // Check and alert for all budgets
  static void checkAllBudgets(
    BuildContext context,
    Map<String, double> categorySpending,
    List<BudgetModel> budgets, {
    bool showDialog = false, // Optional: if you want to show dialog instead of snackbar
  }) {
    for (var budget in budgets) {
      final spent = categorySpending[budget.category] ?? 0.0;
      final status = getBudgetStatus(spent, budget.limit);
      
      if (status == BudgetStatus.exceeded || status == BudgetStatus.warning) {
        if (showDialog) {
          // Optional: Show an alert dialog instead of snackbar
          // showDialog(
          //   context: context,
          //   builder: (ctx) => AlertDialog(
          //     title: Text('Budget Alert'),
          //     content: Text(getStatusMessage(status, budget.category, spent, budget.limit)),
          //     actions: [TextButton(child: Text('OK'), onPressed: () => Navigator.pop(context))],
          //   ),
          // );
        } else {
          showBudgetSnackbar(context, budget.category, spent, budget.limit, status);
        }
        // Optionally, return after the first alert to avoid spamming, or remove return to show all alerts
        // return; 
      }
    }
  }
}

// Budget status enum
enum BudgetStatus {
  safe,
  warning,
  exceeded,
  noLimit,
}