import '../../models/login/login_response.dart';

abstract interface class SessionStorage {
  Future<void> saveToken(String token);
  Future<String?> readToken();

  Future<void> saveSesion(LoginResponse sesion);

  Future<LoginResponse?> readSesion();

  Future<void> clear();
}
