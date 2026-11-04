import 'package:flutter/material.dart';

import '../data/mock_agenda.dart';
import '../data/mock_clientes.dart';
import '../data/mock_confirmaciones.dart';
import '../data/mock_fotografos.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/sheets/confirmacion_sheet_frame.dart';

/// Figma: "HexLens - Confirmar Servicio Atendido (Modal)" (41:2596). Devuelve true al confirmar.
/// Por defecto muestra la sesión en gestión ([sesionEnGestion]).
Future<bool?> showConfirmarAtendidoSheet(BuildContext context, {Sesion? sesion}) =>
    mostrarHoja<bool>(context, _ConfirmarAtendido(sesion: sesion ?? sesionEnGestion), oscuro: true);

class _ConfirmarAtendido extends StatefulWidget {
  const _ConfirmarAtendido({required this.sesion});

  final Sesion sesion;

  @override
  State<_ConfirmarAtendido> createState() => _ConfirmarAtendidoState();
}

class _ConfirmarAtendidoState extends State<_ConfirmarAtendido> {
  final _checks = [true, true, true, false];

  bool get _listo => _checks.take(checklistObligatorios).every((c) => c);

  @override
  Widget build(BuildContext context) {
    final s = widget.sesion;
    final precio = s.precio ?? 0;
    final pct = fotografoPorNombre(s.fotografo)?.comisionPct ?? 0;
    return ConfirmacionSheetFrame(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tag(label: 'COMPLETAR SERVICIO', style: AppText.sans(16, weight: FontWeight.w600, letterSpacing: 1.6)),
              const SizedBox(width: 8),
              const Icon(Icons.circle, size: 8, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 10),
          Text('Cierre de Sesión Atendida', style: AppText.sans(24, weight: FontWeight.w600, lineHeight: 36)),
        ],
      ),
      body: [
        const SizedBox(height: 6),
        Text('Registra la finalización en set, verifica entregables raw y habilita el cálculo de liquidación para el fotógrafo.',
            style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 26)),
        const SizedBox(height: 16),
        _ResumenAtendido(
          codigo: s.codigo ?? '',
          cliente: s.cliente,
          documento: clientePorNombre(s.cliente)?.documento ?? '',
          fotografo: s.fotografo,
          comision: 'Comisión: $pct% (${formatCop(precio * pct ~/ 100)})',
          servicio: s.nombreServicio,
          duracion: 'Duración: ${s.duracionMin} min',
          facturado: '${formatCop(precio)} COP',
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text('LISTA DE ENTREGA Y CALIDAD',
                  style: AppText.sans(19, weight: FontWeight.w600, lineHeight: 30, letterSpacing: 0.6)),
            ),
            Text('${_checks.where((c) => c).length} de\n${_checks.length}',
                style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 26)),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < checklistEntrega.length; i++) ...[
          _CheckTile(
            titulo: checklistEntrega[i].$1,
            detalle: checklistEntrega[i].$2,
            checked: _checks[i],
            onTap: () => setState(() => _checks[i] = !_checks[i]),
          ),
          const SizedBox(height: 10),
        ],
        if (!_listo)
          Text('Completa los tres primeros puntos del checklist para confirmar.',
              style: AppText.sans(14, color: AppColors.accentBright)),
      ],
      actions: ParAcciones(
        secundario: 'Regresar',
        iconoSecundario: const Icon(Icons.arrow_back, size: 18),
        onSecundario: () => Navigator.of(context).pop(),
        principal: 'Confirmar Atendido',
        iconoPrincipal: const SvgIcon('confirmar/atendido.svg', width: 16.4, height: 9),
        onPrincipal: _listo ? () => Navigator.of(context).pop(true) : null,
      ),
    );
  }
}

/// Cliente, fotógrafo, servicio y facturación de la sesión en curso.
class _ResumenAtendido extends StatelessWidget {
  const _ResumenAtendido({
    required this.codigo,
    required this.cliente,
    required this.documento,
    required this.fotografo,
    required this.comision,
    required this.servicio,
    required this.duracion,
    required this.facturado,
  });

  final String codigo;
  final String cliente;
  final String documento;
  final String fotografo;
  final String comision;
  final String servicio;
  final String duracion;
  final String facturado;

  @override
  Widget build(BuildContext context) {
    final label = AppText.sans(15, color: AppColors.onSurfaceVariant, letterSpacing: 0.6);
    final value = AppText.sans(19, weight: FontWeight.w600, lineHeight: 28);
    Widget celda(List<Widget> children) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      color: AppColors.surfaceLow,
      child: Column(
        children: [
          OrdenHeader(codigo: codigo, estado: 'EN SET / EN CURSO', dark: false),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      celda([
                        Text('CLIENTE', style: label),
                        Text(cliente, style: value),
                        Text(documento, style: AppText.sans(15, color: AppColors.outline)),
                      ]),
                      const SizedBox(height: 10),
                      celda([
                        Text('FOTÓGRAFO TITULAR', style: label),
                        Text(fotografo, style: value),
                        Text(comision, style: AppText.sans(16, color: AppColors.accent)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        celda([
                          Text('SERVICIO', style: label),
                          Text(servicio, style: value),
                          Text(duracion, style: AppText.sans(16, color: AppColors.onSurfaceVariant)),
                        ]),
                        celda([
                          Text('FACTURADO', style: label),
                          Text(facturado, style: value),
                          Text('PAGADO COMPLETO',
                              style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.titulo, required this.detalle, required this.checked, required this.onTap});

  final String titulo;
  final String detalle;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.surfaceLow,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: checked ? Colors.black : Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: AppRadius.xs,
              ),
              child: checked ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppText.sans(19, lineHeight: 26)),
                  Text(detalle, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
