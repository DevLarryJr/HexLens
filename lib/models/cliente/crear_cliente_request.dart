import '../../extensions/date_time_extensions.dart';
import '../../utils/formato.dart';

class CrearClienteRequest {
  final String documento;
  final String nombres;
  final String apellidos;
  final String celular;
  final String correo;
  final DateTime? fechaNacimiento;

  const CrearClienteRequest({
    required this.documento,
    required this.nombres,
    required this.apellidos,
    required this.celular,
    this.correo = '',
    this.fechaNacimiento,
  });

  Map<String, dynamic> toJson() => {
    'Documento': soloDigitos(documento),
    'Nombres': nombres.trim(),
    'Apellidos': apellidos.trim(),
    'Celular': soloDigitos(celular),
    if (correo.trim().isNotEmpty) 'Correo': correo.trim(),
    if (fechaNacimiento != null) 'FechaNacimiento': fechaNacimiento!.toIsoDateString(),
  };
}
