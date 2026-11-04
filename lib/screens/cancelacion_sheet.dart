import 'package:flutter/material.dart';

import '../data/mock_agenda.dart';
import '../data/mock_clientes.dart';
import '../data/mock_confirmaciones.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/sheets/confirmacion_sheet_frame.dart';

/// Figma: "HexLens - Confirmar Cancelación (Modal)" (41:2414).
/// Devuelve el motivo elegido si se cancela la cita, o null si se cierra.
/// Por defecto muestra la sesión en gestión ([sesionEnGestion]).
Future<String?> showCancelarCitaSheet(BuildContext context, {Sesion? sesion}) =>
    mostrarHoja<String>(context, _ConfirmarCancelacion(sesion: sesion ?? sesionEnGestion));

/// Variante que solo indica si se canceló (true) o no.
Future<bool?> showConfirmarCancelacionSheet(BuildContext context, {Sesion? sesion}) async =>
    await showCancelarCitaSheet(context, sesion: sesion) != null;

class _ConfirmarCancelacion extends StatefulWidget {
  const _ConfirmarCancelacion({required this.sesion});

  final Sesion sesion;

  @override
  State<_ConfirmarCancelacion> createState() => _ConfirmarCancelacionState();
}

class _ConfirmarCancelacionState extends State<_ConfirmarCancelacion> {
  int _motivo = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.sesion;
    final cliente = clientePorNombre(s.cliente);
    final inicio = s.inicio;
    return ConfirmacionSheetFrame(
      accentTop: true,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cancelar Cita Fotográfica', style: AppText.sans(24, weight: FontWeight.w600, lineHeight: 32)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: AppColors.accent,
            child: IconoTexto(const SvgIcon('confirmar/irreversible.svg', width: 12.8, height: 11.1),
                'ACCIÓN IRREVERSIBLE',
                estilo: AppText.sans(14, weight: FontWeight.w700, color: Colors.white, letterSpacing: 0.8),
                compacto: true),
          ),
        ],
      ),
      body: [
        const SizedBox(height: 10),
        Text('La liberación de horario devolverá el slot a disponibilidad general y notificará al cliente de inmediato.',
            style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 26)),
        const SizedBox(height: 22),
        _ResumenCita(
          codigo: s.codigo ?? '',
          cliente: s.cliente,
          documento: cliente?.documento ?? '',
          servicio: s.nombreServicio,
          precio: '${formatCop(s.precio ?? 0)} COP',
          fecha: '${nombreDia(inicio)} ${inicio.day} ${nombreMes(inicio)} ${inicio.year} • ${horaAmPm(inicio)}',
          lugar: s.lugar,
          fotografo: s.fotografo,
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            const SvgIcon('confirmar/motivo.svg', width: 15, height: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'Motivo de Cancelación ', style: AppText.sans(20, weight: FontWeight.w600)),
                TextSpan(text: '*', style: AppText.sans(20, color: AppColors.accent)),
              ])),
            ),
            Tag(label: 'Obligatorio', padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                style: AppText.sans(14)),
          ],
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < motivosCancelacion.length; i++) ...[
          _MotivoTile(
            titulo: motivosCancelacion[i].$1,
            detalle: motivosCancelacion[i].$2,
            selected: i == _motivo,
            onTap: () => setState(() => _motivo = i),
          ),
          const SizedBox(height: 8),
        ],
      ],
      actions: ParAcciones(
        secundario: 'Volver',
        iconoSecundario: const Icon(Icons.undo, size: 18),
        onSecundario: () => Navigator.of(context).pop(),
        principal: 'Confirmar Cancelación',
        iconoPrincipal: const SvgIcon('confirmar/cancelar.svg', width: 13.3, height: 15),
        colorPrincipal: AppColors.accent,
        onPrincipal: () => Navigator.of(context).pop(motivosCancelacion[_motivo].$1),
      ),
    );
  }
}

/// Datos de la cita que se va a cancelar.
class _ResumenCita extends StatelessWidget {
  const _ResumenCita({
    required this.codigo,
    required this.cliente,
    required this.documento,
    required this.servicio,
    required this.precio,
    required this.fecha,
    required this.lugar,
    required this.fotografo,
  });

  final String codigo;
  final String cliente;
  final String documento;
  final String servicio;
  final String precio;
  final String fecha;
  final String lugar;
  final String fotografo;

  @override
  Widget build(BuildContext context) {
    Widget dato(String label, String value, String sub, {Color subColor = AppColors.outline}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.sans(15, color: AppColors.onSurfaceVariant, letterSpacing: 0.6)),
              const SizedBox(height: 4),
              Text(value, style: AppText.sans(19, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(sub, style: AppText.sans(14, color: subColor)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
      child: Column(
        children: [
          OrdenHeader(codigo: codigo, estado: 'PROGRAMADA', dark: true),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dato('CLIENTE', cliente, documento),
              dato('SERVICIO', servicio, precio, subColor: AppColors.accent),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors.surfaceHigh.withValues(alpha: 0.7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconoTexto(const SvgIcon('confirmar/horario.svg', width: 13.3, height: 13.3), fecha,
                    estilo: AppText.sans(19, weight: FontWeight.w500), ajuste: FlexFit.loose),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(lugar, style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                    ),
                    Expanded(child: Text('Fotógrafa: $fotografo', style: AppText.sans(17, lineHeight: 24))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivoTile extends StatelessWidget {
  const _MotivoTile({required this.titulo, required this.detalle, required this.selected, required this.onTap});

  final String titulo;
  final String detalle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceHigh : AppColors.surfaceLow,
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: selected ? Border.all(color: AppColors.accent, width: 2) : null,
              ),
              child: selected ? const Center(child: Icon(Icons.circle, size: 12, color: AppColors.accent)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppText.sans(19, weight: FontWeight.w500, lineHeight: 28)),
                  Text(detalle, style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 26)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
