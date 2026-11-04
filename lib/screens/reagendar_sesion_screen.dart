import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/reservas_api.dart';
import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../data/mock_clientes.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_reagendar.dart';
import '../models/franja_horaria.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/calendario_mensual.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/reagendar/contexto_bloqueado.dart';
import '../widgets/reagendar/franja_grid.dart';
import '../widgets/reagendar/politica_card.dart';
import '../widgets/reagendar/staff_selector.dart';

/// Figma: "HexLens - Reagendar Sesión" (41:971)
class ReagendarSesionScreen extends StatefulWidget {
  const ReagendarSesionScreen({super.key, this.sesion});

  /// Sesión que se reagenda. Por defecto, la sesión en gestión ([sesionEnGestion]).
  final Sesion? sesion;

  @override
  State<ReagendarSesionScreen> createState() => _ReagendarSesionScreenState();
}

class _ReagendarSesionScreenState extends State<ReagendarSesionScreen> with ProtegeCambios {
  late final _sesion = widget.sesion ?? sesionEnGestion;

  /// La franja que se elige sola (al abrir o al cargar horarios) no cuenta como cambio; la que toca el usuario sí.
  bool _eligioFranja = false;

  @override
  String get firmaFormulario => '$_dia|$_staff|${_eligioFranja ? _slot : ''}';

  /// Con sesión en la API, los horarios libres salen de `GET /api/agenda` (no de la agenda de ejemplo).
  bool get _usaApi => Api.conectada && _sesion.servicioId != null;

  /// Horas libres del día elegido según la API; null mientras se consultan.
  List<DateTime>? _libresApi;

