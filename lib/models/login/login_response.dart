import 'dart:convert';

class LoginResponse {
  final String accessToken;

  final String usuario;

  final String rol;
  final String? empresaId;

  final String? empresa;
  final DateTime? vence;

  const LoginResponse({
    required this.accessToken,
    required this.usuario,
    required this.rol,
    this.empresaId,
    this.empresa,
    this.vence,
  });

  bool get esGestor {
    final r = rol.toLowerCase();
    return r.contains('gestor') || r.contains('admin');
  }

  bool get tieneAcceso {
    final hasta = vence;
    return accessToken.isNotEmpty && (hasta == null || hasta.isAfter(DateTime.now()));
  }

  Map<String, dynamic> toJson() => {'accessToken': accessToken};

  String encode() => jsonEncode(toJson());

  static LoginResponse? tryDecode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? LoginResponse.fromJson(json) : null;
    } on FormatException {
      return null;
    }
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final datos = json['data'] is Map ? json['data'] as Map : const {};
    final token = json['accessToken'] ?? json['token'] ?? datos['accessToken'] ?? datos['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('La API no devolvió un token de acceso.');
    }
    return LoginResponse.desdeToken(token);
  }

  factory LoginResponse.desdeToken(String token) {
    final partes = token.split('.');
    Map<String, dynamic> datos = const {};
    if (partes.length == 3) {
      try {
        datos = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(partes[1])))) as Map<String, dynamic>;
      } on FormatException {
        datos = const {};
      }
    }
    final rol = datos['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? datos['role'] ?? datos['rol'];
    final exp = datos['exp'];
    return LoginResponse(
      accessToken: token,
      usuario: '${datos['usuario'] ?? datos['sub'] ?? ''}',
      rol: '${rol ?? ''}',
      empresaId: datos['empresaId']?.toString(),
      empresa: datos['empresaNombre']?.toString(),
      vence: exp is num ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000) : null,
    );
  }
}
