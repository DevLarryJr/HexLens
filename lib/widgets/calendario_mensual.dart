import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formato.dart';
import 'hex_widgets.dart';

class CalendarioMensual extends StatelessWidget {
  const CalendarioMensual({
    super.key,
    required this.mes,
    required this.seleccionado,
    required this.hoy,
    this.onSelect,
    this.onAnterior,
    this.onSiguiente,
    this.onTitulo,
    this.puntos,
    this.bloqueado,
    this.original,
    this.etiqueta,
    this.pie,
  });

  final DateTime mes;
  final DateTime? seleccionado;
  final DateTime hoy;
  final ValueChanged<DateTime>? onSelect;

  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;

  final VoidCallback? onTitulo;

  final int Function(DateTime dia)? puntos;

  final bool Function(DateTime dia)? bloqueado;

  final DateTime? original;

  final String? etiqueta;

  final Widget? pie;

  static const _diasSemana = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    final primero = DateTime(mes.year, mes.month);
    final lunes = DateTime(primero.year, primero.month, 1 - (primero.weekday - 1));
    final diasDelMes = DateTime(mes.year, mes.month + 1, 0).day;
    final semanas = ((primero.weekday - 1 + diasDelMes) / 7).ceil();

    return HexCard(
      radius: 4,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: onTitulo,
                    borderRadius: AppRadius.xs,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text('${nombreMes(primero)} ${primero.year}',
                                style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
                          ),
                          if (onTitulo != null) ...[
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.onSurfaceVariant),
                          ],
                          if (etiqueta != null) ...[
                            const SizedBox(width: 4),
                            Tag(
                              label: etiqueta!,
                              background: AppColors.surfaceHigh,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 16),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FlechaCalendario(Icons.chevron_left, etiqueta: 'Mes anterior', onTap: onAnterior),
              const SizedBox(width: 4),
              FlechaCalendario(Icons.chevron_right, etiqueta: 'Mes siguiente', onTap: onSiguiente),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in _diasSemana)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: AppText.sans(12,
                            weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 16)),
                  ),
                ),
            ],
          ),
          for (var s = 0; s < semanas; s++) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(child: _dia(DateTime(lunes.year, lunes.month, lunes.day + s * 7 + i))),
                ],
              ],
            ),
          ],
          if (pie != null) ...[const SizedBox(height: 16), pie!],
        ],
      ),
    );
  }

  Widget _dia(DateTime d) {
    if (d.month != mes.month) return const SizedBox(height: 46);
    final selected = seleccionado != null && mismoDia(d, seleccionado!);
    final esHoy = mismoDia(d, hoy);
    final esOriginal = original != null && mismoDia(d, original!);
    final blocked = bloqueado?.call(d) ?? false;
    final n = (puntos?.call(d) ?? 0).clamp(0, 3);
    final color = selected
        ? Colors.white
        : (blocked ? AppColors.disabled : (esOriginal ? AppColors.onSurfaceVariant : AppColors.onSurface));

    return Semantics(
      button: !blocked,
      selected: selected,
      label: fechaLarga(d),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: blocked || esOriginal || onSelect == null ? null : () => onSelect!(d),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: selected ? Colors.black : (esOriginal ? AppColors.surfaceHigh : AppColors.surfaceLow),
            borderRadius: AppRadius.xs,
            border: esHoy && !selected ? Border.all(color: AppColors.accent, width: 1.5) : null,
            boxShadow: selected ? AppShadows.medium : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${d.day}',
                  style: AppText.sans(14,
                      weight: selected || esHoy ? FontWeight.w700 : FontWeight.w400,
                      color: color,
                      lineHeight: 18,
                      decoration: esOriginal ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 3),
              SizedBox(
                height: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (esOriginal)
                      const Dot(size: 4)
                    else
                      for (var k = 0; k < n; k++) ...[
                        if (k > 0) const SizedBox(width: 2),
                        Dot(size: 4, color: selected ? Colors.white : AppColors.accent),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlechaCalendario extends StatelessWidget {
  const FlechaCalendario(this.icono, {super.key, required this.etiqueta, this.onTap});

  final IconData icono;

  final String etiqueta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: etiqueta,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: Material(
          color: AppColors.surfaceLow,
          borderRadius: AppRadius.xs,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.xs,
            child: SizedBox(width: 40, height: 40, child: Icon(icono, size: 20, color: AppColors.onSurface)),
          ),
        ),
      ),
    );
  }
}

class FechaElegida extends StatelessWidget {
  const FechaElegida(this.fecha, {super.key});

  final String fecha;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.xs),
      child: Row(
        children: [
          const SvgIcon('reagendar/calendar.svg', width: 13.5, height: 15),
          const SizedBox(width: 4),
          Expanded(child: Text(fecha, style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18))),
          Tag(
            label: 'ACTIVO',
            background: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            style: AppText.sans(12, weight: FontWeight.w700, color: Colors.white, lineHeight: 16, letterSpacing: 0.55),
          ),
        ],
      ),
    );
  }
}
