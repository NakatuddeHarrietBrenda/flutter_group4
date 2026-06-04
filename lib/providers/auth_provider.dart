import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;
  String? _name;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuestMode = false;

  final String _baseUrl = 'https://testing.rasmuspharmaceuticals.com/api/v1';

  // Getters
  bool get isLoggedIn => _token != null && _token!.isNotEmpty && !_isGuestMode;
  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGuestMode => _isGuestMode;

  // Added for splash screen session restore check
  bool get isInitialising => false;

  AuthProvider() {
    loadAuthData();
  }

  // Load token and user details from SharedPreferences
  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuestMode = prefs.getBool('is_guest_mode') ?? false;
    
    if (!_isGuestMode) {
      _token = prefs.getString('auth_token');
      _email = prefs.getString('user_email');
      _name = prefs.getString('user_name');
    }
    notifyListeners();
  }

  // Set Guest Mode
  Future<void> setGuestMode() async {
    _isGuestMode = true;
    _token = null;
    _email = null;
    _name = null;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_mode', true);
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    notifyListeners();
  }

  // Clear authentication data (Logout)
  Future<void> logout() async {
    _token = null;
    _email = null;
    _name = null;
    _isGuestMode = false;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('is_guest_mode');
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Register ────────────────────────────────────────────────────────────────
  // POST /auth/register
  // Body: { name, email (or contact), password }
  Future<bool> register({
    required String name,
    required String emailOrContact,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': emailOrContact,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Some APIs return a token on register — handle both cases
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final token = responseData['token'] ??
            responseData['access_token'] ??
            responseData['data']?['token'];

        if (token != null) {
          // Auto-login after registration if token is returned
          _isGuestMode = false;
          _token = token;
          _email = emailOrContact;
          _name = name;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('is_guest_mode');
          await prefs.setString('auth_token', token);
          await prefs.setString('user_email', emailOrContact);
          await prefs.setString('user_name', name);
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Attempt auto-login in the background since no token was returned directly
          _isLoading = false;
          final loginSuccess = await login(
            emailOrContact: emailOrContact,
            password: password,
          );
          return loginSuccess;
        }
      } else if (response.statusCode == 409) {
        _errorMessage = 'An account with this email already exists.';
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Please check your input details.';
      } else {
        _errorMessage = 'Registration failed. Please try again.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unable to connect to server. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────
  // POST /auth/login
  // Expects email or contact and password, extracts and persists token
  Future<bool> login({
    required String emailOrContact,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': emailOrContact,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract token from common response shapes
        String? token;
        if (responseData.containsKey('token')) {
          token = responseData['token'];
        } else if (responseData.containsKey('data') &&
            responseData['data'].containsKey('token')) {
          token = responseData['data']['token'];
        } else if (responseData.containsKey('access_token')) {
          token = responseData['access_token'];
        }

        // Extract user data
        String? userName;
        String? userEmail;
        if (responseData.containsKey('data')) {
          userName = responseData['data']['name'] ??
              (responseData['data']['user'] != null
                  ? responseData['data']['user']['name']
                  : null);
          userEmail = responseData['data']['email'] ?? emailOrContact;
        }

        if (token != null) {
          _isGuestMode = false;
          _token = token;
          _email = userEmail ?? emailOrContact;
          _name = userName;

          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('is_guest_mode');
          await prefs.setString('auth_token', token);
          await prefs.setString('user_email', _email!);
          if (userName != null) {
            await prefs.setString('user_name', userName);
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Invalid server response. Token not found.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Invalid email/phone or password. Please try again.';
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Please check your input format.';
      } else {
        _errorMessage = 'Login failed. Please check your credentials and try again.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unable to connect to server. Please check your internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}