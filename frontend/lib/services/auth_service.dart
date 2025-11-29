// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  
  AuthService() {
    _loadAuth();
  }
  
  Future<void> _loadAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUser = prefs.getString(_userKey);
      
      if (savedToken != null) {
        _token = savedToken;
        if (savedUser != null) {
          _user = json.decode(savedUser) as Map<String, dynamic>;
        }
        notifyListeners();
      }
    } catch (e) {
      // If shared_preferences is not available, continue without saved auth
      _token = null;
      _user = null;
    }
  }
  
  Future<void> _saveAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
        if (_user != null) {
          await prefs.setString(_userKey, json.encode(_user));
        }
      } else {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
      }
    } catch (e) {
      // Ignore if shared_preferences is not available
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      _token = response['token'];
      _user = response['user'];
      await _saveAuth();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> register(String email, String username, String password, String fullName) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'email': email,
        'username': username,
        'password': password,
        'fullName': fullName,
      });
      
      _token = response['token'];
      _user = response['user'];
      await _saveAuth();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _saveAuth();
    notifyListeners();
  }
}