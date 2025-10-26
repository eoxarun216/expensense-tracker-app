import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class AuthService {
  // Get stored token
  static Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  // Save token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (e) {
      // Handle error
    }
  }

  // Clear token
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      // Handle error
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        ApiConstants.login,
        {'email': email, 'password': password},
      );

      if (response['success'] == true && response['token'] != null) {
        await saveToken(response['token']);
        return response;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConstants.signup,
        {'name': name, 'email': email, 'password': password},
      );

      if (response['success'] == true && response['token'] != null) {
        await saveToken(response['token']);
        return response;
      } else {
        throw Exception(response['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout
  static Future<void> logout() async {
    await clearToken();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  // Get user profile
  static Future<UserModel?> getProfile() async {
    try {
      final token = await getStoredToken();
      if (token == null) return null;

      final response = await ApiService.get(ApiConstants.me);
      
      if (response['success'] == true) {
        return UserModel.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
