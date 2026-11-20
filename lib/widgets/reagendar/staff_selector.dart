import 'package:flutter/material.dart';

import '../../models/opcion_staff.dart';
import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class StaffSelector extends StatelessWidget {
  const StaffSelector({
    super.key,
    required this.titular,
    required this.especialidad,
    required this.opciones,
    required this.seleccion,
    this.onSelect,
  });

  final String titular;

  final String especialidad;
  final List<OpcionStaff> opciones;
  final int seleccion;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 48,
                decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.xs),
                clipBehavior: Clip.antiAlias,
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgIcon('reagendar/staff_camera.svg', width: 20, height: 18),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: SizedBox(width: 12, height: 12, child: ColoredBox(color: AppColors.accent)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(titular, style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
                        const SizedBox(width: 6),
                        const SvgIcon('reagendar/verified.svg', width: 14.667, height: 14),
                      ],
                    ),
                    Text(especialidad, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    Text('Asignada actualmente',
                        style: AppText.sans(11, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 16.5)),
                  ],
                ),
              ),
              Tag(
                label: 'CONFIRMADA',
                background: AppColors.surfaceHigh,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                style: AppText.sans(11, weight: FontWeight.w600, lineHeight: 16.5, letterSpacing: 0.55),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('O ASIGNAR A OTRO FOTÓGRAFO:',
              style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          const SizedBox(height: 4),
          for (var i = 0; i < opciones.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _OpcionTile(opcion: opciones[i], selected: i == seleccion, onTap: () => onSelect?.call(i)),
          ],
        ],
      ),
    );
  }
}

class _OpcionTile extends StatelessWidget {
  const _OpcionTile({required this.opcion, required this.selected, required this.onTap});

  final OpcionStaff opcion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final auto = opcion.automatica;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(selected ? 12 : 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceHigh : AppColors.surfaceLow,
          borderRadius: AppRadius.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.black : AppColors.surfaceHighest,
                borderRadius: AppRadius.lg,
              ),
              child: selected ? const Dot(color: Colors.white) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opcion.nombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                  Text(opcion.detalle, style: AppText.sans(11, color: AppColors.onSurfaceVariant, lineHeight: 16.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(opcion.etiqueta,
                style: selected
                    ? AppText.sans(12, weight: FontWeight.w700, lineHeight: 18)
                    : AppText.sans(auto ? 11 : 12,
                        weight: auto ? FontWeight.w500 : FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        lineHeight: auto ? 16.5 : 18)),
          ],
        ),
      ),
    );
  }
}
