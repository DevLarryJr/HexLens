import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/reservas_api.dart';
import '../core/reloj.dart';
import '../data/mock_clientes.dart';
import '../data/mock_disponibilidad.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_servicios.dart';
import '../models/bloque_horario.dart';
import '../models/cliente.dart';
import '../models/fotografo.dart';
import '../models/servicio.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/reserva/bloque_tile.dart';
import '../widgets/reserva/boton_navegacion.dart';
import '../widgets/reserva/dia_card.dart';
import '../widgets/reserva/reserva_progreso.dart';
import '../widgets/reserva/sesion_configurada_card.dart';
import '../widgets/reserva/turno_info_cards.dart';

/// Figma: "HexLens - Nueva Reserva: Fecha y Hora" (19:1527)
class NuevaReservaFechaScreen extends StatefulWidget {
  const NuevaReservaFechaScreen({super.key, this.onContinuar, this.onSalir, this.servicio, this.cliente});

  /// Sigue a la confirmación con la fecha y hora de inicio elegidas.
  final ValueChanged<DateTime>? onContinuar;

  /// ✕ del header: sale de toda la reserva. "Volver a Servicio" (abajo) regresa al paso anterior.
  final VoidCallback? onSalir;

  /// Servicio elegido en el paso 2. Define la duración de los bloques y la
  /// tarifa. Por defecto, el primero del catálogo (Retrato profesional).
  final Servicio? servicio;

  /// Cliente elegido en el paso 1 (por defecto, el de ejemplo).
  final Cliente? cliente;

  @override
  State<NuevaReservaFechaScreen> createState() => _NuevaReservaFechaScreenState();
}

class _NuevaReservaFechaScreenState extends State<NuevaReservaFechaScreen> {
  /// Días que se ven a la vez en la tira y hasta cuántos días hacia adelante se puede reservar.
  static const _visibles = 4;
  static const _diasAdelante = 180;

  /// Primer día de la tira al abrir (ayer, como referencia); no se puede retroceder más.
  /// Se fija una vez para que no cambie si se cruza la medianoche con la pantalla abierta.
  late final DateTime _primerDia = diasReserva.first;
  late final DateTime _ultimoDia = Reloj.dia(_diasAdelante);

  /// Primer día visible de la tira; las flechas lo mueven y el calendario lo salta.
  late DateTime _inicio = _primerDia;

  List<DateTime> get _dias => [for (var i = 0; i < _visibles; i++) _sumar(_inicio, i)];

  /// Día elegido: hoy, o el siguiente con bloques libres si hoy ya no queda ninguno (con la API, el primer día
  /// abierto: sus horarios se consultan al elegirlo).
  late DateTime _fecha = diasReserva.firstWhere(
    (d) => !d.isBefore(Reloj.hoy) && !_cerrado(d) && (_usaApi || bloquesDelDia(d).any((b) => b.libre)),
    orElse: () => Reloj.hoy,
  );
  late int _bloque = _usaApi ? -1 : _primerLibre(bloquesDelDia(_fecha));

  Servicio get _servicio => widget.servicio ?? serviciosReserva.firstOrNull ?? servicioEjemplo;

  /// Con sesión en la API y un servicio de la API, los horarios salen de `GET /api/agenda`.
  bool get _usaApi => Api.conectada && _servicio.id != null;

  /// Bloques libres del día elegido según la API; null mientras se consultan.
  List<BloqueHorario>? _bloquesApi;

  /// Bloques de [d]: de la API (solo se consultan los del día elegido) o de la disponibilidad de ejemplo.
  List<BloqueHorario> _bloquesDe(DateTime d) =>
      _usaApi ? (mismoDia(d, _fecha) ? _bloquesApi ?? const [] : const []) : bloquesDelDia(d);

  /// Fotógrafo de la especialidad del servicio (de la API si hay sesión); null mientras se consulta o si no hay.
  Fotografo? _sugerido;

  String get _fotografo => _sugerido?.nombre ?? 'Asignado por el estudio';

  @override
  void initState() {
    super.initState();
    _cargarFotografo();
  }

  /// Primero el fotógrafo y después sus horarios (la API los filtra por profesional).
  Future<void> _cargarFotografo() async {
    final f = await fotografoSugerido(_servicio);
    if (!mounted) return;
    setState(() => _sugerido = f);
    _cargarHorarios();
  }

