import 'package:burning2026/core/models/user.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<void> logout();
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email == 'medecin@burn.center' && password == '123456') {
      return const User(
        id: 'U001',
        email: 'medecin@burn.center',
        nom: 'Martin',
        prenom: 'Sarah',
        role: 'Médecin chef',
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}