  /// Enviando el cambio a la API.
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarHorarios();
  }

  Future<void> _cargarHorarios() async {
    if (!_usaApi) return;
    setState(() {
      _libresApi = null;
      _slot = -1;
    });
    try {
      // Las horas libres del fotógrafo que ya tiene la sesión (si está en el staff cargado).
      final horas = await horariosDisponiblesApi(_dia, _sesion.servicioId!,
          profesionalId: fotografoPorNombre(_sesion.fotografo)?.id);
      if (!mounted) return;
      setState(() {
        _libresApi = horas;
        _slot = _primeraLibre();
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _libresApi = const []);
      showHexToast(context, e.mensaje);
    }
  }

  /// Día elegido: por defecto el primero disponible desde el mismo día de la semana siguiente.
  late DateTime _dia = _primerDisponible(_sumar(_soloFecha(_sesion.inicio), 7));

  /// Mes que muestra el calendario.
  late DateTime _mes = _dia;
  late int _slot = _primeraLibre();
  int _staff = 0;

  static DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _sumar(DateTime d, int dias) => DateTime(d.year, d.month, d.day + dias);

  bool _bloqueado(DateTime d) => diaBloqueadoReagendar(d, _sesion.fotografo);

  DateTime _primerDisponible(DateTime desde) {
    var d = desde.isBefore(Reloj.hoy) ? Reloj.hoy : desde;
    for (var i = 0; i < 60 && _bloqueado(d); i++) {
      d = _sumar(d, 1);
    }
    return d;
  }

  List<FranjaHoraria> get _franjas => _usaApi
      ? [for (final h in _libresApi ?? const <DateTime>[]) FranjaHoraria(horaAmPm(h), inicio: h)]
      : franjasReagendar(_dia, _sesion);

  /// La franja libre a la misma hora de la sesión original o, si no hay, la primera libre (−1 si ninguna).
  int _primeraLibre() {
    final franjas = _franjas;
    final misma = franjas.indexWhere((f) =>
        f.disponible && f.inicio!.hour == _sesion.inicio.hour && f.inicio!.minute == _sesion.inicio.minute);
    return misma >= 0 ? misma : franjas.indexWhere((f) => f.disponible);
  }

  void _elegirDia(DateTime d) {
    setState(() {
      _dia = d;
      _slot = _primeraLibre();
    });
    _cargarHorarios();
  }

  /// Muestra el mes [paso] meses antes o después, entre el mes actual y [mesesReagendar] hacia adelante.
  bool _puedeIrA(int paso) {
    final destino = DateTime(_mes.year, _mes.month + paso);
    return !destino.isBefore(DateTime(Reloj.hoy.year, Reloj.hoy.month)) &&
        !destino.isAfter(DateTime(Reloj.hoy.year, Reloj.hoy.month + mesesReagendar));
  }

  Future<void> _confirmar() async {
    final franja = _franjas[_slot];
    final fotografo = _staff == 1 ? 'Mateo Ríos' : _sesion.fotografo;
    setState(() => _guardando = true);
    try {
      final nueva = await reagendarSesion(_sesion, franja.inicio!, fotografo: fotografo);
      if (!mounted) return;
      showHexToast(context, 'Sesión reagendada: ${fechaLarga(nueva.inicio)} • ${franja.hora}');
      salirSinPreguntar();
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final franjas = _franjas;
    final hora = _slot >= 0 ? franjas[_slot].hora : '—';
    final original = _sesion.inicio;
    final sesion = _sesion;
    final cliente = clientePorNombre(sesion.cliente);
    final telefono = cliente?.telefono ?? '';

    return protegerSalida(HeaderScaffold(
      header: HexHeader(title: 'Reagendar Sesión', cerrar: true),
      bottomPadding: 128,
      overlay: Positioned(left: 0, right: 0, bottom: 0, child: _actionBar()),
      children: [
        const SizedBox(height: 16),
        ContextoBloqueado(
          auditoria: '',
          orden: sesion.codigo ?? '',
          cliente: sesion.cliente,
          documento: cliente?.documento ?? '',
          telefono: telefono,
          servicio: sesion.nombreServicio,
          precio: '${formatCop(sesion.precio ?? 0)} COP',
          duracion: '${sesion.duracionMin} Min (Estándar)',
          cabina: sesion.lugar,
        ),
        const SizedBox(height: 28),
        EncabezadoSeccion(
          '01 · NUEVA FECHA',
          extra: IconoTexto(const SvgIcon('reagendar/history.svg', width: 10.5),
              'Original: ${original.day}\n${mesCorto(original)}',
              estilo: AppText.sans(12, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18),
              separacion: 4),
        ),
        const SizedBox(height: 8),
        CalendarioMensual(
          mes: _mes,
          seleccionado: _dia,
          hoy: Reloj.hoy,
          original: original,
          etiqueta: 'UTC-5',
          bloqueado: _bloqueado,
          onSelect: _elegirDia,
          onAnterior: _puedeIrA(-1) ? () => setState(() => _mes = DateTime(_mes.year, _mes.month - 1)) : null,
          onSiguiente: _puedeIrA(1) ? () => setState(() => _mes = DateTime(_mes.year, _mes.month + 1)) : null,
          pie: FechaElegida(fechaLarga(_dia)),
        ),
        const SizedBox(height: 28),
        EncabezadoSeccion(
          '02 · HORARIO DISPONIBLE',
          extra: Tag(
            label: '${sesion.duracionMin} min de sesión\n+ 15 de limpieza',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            style: AppText.sans(11, color: AppColors.onSurfaceVariant, lineHeight: 16.5),
          ),
        ),
        const SizedBox(height: 8),
        FranjaGrid(
          franjas: franjas,
          seleccion: _slot,
          resumen: _slot >= 0
              ? 'Franja seleccionada: $hora (${sesion.duracionMin} min)'
              : (_usaApi && _libresApi == null ? 'Consultando horarios disponibles…' : 'Sin franjas libres este día: elige otra fecha.'),
          cabina: 'Cabina 02\nLibre',
          onSelect: (i) => setState(() {
            _slot = i;
            _eligioFranja = true;
          }),
        ),
        const SizedBox(height: 28),
        const EncabezadoSeccion('03 · FOTÓGRAFO', dato: 'Comisión: 30%', colorDato: AppColors.accent),
        const SizedBox(height: 8),
        StaffSelector(
          titular: 'Laura Méndez',
          especialidad: 'Especialista en Retrato\nEditorial',
          opciones: opcionesStaffReagendar(hora),
          seleccion: _staff,
          onSelect: (i) => setState(() => _staff = i),
        ),
        const SizedBox(height: 20),
        PoliticaCard(horasAntelacion: 12, telefono: telefono),
      ],
    ));
  }

  /// Solo la acción principal: salir sin reagendar es la ✕ del header.
  Widget _actionBar() {
    return BlurBottomBar(
      child: HexButton(
        label: 'Confirmar Reagendamiento',
        radius: 2,
        gap: 4,
        shadow: AppShadows.medium,
        onPressed: _slot >= 0 && !_guardando ? _confirmar : null,
        leading: const SvgIcon('reagendar/confirm.svg', width: 17.5, height: 18.333),
        textStyle: AppText.sans(15, weight: FontWeight.w700, color: Colors.white, lineHeight: 20),
      ),
    );
  }
}
