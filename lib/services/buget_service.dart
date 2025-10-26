import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/budget_model.dart';
import '../utils/constants.dart';

class BudgetService {
  // Get all budgets
  Future<List<BudgetModel>> getBudgets(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/budgets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<BudgetModel> budgets = [];
        if (data['budgets'] != null) {
          for (var item in data['budgets']) {
            budgets.add(BudgetModel.fromJson(item));
          }
        }
        return budgets;
      } else {
        print('Error fetching budgets: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching budgets: $e');
      return [];
    }
  }

  // Create budget
  Future<bool> createBudget(String token, BudgetModel budget) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/budgets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(budget.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error creating budget: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating budget: $e');
      return false;
    }
  }

  // Update budget
  Future<bool> updateBudget(String token, String id, BudgetModel budget) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/budgets/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(budget.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error updating budget: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating budget: $e');
      return false;
    }
  }

  // Delete budget
  Future<bool> deleteBudget(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/budgets/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting budget: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting budget: $e');
      return false;
    }
  }
}
