import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/agenda/cierre_resumen_card.dart';
import '../widgets/agenda/nueva_reserva_fab.dart';
import '../widgets/agenda/semana_strip.dart';
import '../widgets/agenda/sesion_card.dart';
import '../widgets/agenda/vista_tabs.dart';
import '../widgets/calendario_mensual.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_widgets.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({
    super.key,
    this.bottomBar,
    required this.onNuevaReserva,
    required this.onAbrirSesion,
  });

  final Widget? bottomBar;
  final VoidCallback onNuevaReserva;
  final ValueChanged<Sesion> onAbrirSesion;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

enum _Vista { semanas, dia, mensual }

class _AgendaScreenState extends State<AgendaScreen> with RedibujarAlCambiar {
  @override
  Listenable get escuchar => revisionAgenda;

  _Vista _vista = _Vista.dia;

  DateTime _fecha = Reloj.hoy;

  int _filtroEstado = 0;

  int? _filtroStaff;

  static const _estados = [SesionEstado.programada, SesionEstado.realizada, SesionEstado.cancelada];

  DateTime get _lunes => DateTime(_fecha.year, _fecha.month, _fecha.day - (_fecha.weekday - 1));

  static DateTime _sumar(DateTime d, int dias) => DateTime(d.year, d.month, d.day + dias);

  List<Sesion> _sesionesDe(DateTime dia) =>
      sesionesAgenda.where((s) => mismoDia(s.inicio, dia)).toList()..sort((a, b) => a.inicio.compareTo(b.inicio));

  List<DateTime> get _periodo => switch (_vista) {
        _Vista.dia => [_fecha],
        _Vista.semanas => [for (var i = 0; i < 7; i++) _sumar(_lunes, i)],
        _Vista.mensual => [
            for (var d = 1; d <= DateTime(_fecha.year, _fecha.month + 1, 0).day; d++)
              DateTime(_fecha.year, _fecha.month, d),
          ],
      };

  bool _pasaFiltros(Sesion s) =>
      (_filtroEstado == 0 || s.estado == _estados[_filtroEstado - 1]) &&
      (_filtroStaff == null || s.fotografo == staffAgenda[_filtroStaff!].$2);

  void _mover(int paso) => setState(() {
        if (_vista == _Vista.mensual) {
          final dias = DateTime(_fecha.year, _fecha.month + paso + 1, 0).day;
          _fecha = DateTime(_fecha.year, _fecha.month + paso, _fecha.day.clamp(1, dias));
        } else {
          _fecha = _sumar(_fecha, 7 * paso);
        }
      });

