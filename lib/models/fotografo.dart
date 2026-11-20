import '../utils/formato.dart';
import 'common/json_utils.dart';
import 'especialidad.dart';

enum EstadoFotografo { enTurno, disponible, almuerzo, inactivo, fueraDeTurno }

class Fotografo {
  const Fotografo({
    required this.nombre,
    required this.documento,
    required this.especialidad,
    required this.comisionPct,
    required this.estado,
    this.foto,
    this.equipo = '',
    this.score,
    this.id,
    this.especialidadId,
    this.nombres,
    this.apellidos,
  });

  factory Fotografo.fromJson(Map<String, dynamic> json, {required NombreEspecialidad nombreEspecialidad}) {
    final esp = especialidadDeJson(json, nombreEspecialidad);
    final nombres = parseApiText(json, 'nombres');
    final apellidos = parseApiText(json, 'apellidos');
    final documento = soloDigitos(parseApiText(json, 'documento'));
    final activo = campo(json, 'estado');
    return Fotografo(
      id: parseApiInt(campo(json, 'id') ?? campo(json, 'profesionalId')),
      nombre: [nombres, apellidos].where((p) => p.isNotEmpty).join(' '),
      nombres: nombres,
      apellidos: apellidos,
      documento: documento.isEmpty ? '' : 'C.C. ${milesConPunto(documento)}',
      especialidad: esp.nombre,
      especialidadId: esp.id,
      comisionPct: parseApiInt(campo(json, 'porcentaje')) ?? 0,
      estado: activo == false || activo == 0 ? EstadoFotografo.inactivo : EstadoFotografo.disponible,
    );
  }

  final int? id;

  final String nombre;

  final String? nombres;
  final String? apellidos;

  final String documento;

  final String? foto;

  final String especialidad;

  final int? especialidadId;

  final double? score;
  final int comisionPct;

  final String equipo;
  final EstadoFotografo estado;

  bool get activo => estado != EstadoFotografo.inactivo;
}
