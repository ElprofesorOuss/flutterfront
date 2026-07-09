import 'package:flutter/foundation.dart';
import 'package:burning2026/core/models/user.dart';
import 'package:burning2026/mock/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final FakeAuthRepository _repository = FakeAuthRepository();
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final user = await _repository.login(email, password);
    if (user != null) {
      _user = user;
      _loading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Email ou mot de passe incorrect';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
}