  Future<void> _elegirFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(Reloj.hoy.year - 2),
      lastDate: DateTime(Reloj.hoy.year + 2, 12, 31),
      currentDate: Reloj.hoy,
      helpText: 'Ir a la fecha',
    );
    if (d != null && mounted) setState(() => _fecha = d);
  }

  List<DiaSemana> get _semana => [
        for (var i = 0; i < 7; i++)
          () {
            final d = _sumar(_lunes, i);
            return DiaSemana(
              letraDia(d),
              d.day,
              puntos: _sesionesDe(d).length.clamp(0, 3),
              alerta: diasConAlertaAgenda.any((a) => mismoDia(a, d)),
              domingo: d.weekday == DateTime.sunday,
            );
          }(),
      ];

  String get _rotulo => switch (_vista) {
        _Vista.dia => fechaLarga(_fecha),
        _Vista.semanas => 'Semana ${semanaIso(_lunes)} · ${_lunes.day}–${diaMes(_sumar(_lunes, 6))}',
        _Vista.mensual => '${nombreMes(_fecha)} ${_fecha.year}',
      };

  String get _rotuloCierre => switch (_vista) {
        _Vista.dia => '${_fecha.day} ${mesCorto(_fecha).toUpperCase()}',
        _Vista.semanas => '${_lunes.day}–${_sumar(_lunes, 6).day} ${mesCorto(_sumar(_lunes, 6)).toUpperCase()}',
        _Vista.mensual => nombreMes(_fecha).toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    final periodo = _periodo;
    final delPeriodo = [for (final d in periodo) ..._sesionesDe(d)];
    final activas = delPeriodo.where((s) => !s.cancelada);
    final verHoy = !periodo.any((d) => mismoDia(d, Reloj.hoy));

    return HeaderScaffold(
      header: const HexHeader(section: 'Agenda'),
      bottomBar: widget.bottomBar,
      bottomPadding: 112 + 80,
      overlay: Positioned(
        right: 16,
        bottom: 80 + MediaQuery.paddingOf(context).bottom + 20,
        child: NuevaReservaFab(onTap: widget.onNuevaReserva),
      ),
      children: [
        _titulo(delPeriodo.length),
        const SizedBox(height: 8),
        VistaTabs(seleccion: _vista.index, onSelect: (i) => setState(() => _vista = _Vista.values[i])),
        if (verHoy) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: HexChip(
              label: 'Volver a hoy',
              selected: false,
              leading: const Icon(Icons.today, size: 16),
              onTap: () => setState(() => _fecha = Reloj.hoy),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              radius: 2,
              color: AppColors.surfaceContainer,
              style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18),
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (_vista == _Vista.mensual)
          CalendarioMensual(
            mes: _fecha,
            seleccionado: _fecha,
            hoy: Reloj.hoy,
            puntos: (d) => _sesionesDe(d).where((s) => !s.cancelada).length,
            onTitulo: _elegirFecha,
            onAnterior: () => _mover(-1),
            onSiguiente: () => _mover(1),
            onSelect: (d) => setState(() {
              _fecha = d;
              _vista = _Vista.dia;
            }),
          )
        else
          SemanaStrip(
            titulo: '${nombreMes(_lunes)} ${_lunes.year}',
            semana: 'Semana ${semanaIso(_lunes)}',
            dias: _semana,
            seleccion: _vista == _Vista.dia ? _fecha.weekday - 1 : -1,
            onSelect: (i) => setState(() {
              _fecha = _sumar(_lunes, i);
              _vista = _Vista.dia;
            }),
            onTitulo: _elegirFecha,
            onAnterior: () => _mover(-1),
            onSiguiente: () => _mover(1),
          ),
        const SizedBox(height: 32),
        _filtros(delPeriodo),
        const SizedBox(height: 32),
        const _TimelineHeader(),
        const SizedBox(height: 32),
        ..._lista(periodo, delPeriodo),
        CierreResumenCard(
          fecha: _rotuloCierre,
          total: formatCop(activas.fold(0, (t, s) => t + (s.precio ?? 0))),
          horas: horasDesdeMinutos(activas.fold(0, (t, s) => t + s.duracionMin)),
        ),
      ],
    );
  }

  List<Widget> _lista(List<DateTime> periodo, List<Sesion> delPeriodo) {
    final visibles = delPeriodo.where(_pasaFiltros).toList();
    if (visibles.isEmpty) {
      return [
        _SinSesiones(hayFiltros: delPeriodo.isNotEmpty, periodo: _vista),
        const SizedBox(height: 16),
      ];
    }
    if (_vista == _Vista.dia) {
      return [
        for (final s in visibles) ...[
          SesionCard(sesion: s, onTap: () => widget.onAbrirSesion(s)),
          const SizedBox(height: 16),
        ],
      ];
    }
    return [
      for (final d in periodo)
        if (visibles.where((s) => mismoDia(s.inicio, d)).toList() case final delDia when delDia.isNotEmpty) ...[
          _EncabezadoDia(
            dia: d,
            sesiones: delDia.length,
            hoy: mismoDia(d, Reloj.hoy),
            onTap: () => setState(() {
              _fecha = d;
              _vista = _Vista.dia;
            }),
          ),
          const SizedBox(height: 12),
          for (final s in delDia) ...[
            SesionCard(sesion: s, onTap: () => widget.onAbrirSesion(s)),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
        ],
    ];
  }

  Widget _titulo(int sesiones) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Agenda\nOperativa',
                      style: AppText.sans(28, weight: FontWeight.w700, lineHeight: 36, letterSpacing: -0.7)),
                  const SizedBox(width: 24),
                  const Dot(size: 8),
                ],
              ),
              const SizedBox(height: 4),
              Text('$_rotulo • $sesiones\n${sesiones == 1 ? 'sesión' : 'sesiones'}',
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
        ),
        SizedBox(
          width: 110,
          child: HexButton(
            label: 'Nueva',
            radius: 2,
            gap: 6,
            onPressed: widget.onNuevaReserva,
            leading: const SvgIcon('agenda/plus.svg', width: 11.667),
          ),
        ),
      ],
    );
  }

  Widget _filtros(List<Sesion> delDia) {
    int cuantas(SesionEstado e) => delDia.where((s) => s.estado == e).length;
    final estados = <(String, Widget?)>[
      ('Todas (${delDia.length})', null),
      ('Programadas (${cuantas(SesionEstado.programada)})', const Dot(size: 8)),
      ('Realizadas (${cuantas(SesionEstado.realizada)})', const SvgIcon('agenda/check_circle.svg', width: 13.333)),
      ('Canceladas (${cuantas(SesionEstado.cancelada)})', null),
    ];
    final staff = <(String, Widget?)>[
      for (var i = 0; i < staffAgenda.length; i++)
        (staffAgenda[i].$1, i == 0 ? const SvgIcon('agenda/camera.svg', width: 13.333, height: 12) : null),
    ];

    return Column(
      children: [
        _FiltroFila(
          label: 'Estado:',
          items: estados,
          seleccion: _filtroEstado,
          onSelect: (i) => setState(() => _filtroEstado = i),
        ),
        const SizedBox(height: 4),
        _FiltroFila(
          label: 'Staff:',
          items: staff,
          seleccion: _filtroStaff,
          acento: true,
          onSelect: (i) => setState(() => _filtroStaff = _filtroStaff == i ? null : i),
        ),
      ],
    );
  }
}

