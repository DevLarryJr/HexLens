import '../utils/formato.dart' as fmt;

/// [nuevo]: recién registrado, todavía sin sesiones.
enum EstadoCliente { frecuente, programada, activaHoy, realizada, nuevo }

/// Cliente del estudio.
class Cliente {
  const Cliente({
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.email,
    required this.estado,
    required this.detalle,
    this.foto,
    this.sesiones = 0,
    this.programadas = 0,
    this.set,
    this.ciudad,
    this.id,
  });

  /// Id del cliente en la API (null en los clientes de ejemplo o guardados solo en el celular).
  final int? id;

  /// Ciudad de expedición del documento: "Bogotá D.C.".
  final String? ciudad;

  final String nombre;

  /// Cédula: "C.C. 1.025.340.890". Identifica al cliente.
  final String documento;
  final String telefono;
  final String email;
  final EstadoCliente estado;

  /// Resumen de su sesión más relevante (última, próxima o en curso).
  final String detalle;

  /// Archivo dentro de `assets/images/`. Sin foto se muestran las iniciales.
  final String? foto;

  /// Sesiones históricas (se muestran en los clientes frecuentes).
  final int sesiones;

  /// Sesiones programadas pendientes.
  final int programadas;

  /// Set donde está la sesión activa de hoy.
  final String? set;

  /// Datos básicos para guardarlo en el celular (los clientes registrados no tienen foto ni sesiones).
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'documento': documento,
        'telefono': telefono,
        'email': email,
        'estado': estado.name,
        'detalle': detalle,
        'ciudad': ?ciudad,
        'id': ?id,
      };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        nombre: json['nombre'] as String,
        documento: json['documento'] as String,
        telefono: json['telefono'] as String,
        email: json['email'] as String? ?? '',
        estado: EstadoCliente.values.asNameMap()[json['estado']] ?? EstadoCliente.nuevo,
        detalle: json['detalle'] as String? ?? '',
        ciudad: json['ciudad'] as String?,
        id: json['id'] as int?,
      );

  /// "Andrés Molina" → "AM".
  String get iniciales => fmt.iniciales(nombre);

  /// Coincide por nombre (sin importar tildes), cédula o teléfono.
  bool coincide(String consulta) {
    final q = fmt.sinTildes(consulta.trim());
    if (q.isEmpty) return true;
    final digitos = fmt.soloDigitos(q);
    return fmt.sinTildes(nombre).contains(q) ||
        (digitos.isNotEmpty &&
            (fmt.soloDigitos(documento).contains(digitos) || fmt.soloDigitos(telefono).contains(digitos)));
  }
}
