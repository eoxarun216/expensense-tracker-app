import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ REMOVE constructor - no auto-check
  // AuthProvider() {
  //   _checkAuthentication();
  // }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await AuthService.login(email, password);
      _user = UserModel.fromJson(response['user']);
      _token = response['token'];
      _isAuthenticated = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
 
  // Signup
  Future<bool> signup(String name, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await AuthService.signup(name, email, password);
      _user = UserModel.fromJson(response['user']);
      _token = response['token'];
      _isAuthenticated = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

// Try auto login on app start
Future<bool> tryAutoLogin() async {
  try {
    final token = await AuthService.getStoredToken();
    
    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }

    _token = token;
    
    // Try to get user profile
    final response = await ApiService.get(ApiConstants.me).timeout(
      const Duration(seconds: 5),
    );
    
    if (response['success'] == true) {
      _user = UserModel.fromJson(response['user']);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
  } catch (e) {
    print('Auto-login error: $e');
    // Clear invalid token
    await AuthService.clearToken();
  }
  
  _isAuthenticated = false;
  notifyListeners();
  return false;
}

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get token for API calls
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }
}
