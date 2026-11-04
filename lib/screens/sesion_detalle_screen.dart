import 'package:flutter/material.dart';

import '../api/api.dart';
import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../data/mock_clientes.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_pagos.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/detalle/detalle_cards.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import 'confirmaciones_sheets.dart';

/// Figma: "HexLens - Detalle de Sesión y Acciones" (19:129)
class SesionDetalleScreen extends StatelessWidget {
  const SesionDetalleScreen({super.key, this.onReagendar, this.sesion});

  final VoidCallback? onReagendar;

  /// Sesión a mostrar. Por defecto, la sesión en gestión ([sesionEnGestion]).
  final Sesion? sesion;

  @override
  Widget build(BuildContext context) {
    final s = sesion ?? sesionEnGestion;
    final cliente = clientePorNombre(s.cliente);
    final fotografo = fotografoPorNombre(s.fotografo);
    final precio = s.precio ?? 0;
    final pct = fotografo?.comisionPct ?? 0;
    final pago = mediosPago.where((m) => s.pago.isNotEmpty && m.titulo.startsWith(s.pago)).firstOrNull;
    final ahora = Reloj.ahora();
    final estado = switch (s.estado) {
      SesionEstado.cancelada => 'Cancelada',
      SesionEstado.realizada => 'Realizada',
      SesionEstado.programada when s.enCursoEn(ahora) => 'En curso',
      SesionEstado.programada => 'Programada',
    };
    // La reserva se registra unos días antes de la sesión (dato de ejemplo).
    final creada = s.inicio.subtract(const Duration(days: 5));

    return HeaderScaffold(
      header: HexHeader(title: 'Detalle de Sesión'),
      children: [
        DetalleCodigo(codigo: s.codigo ?? ''),
        const SizedBox(height: 8),
        DetalleHeroCard(
          cliente: s.cliente,
          documento: cliente?.ciudad == null
              ? cliente?.documento ?? ''
              : '${cliente!.documento} •\n${cliente.ciudad}',
          set: '${s.lugar} • 85mm f/1.4',
          estado: estado,
        ),
        const SizedBox(height: 16),
        const MoodboardRow(),
        const SizedBox(height: 16),
        AgendaDetalleCard(
          creada: 'Creada ${creada.day} ${mesCorto(creada)}\n${creada.year}',
          fecha: '${nombreDia(s.inicio)}, ${s.inicio.day} ${mesCorto(s.inicio)}',
          anio: s.inicio.year,
          horario: rangoAmPm(s.inicio, s.fin),
          duracion: '${s.duracionMin} minutos',
          telefono: cliente?.telefono ?? '',
          email: cliente?.email ?? '',
        ),
        const SizedBox(height: 16),
        ServicioLiquidacionCard(
          especialidad: fotografo?.especialidad ?? '',
          servicio: s.nombreServicio,
          descripcion: '3 fotografías procesadas +\nentrega digital HD',
          tarifa: formatCop(precio),
          fotografoIniciales: iniciales(s.fotografo),
          fotografo: s.fotografo,
          comisionPct: pct,
          liquidacion: '${formatCop(precio * pct ~/ 100)} COP',
          pago: pago?.titulo ?? s.pago,
        ),
        const SizedBox(height: 16),
        if (s.estado == SesionEstado.programada)
          _acciones(context, s)
        else
          Text('Sesión ${estado.toLowerCase()}: no admite más acciones.',
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      ],
    );
  }

  Widget _acciones(BuildContext context, Sesion s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('ACCIONES DE GESTIÓN OPERATIVA',
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7)),
        ),
        const SizedBox(height: 8),
        HexButton(
          label: 'Marcar como realizada',
          radius: 2,
          onPressed: () async {
            final ok = await showConfirmarAtendidoSheet(context, sesion: s);
            if (ok == true && context.mounted) {
              marcarRealizada(s);
              showHexToast(context, 'Sesión ${s.codigo ?? ''} marcada como realizada');
              Navigator.of(context).maybePop();
            }
          },
          leading: const SvgIcon('detalle/check_circle.svg', width: 16.667),
        ),
        const SizedBox(height: 8),
        HexButton(
          label: 'Reagendar sesión',
          onPressed: onReagendar,
          radius: 2,
          background: Colors.white,
          foreground: AppColors.onSurface,
          leading: const SvgIcon('detalle/reschedule.svg', width: 16.667),
        ),
        const SizedBox(height: 8),
        HexButton(
          label: 'Cancelar sesión',
          radius: 2,
          background: AppColors.errorContainer,
          foreground: AppColors.onErrorContainer,
          onPressed: () async {
            final motivo = await showCancelarCitaSheet(context, sesion: s);
            if (motivo == null || !context.mounted) return;
            try {
              await cancelarSesion(s, motivo);
              if (!context.mounted) return;
              showHexToast(context, 'Cita cancelada ($motivo). Horario liberado.');
              Navigator.of(context).maybePop();
            } on ApiError catch (e) {
              if (context.mounted) showHexToast(context, e.mensaje);
            }
          },
          leading: const SvgIcon('detalle/cancel.svg', width: 16.667),
        ),
      ],
    );
  }
}
