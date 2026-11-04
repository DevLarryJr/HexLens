import 'package:flutter/material.dart';

import '../../models/cierre.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_widgets.dart';

/// Etiqueta negra de módulo financiero "✦ HEX-FINANCE // ...".
class FinanceTag extends StatelessWidget {
  const FinanceTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      color: Colors.black,
      child: IconoTexto(const SvgIcon('cierres/sparkle.svg', width: 12), text,
          estilo: AppText.sans(14, weight: FontWeight.w600, color: Colors.white, lineHeight: 20, letterSpacing: 1),
          separacion: 8, ajuste: FlexFit.loose, compacto: true),
    );
  }
}

/// Botón negro "+ Nuevo Cierre Contable" con atajo F10.
class NuevoCierreBoton extends StatelessWidget {
  const NuevoCierreBoton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      borderRadius: AppRadius.xs,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const SvgIcon('cierres/nuevo.svg', width: 16.7, height: 16.7),
              const SizedBox(width: 12),
              Expanded(
                child: Text('+ Nuevo Cierre Contable',
                    style: AppText.sans(18, weight: FontWeight.w600, color: Colors.white, lineHeight: 24)),
              ),
              const SvgIcon('cierres/f10.svg', width: 14),
              const SizedBox(width: 6),
              Text('F10', style: AppText.sans(16, color: AppColors.outline, lineHeight: 22)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Año fijo en negro seguido de los filtros de mes.
class PeriodoFiltros extends StatelessWidget {
  const PeriodoFiltros({
    super.key,
    required this.anio,
    required this.filtros,
    required this.selected,
    required this.onSelect,
  });

  final int anio;
  final List<String> filtros;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            color: Colors.black,
            child: Text('$anio', style: AppText.sans(17, weight: FontWeight.w500, color: Colors.white)),
          ),
          for (var i = 0; i < filtros.length; i++) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                color: i == selected ? AppColors.surfaceHighest : AppColors.surfaceContainer,
                child: Text(filtros[i],
                    style: AppText.sans(17,
                        weight: i == selected ? FontWeight.w500 : FontWeight.w400,
                        color: i == selected ? AppColors.onSurface : AppColors.onSurfaceVariant)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "RESUMEN CONSOLIDADO ACTIVO": facturado, comisiones y parte del estudio.
class ResumenConsolidadoCard extends StatelessWidget {
  const ResumenConsolidadoCard({super.key, required this.total, required this.staff, required this.estudio});

  /// Importes ya formateados ("$1.840.000").
  final String total;
  final String staff;
  final String estudio;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const SvgIcon('cierres/resumen.svg', width: 13.5, height: 13.5),
              const SizedBox(width: 8),
              Expanded(
                child: Text('RESUMEN CONSOLIDADO ACTIVO',
                    style: AppText.sans(16,
                        weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 22, letterSpacing: 1.2)),
              ),
              Tag(label: 'COP', background: AppColors.surfaceLow,
                  style: AppText.sans(16, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Facturado Total en Cierres',
                          style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                    ),
                    const SvgIcon('cierres/facturado.svg', width: 12, height: 13.3),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '$total ',
                      style: AppText.sans(34, weight: FontWeight.w700, lineHeight: 42, letterSpacing: -0.8)),
                  TextSpan(text: 'COP', style: AppText.sans(18, color: AppColors.onSurfaceVariant)),
                ])),
              ],
            ),
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _mini('Comisiones Staff', staff, 'Liquidado o pendiente', accent: true),
                const SizedBox(width: 12),
                _mini('Para el Estudio', estudio, 'Margen operativo bruto', dark: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value, String sub, {bool accent = false, bool dark = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? AppColors.surfaceHigh : AppColors.surfaceLow,
          borderRadius: AppRadius.xs,
          boxShadow: dark ? AppShadows.soft : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: AppText.sans(24,
                      weight: FontWeight.w700, color: accent ? AppColors.accent : AppColors.onSurface, lineHeight: 30)),
            ),
            const SizedBox(height: 6),
            Text(sub, style: AppText.sans(13, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de un cierre: auditado (con fotógrafos y detalle) o ya liquidado (archivado).
class CierreCard extends StatelessWidget {
  const CierreCard({super.key, required this.cierre, this.onVerDetalle});

  final Cierre cierre;
  final VoidCallback? onVerDetalle;

  bool get _auditado => cierre.estado == EstadoCierre.auditado;

  @override
  Widget build(BuildContext context) {
    final c = cierre;
    return HexCard(
      radius: 4,
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
                    if (_auditado)
                      Row(
                        children: [
                          Flexible(
                            child: Text(c.codigo,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.sans(20, weight: FontWeight.w700, lineHeight: 26)),
                          ),
                          const SizedBox(width: 8),
                          const SvgIcon('cierres/sparkle_cierre.svg', width: 12),
                        ],
                      )
                    else
                      Text(c.codigo, style: AppText.sans(20, weight: FontWeight.w700, lineHeight: 26)),
                    Text('Quincena ${c.quincena} • ${fechaCorta(c.inicio)} - ${fechaCorta(c.fin)}',
                        style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                  ],
                ),
              ),
              if (_auditado) ...[const SizedBox(width: 8), const _AuditadoBadge()] else const _LiquidadoTag(),
            ],
          ),
          const SizedBox(height: 12),
          if (_auditado) _ServiciosAuditados(c) else _ServiciosArchivados(c),
          const SizedBox(height: 20),
          _Montos([
            (_auditado ? 'SERVICIOS' : 'TOTAL', formatCop(c.total), AppColors.onSurface),
            ('STAFF', formatCop(c.staff), _auditado ? AppColors.accentBright : AppColors.onSurfaceVariant),
            ('ESTUDIO', formatCop(c.estudio), AppColors.onSurface),
          ]),
          const SizedBox(height: 20),
          if (_auditado)
            HexButton(
              label: 'Ver Detalle y Liquidaciones',
              radius: 2,
              shadow: null,
              background: AppColors.surfaceHigh,
              foreground: AppColors.onSurface,
              onPressed: onVerDetalle,
              trailing: const SvgIcon('cierres/arrow.svg', width: 12, height: 12),
              textStyle: AppText.sans(18, weight: FontWeight.w500, lineHeight: 24),
            )
          else
            HexButton(
              label: 'Consultar Histórico',
              radius: 2,
              shadow: null,
              gap: 6,
              background: AppColors.surfaceHigh,
              foreground: AppColors.onSurface,
              onPressed: onVerDetalle,
              leading: const SvgIcon('cierres/historico.svg', width: 13.5, height: 13.5),
              textStyle: AppText.sans(18, weight: FontWeight.w500, lineHeight: 24),
            ),
        ],
      ),
    );
  }
}

