import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String?> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    String? message = await _authService.signUp(email, password);

    _isLoading = false;
    notifyListeners();

    return message;
  }
}
