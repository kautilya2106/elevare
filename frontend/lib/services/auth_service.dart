// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      _token = response['token'];
      _user = response['user'];
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
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  void logout() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}