enum SesionEstado { programada, realizada, cancelada }

/// Sesión fotográfica agendada.
class Sesion {
  const Sesion({
    required this.inicio,
    required this.duracionMin,
    required this.lugar,
    required this.cliente,
    required this.descripcion,
    required this.fotografo,
    required this.estado,
    this.pago = '',
    this.precio,
    this.destacada = false,
    this.motivo,
    this.codigo,
    this.equipo,
    this.servicio,
    this.id,
    this.clienteId,
    this.servicioId,
  });

  /// Id de la reserva en la API (null en las sesiones de ejemplo).
  final int? id;

  /// Ids del cliente y del servicio en la API (para reagendar o editar la reserva).
  final int? clienteId;
  final int? servicioId;

  /// Nombre del servicio del catálogo ("Sesión familiar"). [descripcion] es el
  /// detalle de esta sesión ("Sesión familiar (4 integrantes + mascota)").
  final String? servicio;

  String get nombreServicio => servicio ?? descripcion;

  /// Código de reserva: "#RSV-2026-042".
  final String? codigo;

  /// Cámara y lente asignados: "A7IV / 50mm 1.2".
  final String? equipo;

  /// Fecha y hora de inicio.
  final DateTime inicio;
  final int duracionMin;

  /// Set o locación: "Estudio A", "Ciclorama Blanco"…
  final String lugar;
  final String cliente;
  final String descripcion;
  final String fotografo;

  /// Medio de pago: "Efectivo", "Transferencia".
  final String pago;

  /// Precio en COP. Nulo en sesiones canceladas.
  final int? precio;
  final SesionEstado estado;

  /// Sesión en curso o próxima: se resalta con barra de acento.
  final bool destacada;

  /// Motivo de cancelación.
  final String? motivo;

  DateTime get fin => inicio.add(Duration(minutes: duracionMin));

  bool get cancelada => estado == SesionEstado.cancelada;

  /// Programada y ocurriendo en [ahora].
  bool enCursoEn(DateTime ahora) =>
      estado == SesionEstado.programada && !ahora.isBefore(inicio) && ahora.isBefore(fin);

  Sesion copyWith({
    DateTime? inicio,
    int? duracionMin,
    String? lugar,
    String? fotografo,
    SesionEstado? estado,
    bool? destacada,
    String? motivo,
  }) {
    return Sesion(
      inicio: inicio ?? this.inicio,
      duracionMin: duracionMin ?? this.duracionMin,
      lugar: lugar ?? this.lugar,
      cliente: cliente,
      descripcion: descripcion,
      fotografo: fotografo ?? this.fotografo,
      estado: estado ?? this.estado,
      pago: pago,
      precio: precio,
      destacada: destacada ?? this.destacada,
      motivo: motivo ?? this.motivo,
      codigo: codigo,
      equipo: equipo,
      servicio: servicio,
      id: id,
      clienteId: clienteId,
      servicioId: servicioId,
    );
  }
}
