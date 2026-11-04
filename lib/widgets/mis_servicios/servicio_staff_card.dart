import 'package:flutter/material.dart';

import '../../models/sesion.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_widgets.dart';

/// Tarjeta de un servicio asignado al fotógrafo. Tiene tres variantes:
/// programada (hoy), realizada hoy e histórica (días anteriores).
class ServicioStaffCard extends StatelessWidget {
  const ServicioStaffCard({
    super.key,
    required this.sesion,
    required this.hoy,
    required this.comisionPct,
    this.onVerFicha,
  });

  final Sesion sesion;

  /// Fecha de referencia para distinguir "hoy" de "histórica".
  final DateTime hoy;
  final int comisionPct;
  final VoidCallback? onVerFicha;

  bool get _programada => sesion.estado == SesionEstado.programada;
  bool get _historica => !_programada && !mismoDia(sesion.inicio, hoy);

  /// Ícono según el tipo de servicio.
  Widget get _icono {
    final nombre = sesion.descripcion.toLowerCase();
    if (nombre.contains('graduación')) {
      return const SvgIcon('mis_servicios/graduacion.svg', width: 16.5, height: 13.5);
    }
    if (nombre.contains('corporativo')) {
      return const SvgIcon('mis_servicios/corporativo.svg', width: 15, height: 15);
    }
    return const SvgIcon('mis_servicios/retrato.svg', width: 16.5, height: 16.5);
  }

  String get _fecha {
    final d = sesion.inicio;
    if (_historica) return fechaCorta(d);
    return '${nombreDia(d)} ${d.day} ${mesCorto(d)}, ${horaAmPm(d)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = sesion;
    final precio = s.precio ?? 0;
    final comision = precio * comisionPct ~/ 100;
    return HexCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(s.cliente,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sans(17, weight: FontWeight.w600, lineHeight: 22)),
                        ),
                        if (_programada)
                          const Text(' ✦', style: TextStyle(color: AppColors.accentBright, fontSize: 13)),
                      ],
                    ),
                    Text(s.codigo ?? '', style: AppText.mono(13, lineHeight: 18)),
                  ],
                ),
              ),
              _programada ? const _ProgramadaBadge() : const _RealizadaBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _icono,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: s.descripcion, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 22)),
                        if (!_historica)
                          TextSpan(
                              text: '  • ${s.duracionMin} min',
                              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SvgIcon('mis_servicios/fecha.svg', width: 15, height: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_fecha, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    ),
                    Text('•  ', style: AppText.sans(14, color: AppColors.onSurfaceVariant)),
                    Expanded(
                      child: Text(s.lugar,
                          style: AppText.sans(14, weight: _programada ? FontWeight.w600 : FontWeight.w400, lineHeight: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (s.equipo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: AppColors.surfaceLow,
              child: Row(
                children: [
                  const SvgIcon('mis_servicios/camara.svg', width: 12.5, height: 11.3),
                  const SizedBox(width: 4),
                  Expanded(child: Text(s.equipo!, style: AppText.mono(11, lineHeight: 16))),
                  const SvgIcon('mis_servicios/flash.svg', width: 12.5, height: 10),
                  const SizedBox(width: 4),
                  Text('Godox AD600 Pro', style: AppText.mono(11, lineHeight: 16)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarifa servicio', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    Text('${formatCop(precio)} COP', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 22)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_historica ? 'Tu comisión' : 'Tu comisión ($comisionPct%)',
                      style: AppText.sans(14,
                          color: _programada ? AppColors.accentBright : AppColors.onSurfaceVariant, lineHeight: 18)),
                  Text('${formatCop(comision)} COP',
                      style: AppText.sans(20,
                          weight: FontWeight.w700,
                          color: _programada ? AppColors.accentBright : AppColors.onSurface,
                          lineHeight: 26)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _acciones(),
        ],
      ),
    );
  }

  Widget _acciones() {
    if (_programada) {
      return HexButton(
        label: 'Ver Ficha de Sesión',
        radius: 4,
        onPressed: onVerFicha,
        trailing: const SvgIcon('mis_servicios/arrow.svg', width: 12, height: 12),
      );
    }
    if (_historica) {
      return HexButton(
        label: 'Ver Ficha Histórica',
        radius: 4,
        shadow: null,
        background: AppColors.surfaceHigh,
        foreground: AppColors.onSurface,
        onPressed: onVerFicha,
        leading: const SvgIcon('mis_servicios/ver.svg', width: 16.5, height: 11.3),
      );
    }
    return Row(
      children: [
        Expanded(
          child: HexButton(
            label: 'Resumen de Entrega',
            radius: 4,
            gap: 6,
            shadow: null,
            background: AppColors.surfaceHigh,
            foreground: AppColors.onSurface,
            onPressed: onVerFicha,
            leading: const SvgIcon('mis_servicios/resumen.svg', width: 12, height: 15),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 52,
          height: 48,
          decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.sm),
          child: const SvgIcon('mis_servicios/nube.svg', width: 18.3, height: 13.3),
        ),
      ],
    );
  }
}

class _ProgramadaBadge extends StatelessWidget {
  const _ProgramadaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: AppColors.accentBright, borderRadius: AppRadius.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 7), child: Dot(size: 5, color: Colors.white)),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Programada para hoy',
                style: AppText.sans(14, weight: FontWeight.w500, color: Colors.white, lineHeight: 18)),
          ),
        ],
      ),
    );
  }
}

class _RealizadaBadge extends StatelessWidget {
  const _RealizadaBadge();

  @override
  Widget build(BuildContext context) {
    return Tag(
      label: 'Realizada',
      radius: 12,
      gap: 6,
      background: AppColors.surfaceHigh,
      leading: const SvgIcon('mis_servicios/realizada.svg', width: 13.3, height: 13.3),
      style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
    );
  }
}
