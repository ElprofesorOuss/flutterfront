class FakeAuthRepository {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return email == 'medecin@burn.center' && password == '123456';
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}