  Future<void> _cargarHorarios() async {
    if (!_usaApi) return;
    final dia = _fecha;
    setState(() {
      _bloquesApi = null;
      _bloque = -1;
    });
    try {
      final horas = await horariosDisponiblesApi(dia, _servicio.id!, profesionalId: _sugerido?.id);
      if (!mounted || !mismoDia(dia, _fecha)) return;
      setState(() {
        _bloquesApi = [for (final h in horas) BloqueHorario(h, BloqueTipo.libre, 'Disponible')];
        _bloque = _primerLibre(_bloquesApi!);
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _bloquesApi = const []);
      showHexToast(context, e.mensaje);
    }
  }

  static DateTime _sumar(DateTime d, int dias) => DateTime(d.year, d.month, d.day + dias);

  /// El estudio no atiende los domingos.
  static bool _cerrado(DateTime d) => d.weekday == DateTime.sunday;

  static int _primerLibre(List<BloqueHorario> bloques) => bloques.indexWhere((b) => b.libre);

  bool get _puedeRetroceder => _inicio.isAfter(_primerDia);
  bool get _puedeAvanzar => _dias.last.isBefore(_ultimoDia);

  /// [d] como primer día de la tira, sin salirse de los límites.
  DateTime _dentroDeLimites(DateTime d) {
    final maximo = _sumar(_ultimoDia, -(_visibles - 1));
    return d.isBefore(_primerDia) ? _primerDia : (d.isAfter(maximo) ? maximo : d);
  }

  /// Corre la tira [dias] días (negativo = hacia atrás).
  void _mover(int dias) => setState(() => _inicio = _dentroDeLimites(_sumar(_inicio, dias)));

  void _elegirFecha(DateTime d) {
    setState(() {
      _fecha = d;
      _bloque = _primerLibre(_bloquesDe(d));
    });
    _cargarHorarios();
  }

  /// Rótulo del día en la tira y si va resaltado por alta demanda (con la API no se sabe hasta consultar el día).
  ({String estado, bool altaDemanda}) _estadoDia(DateTime d) {
    if (d.isBefore(Reloj.hoy)) return (estado: 'Pasado', altaDemanda: false);
    if (_cerrado(d)) return (estado: 'Cerrado', altaDemanda: false);
    if (_usaApi) return (estado: 'Abierto', altaDemanda: false);
    final bloques = bloquesDelDia(d);
    final libres = bloques.where((b) => b.libre).length;
    final reservables = bloques.where((b) => b.tipo != BloqueTipo.almuerzo).length;
    return switch (libres) {
      0 => (estado: 'Sin Cupos', altaDemanda: false),
      <= 2 => (estado: 'Alta Demanda', altaDemanda: true),
      _ when libres == reservables => (estado: 'Disponible', altaDemanda: false),
      _ => (estado: '$libres Libres', altaDemanda: false),
    };
  }

  /// Calendario completo para elegir cualquier fecha desde hoy (sin domingos); la tira salta a esa fecha.
  Future<void> _abrirCalendario() async {
    var inicial = _fecha.isBefore(Reloj.hoy) ? Reloj.hoy : _fecha;
    if (_cerrado(inicial)) inicial = _sumar(inicial, 1);
    final d = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: Reloj.hoy,
      lastDate: _ultimoDia,
      currentDate: Reloj.ahora(),
      helpText: 'Fecha de la sesión',
      selectableDayPredicate: (d) => !_cerrado(d),
    );
    if (d == null || !mounted) return;
    _inicio = _dentroDeLimites(d);
    _elegirFecha(d);
  }

  String _rango(BloqueHorario b) => rangoAmPm(b.inicio, b.fin(_servicio.duracionMin));

