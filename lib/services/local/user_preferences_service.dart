import 'package:shared_preferences/shared_preferences.dart';

class UsuarioPreferencesService {
  Future<void> guardarUsuario({
    required String id,
    required String rol,
    required String empresa,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('usuario_identificacion', id);
    await prefs.setString('usuario_rol', rol);
    await prefs.setString('usuario_empresa', empresa);
  }

  Future<String?> obtenerId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('usuario_identificacion');
  }

  Future<String?> obtenerRol() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('usuario_rol');
  }

  Future<String?> obtenerEmpresa() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('usuario_empresa');
  }

  Future<void> eliminarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('usuario_identificacion');
    await prefs.remove('usuario_rol');
    await prefs.remove('usuario_empresa');
  }
}
