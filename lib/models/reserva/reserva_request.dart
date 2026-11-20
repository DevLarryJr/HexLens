import '../../extensions/date_time_extensions.dart';

class CrearReservaRequest {
  final DateTime fecha;
  final int servicioId;
  final int clienteId;

  const CrearReservaRequest({
    required this.fecha,
    required this.servicioId,
    required this.clienteId,
  });

  Map<String, dynamic> toJson() => {
    'Fecha': fecha.toIsoDateTimeString(),
    'ServicioId': servicioId,
    'ClienteId': clienteId,
  };
}

class EditarReservaRequest {
  final DateTime fecha;
  final int servicioId;

  const EditarReservaRequest({required this.fecha, required this.servicioId});

  Map<String, dynamic> toJson() => {
    'Fecha': fecha.toIsoDateTimeString(),
    'ServicioId': servicioId,
  };
}