class _AuditadoBadge extends StatelessWidget {
  const _AuditadoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          const Dot(size: 7),
          const SizedBox(width: 8),
          Expanded(
            child: Text('AUDITADO Y CERRADO',
                style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 26, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }
}

class _LiquidadoTag extends StatelessWidget {
  const _LiquidadoTag();

  @override
  Widget build(BuildContext context) {
    return Tag(
      label: 'LIQUIDADO',
      background: AppColors.surfaceHigh,
      gap: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: const SvgIcon('cierres/liquidado.svg', width: 12.8, height: 7),
      style: AppText.sans(14,
          weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 20, letterSpacing: 1.2),
    );
  }
}

class _ServiciosAuditados extends StatelessWidget {
  const _ServiciosAuditados(this.cierre);

  final Cierre cierre;

  @override
  Widget build(BuildContext context) {
    final nombres = cierre.fotografos;
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon('cierres/servicios.svg', width: 13.3, height: 12),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${cierre.servicios} servicios realizados',
                    style: AppText.sans(16, weight: FontWeight.w500, lineHeight: 22)),
              ),
              Tag(label: 'Excl. Pendientes', background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 28,
                child: Stack(children: [
                  for (var i = 0; i < nombres.length && i < 3; i++) _inicial(iniciales(nombres[i]), 22.0 * i),
                ]),
              ),
              const SizedBox(width: 8),
              Text(nombres.map(nombreCorto).join(', '),
                  style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inicial(String t, double left) => Positioned(
        left: left,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceLow, width: 2),
          ),
          child: Text(t, style: AppText.sans(11, weight: FontWeight.w600)),
        ),
      );
}

class _ServiciosArchivados extends StatelessWidget {
  const _ServiciosArchivados(this.cierre);

  final Cierre cierre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Expanded(child: Text('${cierre.servicios} servicios computados', style: AppText.sans(16, lineHeight: 22))),
          Text('Período archivado', style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
        ],
      ),
    );
  }
}

class _Montos extends StatelessWidget {
  const _Montos(this.items);

  final List<(String, String, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, (label, value, color)) in items.indexed) ...[
          // Separación entre columnas: sin ella las cifras quedaban pegadas ("$1.200.000$378.000").
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppText.sans(20, weight: FontWeight.w600, color: color, lineHeight: 26)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// "Regla de Consolidación": solo cuentan los servicios realizados.
class ReglaConsolidacion extends StatelessWidget {
  const ReglaConsolidacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            color: Colors.black,
            child: const SvgIcon('cierres/regla.svg', width: 32, height: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Regla de Consolidación', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 26)),
                const SizedBox(height: 4),
                Text(
                  'Solo se incluyen servicios con estado Realizada dentro del rango de fechas. Las sesiones '
                  'programadas o canceladas quedan estrictamente excluidas del cómputo.',
                  style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