class _SinSesiones extends StatelessWidget {
  const _SinSesiones({required this.hayFiltros, required this.periodo});

  final bool hayFiltros;
  final _Vista periodo;

  String get _texto => hayFiltros
      ? 'Ninguna sesión coincide con los filtros.'
      : switch (periodo) {
          _Vista.dia => 'Sin sesiones agendadas para este día.',
          _Vista.semanas => 'Sin sesiones agendadas esta semana.',
          _Vista.mensual => 'Sin sesiones agendadas este mes.',
        };

  @override
  Widget build(BuildContext context) {
    return HexCard(
      color: AppColors.surfaceLow,
      shadow: null,
      child: Row(
        children: [
          const SvgIcon('agenda/timeline.svg', width: 16.667, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_texto, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ),
        ],
      ),
    );
  }
}

class _EncabezadoDia extends StatelessWidget {
  const _EncabezadoDia({required this.dia, required this.sesiones, required this.hoy, required this.onTap});

  final DateTime dia;
  final int sesiones;
  final bool hoy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xs,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text('${nombreDia(dia)} ${dia.day} ${mesCorto(dia)}'.toUpperCase(),
                  style: AppText.sans(15,
                      weight: FontWeight.w700,
                      color: hoy ? AppColors.accent : AppColors.onSurface,
                      lineHeight: 20,
                      letterSpacing: 0.8)),
            ),
            if (hoy) ...[
              Tag(
                label: 'HOY',
                background: AppColors.accentContainer,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 16),
              ),
              const SizedBox(width: 8),
            ],
            Text('$sesiones ${sesiones == 1 ? 'sesión' : 'sesiones'}',
                style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _FiltroFila extends StatelessWidget {
  const _FiltroFila({
    required this.label,
    required this.items,
    required this.seleccion,
    required this.onSelect,
    this.acento = false,
  });

  final String label;
  final List<(String, Widget?)> items;
  final int? seleccion;
  final ValueChanged<int> onSelect;

  final bool acento;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(label, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ),
          for (var i = 0; i < items.length; i++) ...[
            const SizedBox(width: 8),
            HexChip(
              label: items[i].$1,
              leading: items[i].$2,
              leadingGap: 4,
              selected: i == seleccion,
              onTap: () => onSelect(i),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              radius: 2,
              color: AppColors.surfaceContainer,
              selectedColor: acento ? AppColors.accentContainer : Colors.black,
              selectedForeground: acento ? AppColors.onAccentContainer : Colors.white,
              style: AppText.sans(14, lineHeight: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconoTexto(const SvgIcon('agenda/timeline.svg', width: 16.667), 'Línea de Tiempo\nOperativa',
            estilo: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24), separacion: 8),
        Text('Bogotá\n(GMT-5)', textAlign: TextAlign.end, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      ],
    );
  }
}
