import '../../extensions/date_time_extensions.dart';
import '../../utils/formato.dart';

class CrearProfesionalRequest {
  final String documento;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;
  final int porcentaje;
  final bool activo;
  final int especialidadId;

  const CrearProfesionalRequest({
    required this.documento,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.porcentaje,
    required this.activo,
    required this.especialidadId,
  });

  Map<String, dynamic> toJson() => {
    'Documento': soloDigitos(documento),
    'Nombres': nombres.trim(),
    'Apellidos': apellidos.trim(),
    'FechaNacimiento': fechaNacimiento.toIsoDateString(),
    'Porcentaje': porcentaje,
    'Estado': activo,
    'Especialidad': especialidadId,
  };
}

class EditarProfesionalRequest {
  final String? nombres;
  final String? apellidos;
  final int? porcentaje;
  final int? especialidadId;
  final bool? activo;

  const EditarProfesionalRequest({
    this.nombres,
    this.apellidos,
    this.porcentaje,
    this.especialidadId,
    this.activo,
  });

  Map<String, dynamic> toJson() => {
    if (nombres != null) 'Nombres': nombres,
    if (apellidos != null) 'Apellidos': apellidos,
    if (porcentaje != null) 'Porcentaje': porcentaje,
    if (especialidadId != null) 'Especialidad': especialidadId,
    if (activo != null) 'Estado': activo,
  };
}
