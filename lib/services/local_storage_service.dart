// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static Future<void> cacheExpenses(List<Map<String, dynamic>> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_expenses', jsonEncode(expenses));
  }
  
  static Future<List<Map<String, dynamic>>?> getCachedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_expenses');
    if (cached != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cached));
    }
    return null;
  }
}
