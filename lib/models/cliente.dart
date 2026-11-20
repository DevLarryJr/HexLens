import '../utils/formato.dart' as fmt;
import 'common/json_utils.dart';

enum EstadoCliente { frecuente, programada, activaHoy, realizada, nuevo }

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

  final int? id;

  final String? ciudad;

  final String nombre;

  final String documento;
  final String telefono;
  final String email;
  final EstadoCliente estado;

  final String detalle;

  final String? foto;

  final int sesiones;

  final int programadas;

  final String? set;

  factory Cliente.fromJson(Map<String, dynamic> json) {
    final documento = fmt.soloDigitos(parseApiText(json, 'documento'));
    final celular = fmt.soloDigitos(parseApiText(json, 'celular'));
    final nombre = [parseApiText(json, 'nombres'), parseApiText(json, 'apellidos')].where((p) => p.isNotEmpty).join(' ');
    return Cliente(
      id: parseApiInt(campo(json, 'id') ?? campo(json, 'clienteId')),
      nombre: nombre.isEmpty ? parseApiText(json, 'nombre') : nombre,
      documento: documento.isEmpty ? '' : 'C.C. ${fmt.milesConPunto(documento)}',
      telefono: celular.isEmpty ? '' : '+57 ${fmt.telefonoConEspacios(celular)}',
      email: parseApiText(json, 'correo'),
      estado: EstadoCliente.nuevo,
      detalle: 'Cliente registrado en el sistema',
    );
  }

  Map<String, dynamic> toLocalJson() => {
        'nombre': nombre,
        'documento': documento,
        'telefono': telefono,
        'email': email,
        'estado': estado.name,
        'detalle': detalle,
        'ciudad': ?ciudad,
        'id': ?id,
      };

  factory Cliente.fromLocalJson(Map<String, dynamic> json) => Cliente(
        nombre: json['nombre'] as String,
        documento: json['documento'] as String,
        telefono: json['telefono'] as String,
        email: json['email'] as String? ?? '',
        estado: EstadoCliente.values.asNameMap()[json['estado']] ?? EstadoCliente.nuevo,
        detalle: json['detalle'] as String? ?? '',
        ciudad: json['ciudad'] as String?,
        id: json['id'] as int?,
      );

  String get iniciales => fmt.iniciales(nombre);

  bool coincide(String consulta) {
    final q = fmt.sinTildes(consulta.trim());
    if (q.isEmpty) return true;
    final digitos = fmt.soloDigitos(q);
    return fmt.sinTildes(nombre).contains(q) ||
        (digitos.isNotEmpty &&
            (fmt.soloDigitos(documento).contains(digitos) || fmt.soloDigitos(telefono).contains(digitos)));
  }
}
