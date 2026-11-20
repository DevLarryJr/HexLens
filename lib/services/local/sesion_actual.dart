import '../../models/login/login_response.dart';
import 'secure_storage_service.dart';
import 'user_preferences_service.dart';

class SesionActual {
  SesionActual._();

  static const _storage = SecureStorageService();

  static LoginResponse? _usuario;
  static LoginResponse? get usuario => _usuario;

  static bool get conectada => _usuario != null;

  static String? get token => _usuario?.accessToken;

  static void iniciar(LoginResponse usuario) => _usuario = usuario;

  static Future<LoginResponse?> restaurar() async {
    final guardada = await _storage.readSesion();
    if (guardada == null) {
      await _storage.clear();
      return null;
    }
    return _usuario = guardada;
  }

  static Future<void> cerrar() async {
    _usuario = null;
    await _storage.clear();
    await UsuarioPreferencesService().eliminarUsuario();
  }
}
