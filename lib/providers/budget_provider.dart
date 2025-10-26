import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider with ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;

  // --- NEW: Income Fields ---
  double _personalIncome = 0.0;
  double _familyIncome = 0.0;
  // --- END NEW ---

  // Getters
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- NEW: Income Getters ---
  double get personalIncome => _personalIncome;
  double get familyIncome => _familyIncome;
  double get totalIncome => _personalIncome + _familyIncome;
  // --- END NEW ---

  // Get total budget for current month
  double get totalMonthlyBudget {
    return _budgets
        .where((b) => b.period == 'monthly')
        .fold(0.0, (sum, b) => sum + b.limit);
  }

  // Setters
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // --- NEW: Income Setters (with persistence) ---
  void setPersonalIncome(double value) async {
    _personalIncome = value;
    notifyListeners();
    // Persist the value
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('personal_income', value);
  }

  void setFamilyIncome(double value) async {
    _familyIncome = value;
    notifyListeners();
    // Persist the value
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('family_income', value);
  }
  // --- END NEW ---

  // Get budget for specific category
  BudgetModel? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere(
        (b) => b.category == category && b.period == 'monthly',
      );
    } catch (e) {
      return null;
    }
  }

  // Get all budgets by period
  List<BudgetModel> getBudgetsByPeriod(String period) {
    return _budgets.where((b) => b.period == period).toList();
  }

  // Fetch all budgets
  Future<void> fetchBudgets() async {
    try {
      setLoading(true);
      _error = null;

      final response = await ApiService.get(ApiConstants.budgets);

      if (response['success'] == true) {
        _budgets = (response['budgets'] as List)
            .map((b) => BudgetModel.fromJson(b))
            .toList();

        // --- NEW: Load Income after fetching budgets ---
        final prefs = await SharedPreferences.getInstance();
        _personalIncome = prefs.getDouble('personal_income') ?? 0.0;
        _familyIncome = prefs.getDouble('family_income') ?? 0.0;
        // --- END NEW ---
      } else {
        _error = response['message'] ?? 'Failed to fetch budgets';
      }
    } catch (e) {
      _error = 'Failed to load budgets: ${e.toString()}';
    } finally {
      setLoading(false);
    }
  }

  // Add budget
  Future<bool> addBudget(BudgetModel budget) async {
    try {
      setLoading(true);
      _error = null;

      final response = await ApiService.post(
        ApiConstants.budgets,
        budget.toJson(),
      );

      if (response['success'] == true) {
        _budgets.insert(0, BudgetModel.fromJson(response['budget']));
        setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add budget';
        setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to add budget: ${e.toString()}';
      setLoading(false);
      return false;
    }
  }

  // Update budget
  Future<bool> updateBudget(String id, BudgetModel budget) async {
    try {
      setLoading(true);
      _error = null;

      final response = await ApiService.put(
        '${ApiConstants.budgets}/$id',
        budget.toJson(),
      );

      if (response['success'] == true) {
        final index = _budgets.indexWhere((b) => b.id == id);
        if (index != -1) {
          _budgets[index] = BudgetModel.fromJson(response['budget']);
        }
        setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update budget';
        setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to update budget: ${e.toString()}';
      setLoading(false);
      return false;
    }
  }

  // Delete budget
  Future<bool> deleteBudget(String id) async {
    try {
      _error = null;

      final response = await ApiService.delete('${ApiConstants.budgets}/$id');

      if (response['success'] == true) {
        _budgets.removeWhere((b) => b.id == id);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete budget';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete budget: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Check if category has budget
  bool hasBudgetForCategory(String category) {
    return _budgets.any((b) => b.category == category);
  }

  // Get budget usage percentage
  double getBudgetUsagePercentage(String category, double spent) {
    final budget = getBudgetForCategory(category);
    if (budget == null || budget.limit == 0) return 0.0;
    return (spent / budget.limit) * 100;
  }

  // Check if budget is exceeded
  bool isBudgetExceeded(String category, double spent) {
    final budget = getBudgetForCategory(category);
    if (budget == null) return false;
    return spent > budget.limit;
  }

  // Check if approaching budget limit (>80%)
  bool isApproachingLimit(String category, double spent) {
    final budget = getBudgetForCategory(category);
    if (budget == null) return false;
    return spent >= (budget.limit * 0.8) && spent <= budget.limit;
  }

  // Get remaining budget
  double getRemainingBudget(String category, double spent) {
    final budget = getBudgetForCategory(category);
    if (budget == null) return 0.0;
    final remaining = budget.limit - spent;
    return remaining > 0 ? remaining : 0.0;
  }

  // Get budget overspending amount
  double getBudgetOverspent(String category, double spent) {
    final budget = getBudgetForCategory(category);
    if (budget == null) return 0.0;
    final overspent = spent - budget.limit;
    return overspent > 0 ? overspent : 0.0;
  }

  // Get budget status (under/near/over)
  String getBudgetStatus(String category, double spent) {
    if (!hasBudgetForCategory(category)) return 'no-budget';
    
    if (isBudgetExceeded(category, spent)) {
      return 'exceeded';
    } else if (isApproachingLimit(category, spent)) {
      return 'warning';
    } else {
      return 'safe';
    }
  }

  // Get budget status color
  Color getBudgetStatusColor(String category, double spent) {
    final status = getBudgetStatus(category, spent);
    switch (status) {
      case 'exceeded':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'safe':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get all category budgets with spending
  Map<String, Map<String, double>> getBudgetOverview(Map<String, double> categorySpending) {
    final overview = <String, Map<String, double>>{};
    
    for (var budget in _budgets) {
      final spent = categorySpending[budget.category] ?? 0.0;
      overview[budget.category] = {
        'limit': budget.limit,
        'spent': spent,
        'remaining': getRemainingBudget(budget.category, spent),
        'percentage': getBudgetUsagePercentage(budget.category, spent),
      };
    }
    
    return overview;
  }

  // Clear all data (for logout)
  void clear() {
    _budgets = [];
    _error = null;
    _isLoading = false;
    // --- NEW: Clear Income ---
    _personalIncome = 0.0;
    _familyIncome = 0.0;
    // --- END NEW ---
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}