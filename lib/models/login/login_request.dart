class LoginRequest {
  final String usuario;
  final String clave;

  const LoginRequest({required this.usuario, required this.clave});

  Map<String, dynamic> toJson() => {'Usuario': usuario.trim(), 'Clave': clave};
}
