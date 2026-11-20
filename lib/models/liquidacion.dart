import '../extensions/date_time_extensions.dart';
import '../utils/formato.dart';
import 'common/json_utils.dart';
import 'fotografo.dart';

class SesionLiquidada {
  const SesionLiquidada(this.cliente, this.codigo, this.servicio, this.fecha, this.tarifa);

  factory SesionLiquidada.fromJson(Map<String, dynamic> json) {
    final cliente = primerCampo(json, ['cliente', 'clienteNombre', 'nombreCliente']);
    final servicio = primerCampo(json, ['servicio', 'servicioNombre', 'nombreServicio']);
    final id = parseApiInt(primerCampo(json, ['reservaId', 'id']));
    final fecha = fechaDesdeApi(primerCampo(json, ['fecha', 'fechaReserva', 'fechaHora'])) ?? DateTime(2000);
    return SesionLiquidada(
      nombreDe(cliente).isEmpty ? 'Cliente' : nombreDe(cliente),
      id == null ? '' : '#RSV-${fecha.year}-${id.toString().padLeft(3, '0')}',
      nombreDe(servicio).isEmpty ? 'Servicio' : nombreDe(servicio),
      fecha,
      parseApiInt(primerCampo(json, ['tarifa', 'precio', 'valor', 'total'])) ??
          (servicio is Map ? parseApiInt(campo(servicio, 'precio')) : null) ??
          0,
    );
  }

  final String cliente;

  final String codigo;

  final String servicio;
  final DateTime fecha;

  final int tarifa;

  String get detalle => '$servicio • ${diaMes(fecha)}';
}

class Liquidacion {
  const Liquidacion(this.fotografo, this.sesiones);

  final Fotografo fotografo;
  final List<SesionLiquidada> sesiones;

  int get tasa => fotografo.comisionPct;
  int get base => sesiones.fold(0, (a, s) => a + s.tarifa);
  int get comision => comisionDe(base);
  int comisionDe(int tarifa) => tarifa * tasa ~/ 100;

  Liquidacion entre(DateTime inicio, DateTime fin) => Liquidacion(fotografo, [
        for (final s in sesiones)
          if (!s.fecha.isBefore(inicio) && !s.fecha.isAfter(fin)) s,
      ]);
}
