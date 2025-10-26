import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/budget_alert_service.dart';

// Currency formatter for INR
String rupee(double amount) =>
    NumberFormat.simpleCurrency(name: "INR", decimalDigits: 0).format(amount);

class BudgetIndicator extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final bool showDetails;

  const BudgetIndicator({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final status = BudgetAlertService.getBudgetStatus(spent, limit);
    final percentage = limit > 0 ? (spent / limit).clamp(0.0, 2.0) : 0.0;
    final color = BudgetAlertService.getStatusColor(status);
    final isExceeded = status == BudgetStatus.exceeded;

    final bgGradient = LinearGradient(
      colors: status == BudgetStatus.exceeded
          ? [
              color.withValues(alpha: (255 * 0.25).toDouble()),
              Colors.redAccent.withValues(alpha: (255 * 0.25).toDouble())
            ]
          : [
              color.withValues(alpha: (255 * 0.10).toDouble()),
              Colors.grey.withValues(alpha: (255 * 0.03).toDouble())
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Semantics(
      label: '$category spent ${rupee(spent)} out of ${rupee(limit)}. '
          '${isExceeded ? "Over budget!" : "Within budget."}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: (255 * 0.3).toDouble()),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: (255 * 0.06).toDouble()),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Tooltip(
                  message: status == BudgetStatus.exceeded
                      ? 'Exceeded!'
                      : (status == BudgetStatus.warning ? 'Warning' : 'Good'),
                  child: Icon(
                    BudgetAlertService.getStatusIcon(status),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    key: ValueKey<int>((percentage * 100).floor()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (showDetails) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${rupee(spent)} / ${rupee(limit)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      isExceeded
                          ? 'Over by ${rupee(spent - limit)}'
                          : '${rupee(limit - spent)} left',
                      key: ValueKey(isExceeded),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percentage.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value > 1.0 ? 1.0 : value,
                    minHeight: 8.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}