import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/budget_model.dart';
import '../../providers/budget_provider.dart';
import '../../utils/constants.dart';

class AddBudgetScreen extends StatefulWidget {
  final BudgetModel? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  final _percentageController = TextEditingController();

  String _selectedCategory = 'Groceries';
  String _selectedPeriod = 'monthly';
  bool _isLoading = false;
  // State to track if we are setting budget as a percentage
  bool _isPercentageBased = false; 
  double _totalIncome = 0.0; // Store total income from provider

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      final budgetLimit = widget.budget!.limit;
      _selectedCategory = widget.budget!.category;
      _selectedPeriod = widget.budget!.period;
      // Determine if the existing budget was set as a percentage (you might need to store this flag)
      // For now, assume it's fixed if we don't have the flag stored
      // If you stored a flag like budget.isPercentage, use that instead of false
      _isPercentageBased = false; 
      
      if (_isPercentageBased) {
        _percentageController.text = budgetLimit.toStringAsFixed(0); // Assuming stored as percentage value
      } else {
        _limitController.text = budgetLimit.toString();
      }
    } else {
      _selectedCategory = CategoryData.categories.first['name'];
      // Optionally, set _isPercentageBased to true by default if desired
      // _isPercentageBased = true;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final budgetProvider = context.read<BudgetProvider>();
      // Calculate the final limit based on whether it's percentage or fixed
      double finalLimit;
      if (_isPercentageBased) {
        final percentageValue = double.tryParse(_percentageController.text.trim()) ?? 0.0;
        finalLimit = (_totalIncome * percentageValue) / 100.0;
      } else {
        finalLimit = double.parse(_limitController.text.trim());
      }

      final budget = BudgetModel(
        id: widget.budget?.id,
        userId: '', // ✅ Added required field (backend will override this)
        category: _selectedCategory,
        limit: finalLimit,
        period: _selectedPeriod,
        spent: widget.budget?.spent ?? 0.0,
        // isPercentage: _isPercentageBased, // Add this if you store the flag
      );

      bool success;
      if (widget.budget == null) {
        success = await budgetProvider.addBudget(budget);
      } else {
        success = await budgetProvider.updateBudget(widget.budget!.id!, budget);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.budget == null
                      ? 'Budget added successfully'
                      : 'Budget updated successfully',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to save budget${budgetProvider.error != null ? ': ${budgetProvider.error}' : ''}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    // Update total income from provider
    _totalIncome = budgetProvider.totalIncome; 

    final categoryData = CategoryData.getCategoryByName(_selectedCategory) ??
        CategoryData.categories.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toggle between Fixed Amount and Percentage
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isPercentageBased) {
                            setState(() {
                              _isPercentageBased = false;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isPercentageBased ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isPercentageBased
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Text(
                            'Fixed Amount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isPercentageBased) {
                            setState(() {
                              _isPercentageBased = false;
                            });
                          } else if (_totalIncome > 0) {
                             setState(() {
                               _isPercentageBased = true;
                             });
                          } else {
                             // Show a snackbar if total income is 0
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Set your income first to use percentage-based budgets.'),
                                 backgroundColor: Colors.orange,
                               ),
                             );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isPercentageBased ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isPercentageBased
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Percentage of Income',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isPercentageBased ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Budget Input Field (Amount or Percentage)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(categoryData['color']).withValues(alpha: 0.1),
                      Color(categoryData['color']).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(categoryData['color']).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _isPercentageBased ? 'Percentage of Income' : 'Budget Limit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: IntrinsicWidth(
                            child: TextFormField(
                              controller: _isPercentageBased ? _percentageController : _limitController,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(categoryData['color']),
                              ),
                              decoration: InputDecoration(
                                hintText: _isPercentageBased ? '0' : '0.00',
                                hintStyle: TextStyle(
                                  color: Color(categoryData['color']).withValues(alpha: 0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a ${_isPercentageBased ? 'percentage' : 'limit'}';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                final numValue = double.parse(value);
                                if (numValue <= 0) {
                                  return '${_isPercentageBased ? 'Percentage' : 'Limit'} must be greater than 0';
                                }
                                if (_isPercentageBased && numValue > 100) {
                                  return 'Percentage cannot exceed 100%';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _isPercentageBased ? '%' : '₹',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(categoryData['color']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isPercentageBased && _totalIncome > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '(≈ ₹${((_totalIncome * (double.tryParse(_percentageController.text.trim()) ?? 0.0)) / 100).toStringAsFixed(2)} of ₹${_totalIncome.toStringAsFixed(0)})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),

              // Period Selection
              Text(
                'Period',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildPeriodSelection(),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.budget == null ? Icons.add_circle : Icons.check_circle,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.budget == null ? 'Add Budget' : 'Update Budget',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Delete Button (only for edit mode)
              if (widget.budget != null)
                OutlinedButton(
                  onPressed: () => _showDeleteDialog(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Delete Budget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: CategoryData.categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['name'],
              child: Row(
                children: [
                  Text(
                    category['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(category['name']),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodOption('Monthly', 'monthly'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPeriodOption('Weekly', 'weekly'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPeriodOption('Daily', 'daily'),
        ),
      ],
    );
  }

  Widget _buildPeriodOption(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<BudgetProvider>().deleteBudget(widget.budget!.id!);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Budget deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