  @override
  Widget build(BuildContext context) {
    void back() => Navigator.of(context).maybePop();
    final dia = _fecha;
    final bloques = _bloquesDe(dia);
    final elegido = _bloque >= 0 && _bloque < bloques.length ? bloques[_bloque] : null;

    return HeaderScaffold(
      header: HexHeader(title: 'Nueva Reserva', cerrar: true, onBack: widget.onSalir),
      bottomPadding: 32,
      children: [
        const SizedBox(height: 4),
        ReservaProgreso(
          paso: 2,
          servicio: '${_servicio.nombre.toUpperCase()} (${_servicio.duracionMin}M)',
          fotografo: _fotografo,
          cliente: (widget.cliente ?? clienteEjemplo).nombre,
        ),
        const SizedBox(height: 32),
        _fechas(),
        const SizedBox(height: 36),
        JornadaInfoCard(
          texto: _usaApi
              ? 'Horarios libres según la agenda del estudio para ${_servicio.nombre} (${_servicio.duracionMin} min).'
              : 'Bloques calculados según jornada de $_fotografo (08:00 - 17:00) y pausa '
                  'técnica de almuerzo (13:00 - 14:00).',
        ),
        const SizedBox(height: 32),
        if (_usaApi && bloques.isEmpty) ...[
          InfoBox(
            icon: Icons.schedule,
            child: Text(_bloquesApi == null ? 'Consultando horarios disponibles…' : 'Sin horarios libres este día: elige otra fecha.',
                style: AppText.sans(14, lineHeight: 18)),
          ),
          const SizedBox(height: 16),
        ],
        _horarios(dia, bloques),
        const SizedBox(height: 44),
        const SetAsignadoCard(set: 'Set Estudio A • Ciclorama Blanco', equipo: "Flash Profoto B10X Plus + Octa 3' incluidos"),
        const SizedBox(height: 44),
        SesionConfiguradaCard(
          fecha: '${nombreDia(dia)}, ${dia.day} ${mesCorto(dia)}'
              '${elegido == null ? '' : ' • ${horaAmPm(elegido.inicio)}'}',
          tarifa: '${formatCop(_servicio.precio)} COP',
          onBack: back,
          onContinuar: elegido == null || widget.onContinuar == null ? null : () => widget.onContinuar!(elegido.inicio),
        ),
      ],
    );
  }

  Widget _fechas() {
    final primero = _dias.first;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flexible + FittedBox: con meses largos ("Septiembre 2026") y los tres botones, el título se reduce
            // en vez de desbordar.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text('${nombreMes(primero)} ${primero.year}',
                        style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2)),
                    const SizedBox(width: 8),
                    Tag(
                      label: 'S${semanaIso(primero)}',
                      radius: 0,
                      background: AppColors.accentContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      style:
                          AppText.sans(11, weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 16.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                BotonNavegacion('fecha/chevron_left.svg', etiqueta: 'Días anteriores',
                    onTap: _puedeRetroceder ? () => _mover(-_visibles) : null),
                const SizedBox(width: 4),
                BotonNavegacion('fecha/chevron_right.svg', etiqueta: 'Días siguientes',
                    onTap: _puedeAvanzar ? () => _mover(_visibles) : null),
                const SizedBox(width: 4),
                BotonNavegacion('fecha/calendar.svg', etiqueta: 'Abrir calendario', ancho: 15, alto: 16.7,
                    onTap: _abrirCalendario),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(top: 6),
            itemCount: _dias.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final d = _dias[i];
              final inactivo = d.isBefore(Reloj.hoy) || _cerrado(d);
              final (:estado, :altaDemanda) = _estadoDia(d);
              return DiaCard(
                abrev: diaCorto(d),
                numero: d.day,
                estado: estado,
                selected: mismoDia(d, _fecha),
                pasado: inactivo,
                altaDemanda: altaDemanda,
                hoy: mismoDia(d, Reloj.hoy),
                onTap: inactivo ? null : () => _elegirFecha(d),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _horarios(DateTime dia, List<BloqueHorario> bloques) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text('Horarios para ${nombreDia(dia)} ${dia.day}',
                        style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                  ),
                  const SizedBox(width: 6),
                  Tag(label: '${_servicio.duracionMin}\nMIN', background: AppColors.accentContainer, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 16)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('Hora Colombia\n(COT)',
                textAlign: TextAlign.end, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < bloques.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          BloqueTile(
            horario: _rango(bloques[i]),
            nota: bloques[i].nota,
            tipo: bloques[i].tipo,
            selected: i == _bloque,
            onTap: () => setState(() => _bloque = i),
          ),
        ],
      ],
    );
  }
}
