import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;
  Map<String, double> _categoryTotals = {};
  double _totalExpenses = 0.0;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, double> get categoryTotals => _categoryTotals;
  double get totalExpenses => _totalExpenses;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Fetch expenses
  Future<void> fetchExpenses() async {
    try {
      setLoading(true);
      _error = null;

      final response = await ApiService.get(ApiConstants.expenses);
      
      if (response['success'] == true) {
        _expenses = (response['expenses'] as List)
            .map((e) => ExpenseModel.fromJson(e))
            .toList();
        _calculateTotals();
      } else {
        _error = response['message'] ?? 'Failed to fetch expenses';
      }
    } catch (e) {
      _error = 'Failed to load expenses: ${e.toString()}';
    } finally {
      setLoading(false);
    }
  }

  // Add expense
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      setLoading(true);
      _error = null;

      final response = await ApiService.post(
        ApiConstants.expenses,
        expense.toJson(),
      );

      if (response['success'] == true) {
        _expenses.insert(0, ExpenseModel.fromJson(response['expense']));
        _calculateTotals();
        setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add expense';
        setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to add expense: ${e.toString()}';
      setLoading(false);
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense(String id, ExpenseModel expense) async {
    try {
      setLoading(true);
      _error = null;

      final response = await ApiService.put(
        '${ApiConstants.expenses}/$id',
        expense.toJson(),
      );

      if (response['success'] == true) {
        final index = _expenses.indexWhere((e) => e.id == id);
        if (index != -1) {
          _expenses[index] = ExpenseModel.fromJson(response['expense']);
          _calculateTotals();
        }
        setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update expense';
        setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to update expense: ${e.toString()}';
      setLoading(false);
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      _error = null;

      final response = await ApiService.delete('${ApiConstants.expenses}/$id');

      if (response['success'] == true) {
        _expenses.removeWhere((e) => e.id == id);
        _calculateTotals();
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete expense';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete expense: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Calculate totals
  void _calculateTotals() {
    _totalExpenses = 0.0;
    _categoryTotals.clear();

    for (var expense in _expenses) {
      _totalExpenses += expense.amount;
      _categoryTotals[expense.category] =
          (_categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
  }

  // Get expenses by date range
  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get expenses by category
  List<ExpenseModel> getExpensesByCategory(String category) {
    return _expenses.where((e) => e.category == category).toList();
  }

  // Get current month expenses
  List<ExpenseModel> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }

  // Get current week expenses
  List<ExpenseModel> getCurrentWeekExpenses() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    return getExpensesByDateRange(startOfWeek, endOfWeek);
  }

  // Get today expenses
  List<ExpenseModel> getTodayExpenses() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getExpensesByDateRange(startOfDay, endOfDay);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data (for logout)
  void clear() {
    _expenses = [];
    _categoryTotals = {};
    _totalExpenses = 0.0;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
