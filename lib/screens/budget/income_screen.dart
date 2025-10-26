import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final personalIncome = budgetProvider.personalIncome;
    final familyIncome = budgetProvider.familyIncome;
    final totalIncome = personalIncome + familyIncome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Row
            _buildSummaryCards(personalIncome, familyIncome, totalIncome),
            const SizedBox(height: 32),

            // Personal Income Card
            _buildIncomeCard(
              title: 'Personal Income',
              amount: personalIncome,
              icon: Icons.person,
              color: Colors.blue,
              onEdit: () => _showIncomeDialog(
                context,
                'Personal Income',
                personalIncome,
                budgetProvider.setPersonalIncome,
              ),
            ),
            const SizedBox(height: 18),

            // Family Income Card
            _buildIncomeCard(
              title: 'Family Income',
              amount: familyIncome,
              icon: Icons.family_restroom,
              color: Colors.green,
              onEdit: () => _showIncomeDialog(
                context,
                'Family Income',
                familyIncome,
                budgetProvider.setFamilyIncome,
              ),
            ),
            const SizedBox(height: 32),

            // Pie Chart (if chart package available)
            // _buildIncomePieChart(personalIncome, familyIncome), // Uncomment if using charts
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double personalIncome, double familyIncome, double totalIncome) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _animatedSummaryCard('Personal', personalIncome, Icons.person, Colors.blue),
        _animatedSummaryCard('Family', familyIncome, Icons.family_restroom, Colors.green),
        _animatedSummaryCard('Total', totalIncome, Icons.savings, Colors.purple),
      ],
    );
  }

  Widget _animatedSummaryCard(String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: "Edit $title",
              child: IconButton(
                icon: Icon(Icons.edit, color: color),
                onPressed: onEdit,
              ),
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
        title: const Text('About Income Calculation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Your total income (Personal + Family) is used for budgeting.\n'
              '• Set and update each section as needed.\n'
              '• Budgets can be set as percentages or fixed amounts relative to your total income.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('OK'), onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }

  Future<void> _showIncomeDialog(
    BuildContext context,
    String title,
    double currentAmount,
    Function(double) onSave,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: currentAmount > 0 ? currentAmount.toStringAsFixed(0) : '',
    );
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Set $title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '₹',
              border: const OutlineInputBorder(),
              errorText: errorText,
            ),
            onChanged: (val) {
              setState(() {
                errorText = (double.tryParse(val) ?? -1) < 0 ? 'Enter a valid amount' : null;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = controller.text;
                final amount = double.tryParse(input);
                if (amount == null || amount < 0) {
                  setState(() {
                    errorText = 'Please enter a valid non-negative amount';
                  });
                } else {
                  onSave(amount);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
