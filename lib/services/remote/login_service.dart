import '../../config/api_paths.dart';
import '../../config/app_config.dart';
import '../../models/login/login_request.dart';
import '../../models/login/login_response.dart';
import '../local/secure_storage_service.dart';
import '../local/sesion_actual.dart';
import '../local/user_preferences_service.dart';
import 'api_service.dart';
import 'authenticated_api.dart';

class LoginService {
  LoginService({ApiService? api})
    : _api = api ?? ApiService(baseUrl: AppConfig.apiBaseUrl, timeout: const Duration(seconds: 90));

  final ApiService _api;
  final _storage = const SecureStorageService();
  final _preferencias = UsuarioPreferencesService();

  String get apiBaseUrl => _api.baseUrl;

  Future<LoginResponse> login(LoginRequest request, {bool recordar = true}) async {
    final Object? json;
    try {
      json = await _api.post(ApiPaths.login, body: request.toJson());
    } on ApiException catch (e) {
      final cuerpo = e.data;
      final mensajeApi = cuerpo is Map ? cuerpo['message'] : null;
      if (e.isUnauthorized && mensajeApi is! String) {
        throw ApiException('Usuario o clave incorrectos.', statusCode: e.statusCode, data: e.data);
      }
      rethrow;
    }

    final login = parseJsonObject(json, LoginResponse.fromJson);

    if (recordar) {
      await _storage.saveSesion(login);
    } else {
      await _storage.clear();
    }
    await _preferencias.guardarUsuario(
      id: login.usuario,
      rol: login.rol,
      empresa: login.empresa ?? '',
    );
    SesionActual.iniciar(login);

    return login;
  }

  Future<void> logout() => SesionActual.cerrar();
}
