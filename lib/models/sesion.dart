import '../extensions/date_time_extensions.dart';
import '../utils/formato.dart';
import 'common/json_utils.dart';

enum SesionEstado { programada, realizada, cancelada }

SesionEstado estadoDesdeApi(Object? v) {
  final e = sinTildes('${v ?? ''}');
  if (e.contains('cancel') || e.contains('anul')) return SesionEstado.cancelada;
  if (e.contains('atend') || e.contains('complet') || e.contains('realiz') || e.contains('finaliz')) {
    return SesionEstado.realizada;
  }
  return SesionEstado.programada;
}

typedef NombreCliente = String Function(int? id);

typedef ServicioPorId = ({String nombre, int duracion, int precio})? Function(int? id);

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

  factory Sesion.fromJson(Map<String, dynamic> json, {NombreCliente? nombreCliente, ServicioPorId? servicioPorId}) {
    final cliente = primerCampo(json, ['cliente', 'clienteNombre', 'nombreCliente']);
    final servicio = primerCampo(json, ['servicio', 'servicioNombre', 'nombreServicio']);
    final profesional = primerCampo(json, ['profesional', 'profesionalNombre', 'nombreProfesional', 'fotografo']);
    final clienteId = parseApiInt(primerCampo(json, ['clienteId']) ?? (cliente is Map ? campo(cliente, 'id') : null));
    final servicioId =
        parseApiInt(primerCampo(json, ['servicioId']) ?? (servicio is Map ? campo(servicio, 'id') : null));
    final delCatalogo = servicioPorId?.call(servicioId);

    var nombreDelCliente = nombreDe(cliente);
    if (nombreDelCliente.isEmpty) nombreDelCliente = nombreCliente?.call(clienteId) ?? 'Cliente';
    var nombreDelServicio = servicio is Map ? '${campo(servicio, 'nombre') ?? ''}' : nombreDe(servicio);
    if (nombreDelServicio.isEmpty) nombreDelServicio = delCatalogo?.nombre ?? 'Servicio';
    final precio = parseApiInt(
          primerCampo(json, ['precio', 'valor', 'total']) ?? (servicio is Map ? campo(servicio, 'precio') : null),
        ) ??
        delCatalogo?.precio;
    final id = parseApiInt(primerCampo(json, ['id', 'reservaId']));
    final dia = fechaDesdeApi(primerCampo(json, ['fecha', 'fechaHora', 'fechaInicio', 'inicio'])) ?? DateTime(2000);
    final horaInicio = minutosDeHora(campo(json, 'horaInicio'));
    final horaFin = minutosDeHora(campo(json, 'horaFin'));
    final inicio = horaInicio == null ? dia : DateTime(dia.year, dia.month, dia.day, 0, horaInicio);
    final duracion =
        parseApiInt(primerCampo(json, ['duracion']) ?? (servicio is Map ? campo(servicio, 'duracion') : null)) ??
            (horaInicio != null && horaFin != null && horaFin > horaInicio ? horaFin - horaInicio : null) ??
            delCatalogo?.duracion ??
            60;
    final estado = estadoDesdeApi(campo(json, 'estado'));

    return Sesion(
      id: id,
      clienteId: clienteId,
      servicioId: servicioId,
      codigo: id == null ? null : '#RSV-${inicio.year}-${id.toString().padLeft(3, '0')}',
      inicio: inicio,
      duracionMin: duracion,
      lugar: '${primerCampo(json, ['lugar', 'sede', 'set']) ?? 'Estudio'}',
      cliente: nombreDelCliente,
      servicio: nombreDelServicio,
      descripcion: nombreDelServicio,
      fotografo: nombreDe(profesional).isEmpty ? 'Por asignar' : nombreDe(profesional),
      pago: '${primerCampo(json, ['medioPago', 'pago']) ?? ''}',
      precio: estado == SesionEstado.cancelada ? null : precio,
      estado: estado,
      motivo: estado == SesionEstado.cancelada ? 'Reserva cancelada' : null,
    );
  }

  final int? id;

  final int? clienteId;
  final int? servicioId;

  final String? servicio;

  String get nombreServicio => servicio ?? descripcion;

  final String? codigo;

  final String? equipo;

  final DateTime inicio;
  final int duracionMin;

  final String lugar;
  final String cliente;
  final String descripcion;
  final String fotografo;

  final String pago;

  final int? precio;
  final SesionEstado estado;

  final bool destacada;

  final String? motivo;

  DateTime get fin => inicio.add(Duration(minutes: duracionMin));

  bool get cancelada => estado == SesionEstado.cancelada;

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
