/// `enTurno`: en una sesión ahora mismo; `fueraDeTurno`: fuera del horario laboral (noche o domingo).
enum EstadoFotografo { enTurno, disponible, almuerzo, inactivo, fueraDeTurno }

/// Fotógrafo del staff del estudio.
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

  /// Id en la API (null en los fotógrafos de ejemplo).
  final int? id;

  /// Nombre completo: "Laura Méndez".
  final String nombre;

  /// Nombres y apellidos por separado, como los guarda la API (null en los de ejemplo).
  final String? nombres;
  final String? apellidos;

  /// Cédula: "C.C. 52.890.123". Identifica al fotógrafo.
  final String documento;

  /// Archivo dentro de `assets/images/`; null si no tiene foto (se muestran sus iniciales).
  final String? foto;

  /// Nombre de su especialidad: Retratos, Familiar, Productos o Editorial.
  final String especialidad;

  /// Id de la especialidad en la API (null en los de ejemplo).
  final int? especialidadId;

  /// Calificación de 0 a 5. Nula si aún no tiene.
  final double? score;
  final int comisionPct;

  /// Cámara y lente en custodia ('' si no se ha registrado).
  final String equipo;
  final EstadoFotografo estado;

  bool get activo => estado != EstadoFotografo.inactivo;
}
